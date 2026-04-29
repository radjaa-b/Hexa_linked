import axiosInstance from "../api/axiosInstance";

export const getMyNotifications = async () => {
  const response = await axiosInstance.get("/notifications/me");
  return response.data;
};

export const getUnreadNotificationCount = async () => {
  const response = await axiosInstance.get("/notifications/unread-count");
  return response.data.unread_count;
};

export const markNotificationAsRead = async (notificationId) => {
  const response = await axiosInstance.patch(
    `/notifications/${notificationId}/read`
  );
  return response.data;
};