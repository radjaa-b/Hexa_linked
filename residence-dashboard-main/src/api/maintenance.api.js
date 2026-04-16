import axiosInstance from "./axiosInstance";

// ============================================================
// Radja: all maintenance request API calls are here.
// Residents submit requests from the mobile app.
// Technician views and updates status from the web.
// ============================================================

// GET /technician/maintenance?status=pending|in_progress|completed
export const getMaintenanceRequests = async (status = "all") => {
  const response = await axiosInstance.get("/technician/maintenance", {
    params: { status },
  });
  return response.data;
};

// PATCH /technician/maintenance/:id/status
// body: { status: "in_progress"|"completed", note: string }
// Radja: after update, send push notification to resident mobile app
export const updateMaintenanceStatus = async (id, status, note) => {
  const response = await axiosInstance.patch(
    `/technician/maintenance/${id}/status`,
    { status, note }
  );
  return response.data;
};