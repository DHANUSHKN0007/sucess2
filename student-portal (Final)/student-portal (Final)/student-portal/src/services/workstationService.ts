/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

// localStorage (not sessionStorage): the ID identifies the machine, so it must outlive any one student's session.
const WORKSTATION_ID_KEY = 'mitm_workstation_id';

// One page load always uses one ID even when localStorage is blocked; without this every call would invent a new ID and the
// lab server would see the login and the instructor sign-in as two different machines.
let inMemoryId: string | null = null;

export const workstationService = {
  getWorkstationId(): string {
    try {
      const stored = localStorage.getItem(WORKSTATION_ID_KEY);
      if (stored) return stored;
    } catch {
      // Storage unavailable; the in-memory ID below keeps this page load consistent.
    }
    if (!inMemoryId) {
      // getRandomValues rather than randomUUID: randomUUID is undefined on plain-HTTP LAN origins.
      const hex = Array.from(crypto.getRandomValues(new Uint8Array(4)), (b) =>
        b.toString(16).padStart(2, '0')
      ).join('');
      inMemoryId = `WS-${hex.toUpperCase()}`;
    }
    workstationService.setWorkstationId(inMemoryId);
    return inMemoryId;
  },

  setWorkstationId(id: string): void {
    try {
      localStorage.setItem(WORKSTATION_ID_KEY, id);
    } catch {
      // Ignore
    }
  },
};
