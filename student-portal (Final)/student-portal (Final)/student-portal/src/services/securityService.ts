/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import {
  SecurityAuditLogEntry,
  SecurityLockState,
  SecurityViolationInfo,
  SecurityViolationType,
} from '../types/security';
import { apiClient } from '../api/client';

export const INVIGILATOR_SECRET_PASSWORD = 'MIT@CBT2026';
export const MAX_INVIGILATOR_ATTEMPTS = 3;

const SECURITY_LOCK_STATE_KEY = 'mitm_cbt_security_lock_state_v1';
const SECURITY_AUDIT_LOGS_KEY = 'mitm_cbt_security_audit_logs_v1';

const INITIAL_LOCK_STATE: SecurityLockState = {
  isLocked: false,
  violation: null,
  violationCount: 0,
  lockedAtMs: null,
  failedAttempts: 0,
  maxAttempts: MAX_INVIGILATOR_ATTEMPTS,
  isPermanentlyLocked: false,
  resumptionCount: 0,
  lastResumedAt: null,
  savedQuestionIndex: 0,
  savedRemainingSeconds: 2700,
  savedAnswerCount: 0,
};

export const securityService = {
  getLockState(): SecurityLockState {
    try {
      const raw = localStorage.getItem(SECURITY_LOCK_STATE_KEY);
      if (!raw) return { ...INITIAL_LOCK_STATE };
      return JSON.parse(raw) as SecurityLockState;
    } catch {
      return { ...INITIAL_LOCK_STATE };
    }
  },

  saveLockState(state: SecurityLockState): void {
    try {
      localStorage.setItem(SECURITY_LOCK_STATE_KEY, JSON.stringify(state));
    } catch {
      // Ignore quota issues
    }
  },

  triggerLockdown(params: {
    violationType: SecurityViolationType;
    label: string;
    description: string;
    studentUsn: string;
    studentName: string;
    examinationId: string;
    currentQuestionIndex: number;
    remainingSeconds: number;
    answeredCount: number;
  }): SecurityLockState {
    const current = this.getLockState();

    if (current.isLocked) {
      return current;
    }

    const now = new Date();
    const nowMs = now.getTime();
    const formattedTime = now.toLocaleString('en-IN', {
      day: '2-digit',
      month: 'short',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit',
      hour12: true,
    });

    const violation: SecurityViolationInfo = {
      type: params.violationType,
      label: params.label,
      description: params.description,
      detectedAt: formattedTime,
      detectedAtMs: nowMs,
    };

    const newViolationCount = current.violationCount + 1;

    const updatedState: SecurityLockState = {
      ...current,
      isLocked: true,
      violation,
      violationCount: newViolationCount,
      lockedAtMs: nowMs,
      savedQuestionIndex: params.currentQuestionIndex,
      savedRemainingSeconds: params.remainingSeconds,
      savedAnswerCount: params.answeredCount,
    };

    this.saveLockState(updatedState);

    // Record Event 1: Malpractice / Violation Detected
    this.addAuditLog({
      studentUsn: params.studentUsn,
      studentName: params.studentName,
      examinationId: params.examinationId,
      event: `${params.label} detected`,
      violationType: params.violationType,
      status: 'Locked',
      details: `${params.description} (Incident #${newViolationCount}). Interface locked immediately.`,
      questionNumberAtEvent: params.currentQuestionIndex + 1,
      remainingSecondsAtEvent: params.remainingSeconds,
    });

    // Notify backend server asynchronously
    apiClient
      .post('/api/security/violation', {
        violationType: params.violationType,
        label: params.label,
        description: params.description,
        studentUsn: params.studentUsn,
        examinationId: params.examinationId,
        currentQuestionIndex: params.currentQuestionIndex,
        remainingSeconds: params.remainingSeconds,
        answeredCount: params.answeredCount,
      })
      .catch(() => {
        // Safe offline fallback
      });

    return updatedState;
  },

  async verifyInvigilatorPassword(params: {
    enteredPassword: string;
    studentUsn: string;
    studentName: string;
    examinationId: string;
  }): Promise<{ success: boolean; message: string; state: SecurityLockState }> {
    const current = this.getLockState();

    if (!current.isLocked) {
      return {
        success: true,
        message: 'Examination is already unlocked.',
        state: current,
      };
    }

    if (current.isPermanentlyLocked) {
      throw new Error(
        'Maximum authorization attempts exceeded (3/3). This session is permanently locked. Chief Invigilator / HOD administrative override required.'
      );
    }

    const trimmedPassword = params.enteredPassword.trim();
    if (!trimmedPassword) {
      throw new Error('Please enter the invigilator authorization password.');
    }

    // Attempt authoritative backend verification first
    try {
      const serverResponse = await apiClient.post<{
        success: boolean;
        message: string;
        state: SecurityLockState;
      }>('/api/security/unlock', {
        enteredPassword: trimmedPassword,
        studentUsn: params.studentUsn,
        examinationId: params.examinationId,
      });

      if (serverResponse.success) {
        this.saveLockState(serverResponse.state);
        return serverResponse;
      }
    } catch {
      // Backend is unreachable; fallback to secure local offline verification
    }

    // Local fallback verification
    const isMatch = trimmedPassword === INVIGILATOR_SECRET_PASSWORD;
    const now = new Date();
    const formattedTime = now.toLocaleString('en-IN', {
      day: '2-digit',
      month: 'short',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit',
      hour12: true,
    });

    if (isMatch) {
      const updatedState: SecurityLockState = {
        ...current,
        isLocked: false,
        violation: null,
        failedAttempts: 0,
        isPermanentlyLocked: false,
        resumptionCount: current.resumptionCount + 1,
        lastResumedAt: formattedTime,
      };

      this.saveLockState(updatedState);

      this.addAuditLog({
        studentUsn: params.studentUsn,
        studentName: params.studentName,
        examinationId: params.examinationId,
        event: 'Invigilator password entered',
        status: 'Successful',
        details: 'Valid invigilator authorization password entered by proctor. Session unlocked.',
        attemptNumber: current.failedAttempts + 1,
        questionNumberAtEvent: current.savedQuestionIndex + 1,
        remainingSecondsAtEvent: current.savedRemainingSeconds,
      });

      return {
        success: true,
        message: 'Invigilator verification successful. Your examination session has been restored.',
        state: updatedState,
      };
    } else {
      const newFailed = current.failedAttempts + 1;
      const isNowPermanent = newFailed >= MAX_INVIGILATOR_ATTEMPTS;

      const updatedState: SecurityLockState = {
        ...current,
        failedAttempts: newFailed,
        isPermanentlyLocked: isNowPermanent,
      };

      this.saveLockState(updatedState);

      this.addAuditLog({
        studentUsn: params.studentUsn,
        studentName: params.studentName,
        examinationId: params.examinationId,
        event: 'Invigilator password attempt failed',
        status: isNowPermanent ? 'Permanent Lock' : 'Failed',
        details: isNowPermanent
          ? 'Failed authorization attempt #3. Session permanently locked. Administrative override required.'
          : `Invalid password entered (Attempt ${newFailed}/${MAX_INVIGILATOR_ATTEMPTS}).`,
        attemptNumber: newFailed,
        questionNumberAtEvent: current.savedQuestionIndex + 1,
        remainingSecondsAtEvent: current.savedRemainingSeconds,
      });

      const remainingAttempts = MAX_INVIGILATOR_ATTEMPTS - newFailed;
      const message = isNowPermanent
        ? 'Maximum invigilator attempts exceeded (3/3). This workstation is permanently locked. Contact Chief Invigilator.'
        : `Invalid invigilator password. ${remainingAttempts} attempt${remainingAttempts === 1 ? '' : 's'} remaining before permanent lockdown.`;

      return {
        success: false,
        message,
        state: updatedState,
      };
    }
  },

  addAuditLog(entry: {
    studentUsn: string;
    studentName: string;
    examinationId: string;
    event: string;
    status: 'Locked' | 'Successful' | 'Failed' | 'Restored' | 'Permanent Lock';
    details: string;
    violationType?: SecurityViolationType;
    attemptNumber?: number;
    questionNumberAtEvent?: number;
    remainingSecondsAtEvent?: number;
  }): SecurityAuditLogEntry {
    const logs = this.getAuditLogs();
    const now = new Date();
    const formattedTime = now.toLocaleString('en-IN', {
      day: '2-digit',
      month: 'short',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit',
      hour12: true,
    });

    const newLog: SecurityAuditLogEntry = {
      id: `SEC-LOG-${Date.now().toString(36).toUpperCase()}-${Math.floor(Math.random() * 1000)}`,
      timestamp: formattedTime,
      timestampMs: now.getTime(),
      studentUsn: entry.studentUsn,
      studentName: entry.studentName,
      examinationId: entry.examinationId,
      event: entry.event,
      violationType: entry.violationType,
      status: entry.status,
      details: entry.details,
      attemptNumber: entry.attemptNumber,
      questionNumberAtEvent: entry.questionNumberAtEvent,
      remainingSecondsAtEvent: entry.remainingSecondsAtEvent,
    };

    logs.unshift(newLog);

    try {
      localStorage.setItem(SECURITY_AUDIT_LOGS_KEY, JSON.stringify(logs.slice(0, 100)));
    } catch {
      // Ignore
    }

    return newLog;
  },

  getAuditLogs(): SecurityAuditLogEntry[] {
    try {
      const raw = localStorage.getItem(SECURITY_AUDIT_LOGS_KEY);
      if (!raw) return [];
      return JSON.parse(raw) as SecurityAuditLogEntry[];
    } catch {
      return [];
    }
  },

  async fetchRemoteAuditLogs(): Promise<SecurityAuditLogEntry[]> {
    try {
      return await apiClient.get<SecurityAuditLogEntry[]>('/api/security/audit-logs');
    } catch {
      return this.getAuditLogs();
    }
  },
};
