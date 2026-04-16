import axiosInstance from "./axiosInstance";

// ============================================================
// Radja: all announcements API calls are here.
// Announcements posted here appear in the resident mobile app.
// ============================================================

// GET /announcements
export const getAnnouncements = async () => {
  const response = await axiosInstance.get("/announcements");
  return response.data;
};

// POST /announcements
// body: { title: string, body: string, pinned: bool }
export const createAnnouncement = async (data) => {
  const response = await axiosInstance.post("/announcements", data);
  return response.data;
};

// PUT /announcements/:id
export const updateAnnouncement = async (id, data) => {
  const response = await axiosInstance.put(`/announcements/${id}`, data);
  return response.data;
};

// DELETE /announcements/:id
export const deleteAnnouncement = async (id) => {
  const response = await axiosInstance.delete(`/announcements/${id}`);
  return response.data;
};