import axiosInstance from "../api/axiosInstance";

export const getContactRequests = async () => {
  const response = await axiosInstance.get("/admin/contact-requests");
  return response.data;
};

export const getContactRequestById = async (id) => {
  const response = await axiosInstance.get(`/admin/contact-requests/${id}`);
  return response.data;
};

export const updateContactRequestStatus = async (id, status) => {
  const response = await axiosInstance.patch(`/admin/contact-requests/${id}`, {
    status,
  });
  return response.data;
};