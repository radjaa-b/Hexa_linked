import axiosInstance from "../api/axiosInstance";

export const getAnnouncements = async () => {
  const response = await axiosInstance.get("/announcements");
  return response.data;
};

export const createAnnouncement = async (data) => {
  const response = await axiosInstance.post("/announcements", data);
  return response.data;
};

export const updateAnnouncement = async (id, data) => {
  const response = await axiosInstance.put(`/announcements/${id}`, data);
  return response.data;
};

export const deleteAnnouncement = async (id) => {
  await axiosInstance.delete(`/announcements/${id}`);
};