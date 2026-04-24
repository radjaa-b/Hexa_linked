// All frontend URL paths in one place.
// Radja: no action needed here — this is purely frontend routing.
// Just make sure your API base URL is set in api/axiosInstance.js

export const ROUTES = {
  LOGIN: "/",

  // Admin pages
  ADMIN_DASHBOARD:  "/admin/dashboard",
  ADMIN_RESIDENTS:  "/admin/residents",
  ADMIN_STAFF:      "/admin/staff",
  ADMIN_MESSAGES:   "/admin/messages",  // ← also handles announcements
  ADMIN_ACCESS_LOG: "/admin/access-log",
  ADMIN_CONSUMPTION:"/admin/consumption",
  ADMIN_ALERTS: "/admin/alerts",

  // Security agent pages
  SECURITY_GATE:      "/security/gate",
  SECURITY_VISITORS:  "/security/visitors",
  SECURITY_ALERTS:    "/security/surveillance",
  SECURITY_INCIDENTS: "/security/incidents",
  SECURITY_NUMBERS: "/security/important-numbers",

  // Technician pages
  TECH_MAINTENANCE: "/technician/maintenance",
  TECH_ENERGY:      "/technician/energy",
  TECH_IOT: "/technician/iot",
};