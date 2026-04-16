import axiosInstance from "./axiosInstance";

// ============================================================
// Radja: all access/gate API calls are here.
// ============================================================

// GET /admin/access-log?from=date&to=date&page=1&limit=20
export const getAccessLog = async (params) => {
  const response = await axiosInstance.get("/admin/access-log", { params });
  return response.data;
};

// GET /security/gate/status
// Returns: { id, name, status: "open"|"closed", lastChangedBy, lastChangedAt }
export const getGateStatus = async () => {
  const response = await axiosInstance.get("/security/gate/status");
  return response.data;
};

// POST /security/gate/control
// body: { action: "open"|"close", gateId: string }
// Radja: agent opens/closes the gate manually from here
export const controlGate = async (action, gateId) => {
  const response = await axiosInstance.post("/security/gate/control", {
    action,
    gateId,
  });
  return response.data;
};

// POST /security/gate/manual-entry
// body: { visitorName, unit, gateId, type: "visitor"|"staff" }
// Radja: agent logs a manual entry for a visitor or staff member
export const logManualEntry = async (data) => {
  const response = await axiosInstance.post("/security/gate/manual-entry", data);
  return response.data;
};