import axiosInstance from "./axiosInstance";

// ============================================================
// Radja: all consumption/energy API calls are here.
// ============================================================

// GET /admin/consumption/overview?period=weekly|monthly
// Returns electricity and water stats + trends
export const getConsumptionOverview = async (period) => {
  const response = await axiosInstance.get("/admin/consumption/overview", {
    params: { period },
  });
  return response.data;
};

// GET /technician/energy/history?metric=electricity|water&period=weekly|monthly
// Returns chart data (array of { date, value })
export const getEnergyHistory = async (metric, period) => {
  const response = await axiosInstance.get("/technician/energy/history", {
    params: { metric, period },
  });
  return response.data;
};