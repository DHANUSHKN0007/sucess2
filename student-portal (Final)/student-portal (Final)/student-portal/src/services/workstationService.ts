/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

// localStorage (not sessionStorage): the ID identifies the machine, so it must outlive any one student's session.
const WORKSTATION_ID_KEY = 'mitm_workstation_id';

export const workstationService = {
  getWorkstationId(): string {
    try {
      const stored = localStorage.getItem(WORKSTATION_ID_KEY);
      if (stored) return stored;
    } catch {
      // Storage unavailable; fall through to a fresh ID the student can overwrite in the form.
    }
    // getRandomValues rather than randomUUID: randomUUID is undefined on plain-HTTP LAN origins.
    const hex = Array.from(crypto.getRandomValues(new Uint8Array(4)), (b) =>
      b.toString(16).padStart(2, '0')
    ).join('');
    const id = `WS-${hex.toUpperCase()}`;
    workstationService.setWorkstationId(id);
    return id;
  },

  setWorkstationId(id: string): void {
    try {
      localStorage.setItem(WORKSTATION_ID_KEY, id);
    } catch {
      // Ignore
    }
  },
};
