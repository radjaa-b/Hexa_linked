import axiosInstance from "./axiosInstance";

// ============================================================
// Radja: all resident-related API calls are here.
// ============================================================

// GET /admin/residents?page=1&limit=20&search=&status=
export const getResidents = async (params) => {
  const response = await axiosInstance.get("/admin/residents", { params });
  return response.data;
};

// GET /admin/residents/:id
export const getResident = async (id) => {
  const response = await axiosInstance.get(`/admin/residents/${id}`);
  return response.data;
};

// POST /admin/residents
// Radja: after creating, backend should auto-generate password
// and send it to the resident via SMS or email
export const createResident = async (data) => {
  const response = await axiosInstance.post("/admin/residents", data);
  return response.data;
};

// PUT /admin/residents/:id
export const updateResident = async (id, data) => {
  const response = await axiosInstance.put(`/admin/residents/${id}`, data);
  return response.data;
};

// PATCH /admin/residents/:id/status
// body: { status: "active" | "suspended" }
export const updateResidentStatus = async (id, status) => {
  const response = await axiosInstance.patch(
    `/admin/residents/${id}/status`,
    { status }
  );
  return response.data;
};