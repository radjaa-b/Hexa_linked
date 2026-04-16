// These are the three roles in the system.
// Radja: the "role" field in the login response must match
// one of these exactly (lowercase). The frontend uses this
// to decide which dashboard to show after login.

export const ROLES = {
  ADMIN:      "admin",
  SECURITY:   "security",
  TECHNICIAN: "technician",
};