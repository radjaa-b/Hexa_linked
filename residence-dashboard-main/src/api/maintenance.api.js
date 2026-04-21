import axiosInstance from "./axiosInstance";

// ============================================================
// Radja: all maintenance request API calls are here.
// Residents submit requests from the mobile app.
// Technician views and updates status from the web.
// ============================================================

// GET /technician/maintenance?status=pending|in_progress|completed
export const getMaintenanceRequests = async (status = "all") => {
  const params = status !== "all" ? { status } : {};
  const response = await axiosInstance.get("/maintenance", { params });
  return response.data;
};

export const updateMaintenanceStatus = async (id, status, note) => {
  const response = await axiosInstance.patch(
    `/maintenance/${id}/status`,
    { status, note }
  );
  return response.data;
};