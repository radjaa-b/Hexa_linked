import axiosInstance from "./axiosInstance";

// ============================================================
// Radja: all visitor request API calls are here.
// Residents submit visitor requests from the mobile app.
// Security agent approves or rejects from the web.
// ============================================================

// GET /security/visitors?status=pending|approved|rejected|all
export const getVisitors = async (status = "all") => {
  const response = await axiosInstance.get("/security/visitors", {
    params: { status },
  });
  return response.data;
};

// PATCH /security/visitors/:id
// body: { status: "approved"|"rejected", note: string }
// Radja: after approval, send push notification to resident mobile app
export const updateVisitorStatus = async (id, status, note) => {
  const response = await axiosInstance.patch(`/security/visitors/${id}`, {
    status,
    note,
  });
  return response.data;
};