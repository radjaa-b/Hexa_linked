import axiosInstance from "../api/axiosInstance";

// GET /maintenance
export const getMaintenanceRequests = async () => {
  const response = await axiosInstance.get("/maintenance");
  return response.data;
};

// GET /maintenance/:id
export const getMaintenanceRequestById = async (id) => {
  const response = await axiosInstance.get(`/maintenance/${id}`);
  return response.data;
};

// PATCH /maintenance/:id/status
export const updateMaintenanceStatus = async (id, status) => {
  const response = await axiosInstance.patch(`/maintenance/${id}/status`, {
    status,
  });
  return response.data;
};

// PATCH /maintenance/:id/assign
export const assignTechnicianToMaintenance = async (id, technicianId) => {
  const response = await axiosInstance.patch(`/maintenance/${id}/assign`, {
    technician_id: technicianId,
  });
  return response.data;
};