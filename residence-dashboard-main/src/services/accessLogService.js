import axiosInstance from "../api/axiosInstance";

export const createSecurityAccessLog = async (data) => {
  const res = await axiosInstance.post("/security/access-log", data);
  return res.data;
};

export const getSecurityAccessLogs = async () => {
  const res = await axiosInstance.get("/security/access-log");
  return res.data;
};