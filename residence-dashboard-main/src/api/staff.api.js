import axiosInstance from "./axiosInstance";

// ============================================================
// Radja: all staff-related API calls are here.
// Staff = security agents + technicians.
// Admin creates all accounts — no self-registration.
// ============================================================

// GET /admin/staff
export const getStaff = async () => {
  const response = await axiosInstance.get("/admin/staff");
  return response.data;
};

// POST /admin/staff
// Radja: after creating, backend auto-generates password
// and sends it to the staff member via SMS or email.
// body: { name, role: "security"|"technician", phone, email }
export const createStaff = async (data) => {
  const response = await axiosInstance.post("/admin/staff", data);
  return response.data;
};

// PUT /admin/staff/:id
export const updateStaff = async (id, data) => {
  const response = await axiosInstance.put(`/admin/staff/${id}`, data);
  return response.data;
};

// PATCH /admin/staff/:id/status
// body: { status: "active" | "inactive" }
export const updateStaffStatus = async (id, status) => {
  const response = await axiosInstance.patch(
    `/admin/staff/${id}/status`,
    { status }
  );
  return response.data;
};