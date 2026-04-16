import axiosInstance from "./axiosInstance";

// ============================================================
// Radja: all surveillance/alerts API calls are here.
// Alerts can be triggered by IoT sensors or manually.
// ============================================================

// GET /security/alerts?status=active|resolved|all&type=
// Radja: returns paginated alerts list
export const getAlerts = async (params) => {
  const response = await axiosInstance.get("/security/alerts", { params });
  return response.data;
};

// PATCH /security/alerts/:id/resolve
// body: { note: string }
export const resolveAlert = async (id, note) => {
  const response = await axiosInstance.patch(
    `/security/alerts/${id}/resolve`,
    { note }
  );
  return response.data;
};