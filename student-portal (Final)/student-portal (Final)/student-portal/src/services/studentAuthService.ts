/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import {
  StudentLoginRequest,
  StudentLoginResponse,
} from '../types/examination';
import { apiClient } from '../api/client';
import { workstationService } from './workstationService';

/**
 * Student Authentication Service
 * Verifies student USN and Date of Birth against the Lab Server.
 */
export const studentAuthService = {
  async login(credentials: StudentLoginRequest): Promise<StudentLoginResponse> {
    const response = await apiClient.post<StudentLoginResponse>(
      '/api/student/login',
      // The machine ID is never typed by the student; the lab server needs it for its one-candidate-per-computer check.
      { ...credentials, workstationId: workstationService.getWorkstationId() }
    );

    if (response.student?.sessionToken) {
      apiClient.setStoredToken(response.student.sessionToken);
    }
    return response;
  },

  async logout(): Promise<void> {
    try {
      await apiClient.post('/api/student/logout');
    } catch {
      // Offline / network failure on logout is safely ignored
    } finally {
      apiClient.setStoredToken(null);
    }
  },

  getActiveSessionToken(): string | null {
    return apiClient.getStoredToken();
  },
};
