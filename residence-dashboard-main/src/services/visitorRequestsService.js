import axiosInstance from "../api/axiosInstance";

// -----------------------------
// Resident
// -----------------------------

export const createVisitorRequest = async (data) => {
  const res = await axiosInstance.post("/visitor-requests", data);
  return res.data;
};

export const getMyVisitorRequests = async () => {
  const res = await axiosInstance.get("/visitor-requests/my");
  return res.data;
};

export const cancelVisitorRequest = async (id) => {
  const res = await axiosInstance.patch(`/visitor-requests/${id}/cancel`);
  return res.data;
};

// -----------------------------
// Security Agent
// -----------------------------

export const getAllVisitorRequests = async () => {
  const res = await axiosInstance.get("/visitor-requests");
  return res.data;
};

export const approveVisitorRequest = async (id) => {
  const res = await axiosInstance.patch(`/visitor-requests/${id}/approve`);
  return res.data;
};

export const rejectVisitorRequest = async (id) => {
  const res = await axiosInstance.patch(`/visitor-requests/${id}/reject`);
  return res.data;
};

export const markVisitorArrived = async (id) => {
  const res = await axiosInstance.patch(`/visitor-requests/${id}/arrived`);
  return res.data;
};

export const markVisitorExited = async (id) => {
  const res = await axiosInstance.patch(`/visitor-requests/${id}/exited`);
  return res.data;
};