import axiosInstance from "../api/axiosInstance";

export const getAlerts = async () => {
  const response = await axiosInstance.get("/alerts");
  return response.data;
};

export const getAlertById = async (alertId) => {
  const response = await axiosInstance.get(`/alerts/${alertId}`);
  return response.data;
};

export const updateAlertStatus = async (alertId, status) => {
  const response = await axiosInstance.patch(`/alerts/${alertId}/status`, {
    status,
  });
  return response.data;
};