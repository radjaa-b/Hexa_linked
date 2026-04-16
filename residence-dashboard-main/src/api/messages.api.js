import axiosInstance from "./axiosInstance";

// ============================================================
// Radja: all messages/contact API calls are here.
// Residents submit contact forms from the mobile app.
// Admin reads and replies from the web.
// ============================================================

// GET /admin/messages?status=unread|read|resolved|all
export const getMessages = async (status = "all") => {
  const response = await axiosInstance.get("/admin/messages", {
    params: { status },
  });
  return response.data;
};

// GET /admin/messages/:id — full thread
export const getMessage = async (id) => {
  const response = await axiosInstance.get(`/admin/messages/${id}`);
  return response.data;
};

// POST /admin/messages/:id/reply
// body: { body: string }
export const replyToMessage = async (id, body) => {
  const response = await axiosInstance.post(
    `/admin/messages/${id}/reply`,
    { body }
  );
  return response.data;
};

// PATCH /admin/messages/:id/status
// body: { status: "read" | "resolved" }
export const updateMessageStatus = async (id, status) => {
  const response = await axiosInstance.patch(
    `/admin/messages/${id}/status`,
    { status }
  );
  return response.data;
};