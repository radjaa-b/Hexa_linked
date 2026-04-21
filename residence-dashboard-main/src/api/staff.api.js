import axiosInstance from "./axiosInstance";

export const getAllUsers = async () => {
  const response = await axiosInstance.get("/admin/users");
  return response.data;
};

export const createStaff = async ({ email, full_name, role }) => {
  const response = await axiosInstance.post("/auth/admin/create-user", {
    email,
    full_name,
    role,
  });
  return response.data;
};

export const updateStaff = async (id, data) => {
  const response = await axiosInstance.patch(`/admin/users/${id}`, data);
  return response.data;
};

export const updateStaffStatus = async (id, is_active) => {
  const response = await axiosInstance.patch(`/admin/users/${id}`, {
    is_active,
  });
  return response.data;
};