import axiosInstance from "../api/axiosInstance";

export const createSecurityAccessLog = async (data) => {
  const res = await axiosInstance.post("/security/access-log", data);
  return res.data;
};

export const createVerifiedManualAccess = async (data) => {
  const res = await axiosInstance.post("/security/manual-access", data);
  return res.data;
};

export const getSecurityAccessLogs = async () => {
  const res = await axiosInstance.get("/security/access-log");
  return res.data;
};

export const searchResidentsForManualAccess = async (q) => {
  const res = await axiosInstance.get("/security/residents/search", {
    params: { q },
  });

  return res.data;
};

export const searchVisitorsForManualAccess = async (q) => {
  const res = await axiosInstance.get("/security/visitors/search", {
    params: { q },
  });

  return res.data;
};