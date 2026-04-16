import axiosInstance from "./axiosInstance";

// GET /admin/users?q=
export const getResidents = async (params = {}) => {
  const response = await axiosInstance.get("/admin/users", {
    params: {
      q: params.search || undefined,
    },
  });
  return response.data;
};

export const getResident = async (id) => {
  const response = await axiosInstance.get(`/admin/users/${id}`);
  return response.data;
};

export const createResident = async (data) => {
  const response = await axiosInstance.post("/auth/admin/create-user", data);
  return response.data;
};

export const updateResident = async (id, data) => {
  const response = await axiosInstance.patch(`/admin/users/${id}`, data);
  return response.data;
};

export const updateResidentStatus = async (id, status) => {
  if (status === "active") {
    const response = await axiosInstance.patch(`/admin/users/${id}/reactivate`);
    return response.data;
  }

  const response = await axiosInstance.patch("/auth/admin/deactivate", null, {
    params: { email: status.email },
  });
  return response.data;
};