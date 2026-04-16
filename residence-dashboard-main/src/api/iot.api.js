import axiosInstance from "./axiosInstance";

// ============================================================
// Radja: all IoT device API calls are here.
// ============================================================

// GET /technician/iot/devices
// Returns list of all IoT devices with their current status
export const getIoTDevices = async () => {
  const response = await axiosInstance.get("/technician/iot/devices");
  return response.data;
};

// PATCH /technician/iot/devices/:id/status
// body: { status: "online"|"offline"|"maintenance" }
export const updateDeviceStatus = async (id, status) => {
  const response = await axiosInstance.patch(
    `/technician/iot/devices/${id}/status`,
    { status }
  );
  return response.data;
};

// GET /technician/iot/devices/:id/history
// Returns sensor reading history for charts
// Radja: use WebSocket for real-time readings:
// Event: "sensor.reading" → { deviceId, value, unit, timestamp }
export const getDeviceHistory = async (id) => {
  const response = await axiosInstance.get(
    `/technician/iot/devices/${id}/history`
  );
  return response.data;
};