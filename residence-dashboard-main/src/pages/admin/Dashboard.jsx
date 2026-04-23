import { useEffect, useState } from "react";
import PageWrapper from "../../components/layout/PageWrapper";
import "./Dashboard.css";
import useAuth from "../../hooks/useAuth";
import {
  getMaintenanceRequests,
  getMaintenanceRequestById,
  updateMaintenanceStatus,
  assignTechnicianToMaintenance,
} from "../../services/maintenanceService";

const mockStats = {
  totalResidents: 120,
  todayEntries: 34,
  pendingRequests: 4,
  newMessages: 2,
};

const mockAccessLog = [
  { id: 1, name: "Ahmed Benali", unit: "Unit A-12 · Resident", type: "entry", time: "08:30" },
  { id: 2, name: "Karima Saidi", unit: "Security Agent · Staff", type: "entry", time: "08:15" },
  { id: 3, name: "Unknown visitor", unit: "Gate 2 · Unauthorized", type: "alert", time: "07:55" },
  { id: 4, name: "Youcef Amrani", unit: "Unit B-04 · Resident", type: "entry", time: "07:40" },
];

const mockAlerts = [
  { id: 1, title: "Unauthorized access", sub: "Gate 2 · 07:55 today", type: "danger" },
  { id: 2, title: "High consumption", sub: "Building B · Electricity", type: "warning" },
];

const mockVisitors = [
  { id: 1, name: "Karim Ouali", initials: "KO" },
  { id: 2, name: "Sara Bensaid", initials: "SB" },
];

const mockConsumption = {
  electricity: { value: 1240, unit: "kWh", trend: "+5%", up: true },
  water: { value: 340, unit: "m³", trend: "-2%", up: false },
};

const statusStyles = {
  pending: { bg: "#E6F1FB", color: "#185FA5", label: "Pending" },
  in_progress: { bg: "#fdf0e0", color: "#e67e22", label: "In progress" },
  completed: { bg: "#edfaf5", color: "#0F6E56", label: "Completed" },
};

const today = new Date().toLocaleDateString("en-GB", {
  weekday: "long",
  year: "numeric",
  month: "long",
  day: "numeric",
});

const formatPreferredDate = (value) => {
  if (!value) return "No preferred date";

  const parsed = new Date(value);
  if (Number.isNaN(parsed.getTime())) {
    return value;
  }

  return (
    parsed.toLocaleDateString("en-GB", {
      day: "2-digit",
      month: "short",
    }) +
    " · " +
    parsed.toLocaleTimeString("en-GB", {
      hour: "2-digit",
      minute: "2-digit",
    })
  );
};

const Dashboard = () => {
  const { user } = useAuth();

  const [stats] = useState(mockStats);
  const [accessLog] = useState(mockAccessLog);
  const [maintenance, setMaintenance] = useState([]);
  const [alerts] = useState(mockAlerts);
  const [visitors] = useState(mockVisitors);
  const [consumption] = useState(mockConsumption);

  const [loadingMaintenance, setLoadingMaintenance] = useState(true);

  const [selectedRequest, setSelectedRequest] = useState(null);
  const [loadingRequestDetails, setLoadingRequestDetails] = useState(false);

  const [statusValue, setStatusValue] = useState("");
  const [technicianId, setTechnicianId] = useState("");
  const [actionLoading, setActionLoading] = useState(false);
  const [actionError, setActionError] = useState("");
  const [actionSuccess, setActionSuccess] = useState("");

  const loadMaintenance = async () => {
    try {
      setLoadingMaintenance(true);

      const data = await getMaintenanceRequests();
      console.log("MAINTENANCE RAW DATA:", data);

      const normalized = Array.isArray(data)
        ? data
            .filter((item) => item.status !== "completed")
            .slice(0, 3)
            .map((item) => ({
              id: item.id,
              title: item.maintenance_type || `Request #${item.id}`,
              category: item.maintenance_type || "General",
              priority: item.status || "pending",
              description: item.description || "",
              unitNumber: item.unit_number || "-",
              preferredDate: item.preferred_date || "",
            }))
        : [];

      setMaintenance(normalized);
    } catch (error) {
      console.error("Failed to load maintenance requests:", error);
      console.error("Backend response:", error?.response?.data);
      setMaintenance([]);

    } finally {
      setLoadingMaintenance(false);
    }
  };

  useEffect(() => {
    loadMaintenance();
  }, []);

  const openMaintenanceDetails = async (id) => {
    try {
      setLoadingRequestDetails(true);
      setActionError("");
      setActionSuccess("");
      setStatusValue("");
      setTechnicianId("");

      const data = await getMaintenanceRequestById(id);
      setSelectedRequest(data);
      setStatusValue(data.status || "");
      setTechnicianId(data.assigned_technician_id ? String(data.assigned_technician_id) : "");
    } catch (error) {
      console.error("Failed to load maintenance request details:", error);
      setActionError("Failed to load request details.");
    } finally {
      setLoadingRequestDetails(false);
    }
  };

  const closeMaintenanceDetails = () => {
    setSelectedRequest(null);
    setActionError("");
    setActionSuccess("");
    setStatusValue("");
    setTechnicianId("");
  };

  const handleAssignTechnician = async () => {
    if (!selectedRequest || !technicianId.trim()) {
      setActionError("Please enter a technician ID.");
      return;
    }

    try {
      setActionLoading(true);
      setActionError("");
      setActionSuccess("");

      const updated = await assignTechnicianToMaintenance(
        selectedRequest.id,
        Number(technicianId)
      );

      setSelectedRequest(updated);
      setActionSuccess("Technician assigned successfully.");
      await loadMaintenance();
    } catch (error) {
      console.error("Failed to assign technician:", error);
      setActionError(
        error?.response?.data?.detail || "Failed to assign technician."
      );
    } finally {
      setActionLoading(false);
    }
  };

  const handleUpdateStatus = async () => {
    if (!selectedRequest || !statusValue) {
      setActionError("Please choose a status.");
      return;
    }

    try {
      setActionLoading(true);
      setActionError("");
      setActionSuccess("");

      const updated = await updateMaintenanceStatus(
        selectedRequest.id,
        statusValue
      );

      setSelectedRequest(updated);
      setActionSuccess("Status updated successfully.");
      await loadMaintenance();
    } catch (error) {
      console.error("Failed to update status:", error);
      setActionError(
        error?.response?.data?.detail || "Failed to update status."
      );
    } finally {
      setActionLoading(false);
    }
  };

  return (
    <PageWrapper>
      <div className="dash-layout">
        <div className="dash-main">
          <div className="dash-hero">
            <div className="dash-hero-hex">
              <svg width="220" height="200" viewBox="0 0 200 180" fill="none">
                <path
                  d="M100 10L180 55V145L100 190L20 145V55L100 10Z"
                  stroke="white"
                  strokeWidth="1"
                  opacity="0.15"
                />
                <path
                  d="M100 40L150 68V122L100 150L50 122V68L100 40Z"
                  stroke="white"
                  strokeWidth="0.8"
                  opacity="0.1"
                />
                <path
                  d="M100 70L125 84V110L100 124L75 110V84L100 70Z"
                  stroke="white"
                  strokeWidth="0.6"
                  opacity="0.08"
                />
              </svg>
            </div>

            <div className="dash-hero-tag">{today}</div>

            <div className="dash-hero-title">
              Good {getGreeting()},<br />
              Administrator
            </div>

            <div className="dash-hero-stats">
              <div className="dash-hs">
                <span className="dash-hs-val">{stats.totalResidents}</span>
                <span className="dash-hs-label">Residents</span>
              </div>

              <div className="dash-hs-divider" />

              <div className="dash-hs">
                <span className="dash-hs-val">{stats.todayEntries}</span>
                <span className="dash-hs-label">Entries today</span>
              </div>

              <div className="dash-hs-divider" />

              <div className="dash-hs">
                <span className="dash-hs-val">{stats.pendingRequests}</span>
                <span className="dash-hs-label">Pending requests</span>
              </div>

              <div className="dash-hs-divider" />

              <div className="dash-hs">
                <span className="dash-hs-val">{stats.newMessages}</span>
                <span className="dash-hs-label">New messages</span>
              </div>
            </div>
          </div>

          <div className="dash-cards">
            <div className="dash-card">
              <div className="dash-card-head">
                <span className="dash-card-title">Recent access</span>
                <span className="dash-card-more">View all</span>
              </div>

              {accessLog.map((item) => (
                <div key={item.id} className="dash-log-item">
                  <div className={`dash-log-icon ${item.type}`}>
                    {item.type === "alert" ? (
                      <svg
                        width="13"
                        height="13"
                        viewBox="0 0 24 24"
                        fill="none"
                        stroke="#e74c3c"
                        strokeWidth="2"
                      >
                        <circle cx="12" cy="12" r="10" />
                        <line x1="12" y1="8" x2="12" y2="12" />
                        <line x1="12" y1="16" x2="12.01" y2="16" />
                      </svg>
                    ) : (
                      <svg
                        width="13"
                        height="13"
                        viewBox="0 0 24 24"
                        fill="none"
                        stroke="#1D9E75"
                        strokeWidth="2"
                      >
                        <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
                      </svg>
                    )}
                  </div>

                  <div className="dash-log-info">
                    <span className="dash-log-name">{item.name}</span>
                    <span className="dash-log-unit">{item.unit}</span>
                  </div>

                  <span className="dash-log-time">{item.time}</span>
                </div>
              ))}
            </div>

            <div className="dash-card">
              <div className="dash-card-head">
                <span className="dash-card-title">Maintenance requests</span>
              </div>

              {loadingMaintenance ? (
                <div className="dash-empty">Loading maintenance requests...</div>
              ) : maintenance.length === 0 ? (
                <div className="dash-empty">No maintenance requests</div>
              ) : (
                maintenance.map((item) => {
                  const statusStyle =
                    statusStyles[item.priority] || statusStyles.pending;

                  return (
                    <button
                      key={item.id}
                      type="button"
                      className="dash-log-item dash-log-item-btn"
                      onClick={() => openMaintenanceDetails(item.id)}
                    >
                      <div className="dash-log-info">
                        <span className="dash-log-name">{item.title}</span>
                        <span className="dash-log-unit">
                          {item.category} · Unit {item.unitNumber} · {formatPreferredDate(item.preferredDate)}
                        </span>
                      </div>

                      <span
                        className="dash-badge"
                        style={{
                          background: statusStyle.bg,
                          color: statusStyle.color,
                        }}
                      >
                        {statusStyle.label}
                      </span>
                    </button>
                  );
                })
              )}
            </div>
          </div>
        </div>

        <div className="dash-right">
          <div className="dash-rp-section">
            <div className="dash-rp-title">Live consumption</div>

            <div className="dash-rp-stat">
              <div className="dash-rp-val">
                {consumption.electricity.value.toLocaleString()}
              </div>
              <div className="dash-rp-label">
                {consumption.electricity.unit} this month
              </div>
              <div
                className={`dash-rp-trend ${
                  consumption.electricity.up ? "up" : "down"
                }`}
              >
                {consumption.electricity.up ? "↑" : "↓"}{" "}
                {consumption.electricity.trend} vs last month
              </div>
            </div>

            <div className="dash-rp-stat">
              <div className="dash-rp-val">{consumption.water.value}</div>
              <div className="dash-rp-label">
                {consumption.water.unit} water used
              </div>
              <div
                className={`dash-rp-trend ${
                  consumption.water.up ? "up" : "down"
                }`}
              >
                {consumption.water.up ? "↑" : "↓"} {consumption.water.trend} vs last month
              </div>
            </div>
          </div>

          <div className="dash-rp-section">
            <div className="dash-rp-title">Alerts</div>

            {alerts.map((alert) => (
              <div key={alert.id} className={`dash-rp-alert ${alert.type}`}>
                <div className="dash-rp-alert-title">{alert.title}</div>
                <div className="dash-rp-alert-sub">{alert.sub}</div>
              </div>
            ))}
          </div>

          <div className="dash-rp-section">
            <div className="dash-rp-title">Pending visitors</div>

            {visitors.map((v) => (
              <div key={v.id} className="dash-rp-visitor">
                <div className="dash-rp-avatar">{v.initials}</div>
                <span className="dash-rp-vname">{v.name}</span>
                <span className="dash-rp-vbadge">Pending</span>
              </div>
            ))}
          </div>
        </div>
      </div>

      {(selectedRequest || loadingRequestDetails) && (
        <div className="dash-modal-overlay" onClick={closeMaintenanceDetails}>
          <div
            className="dash-modal"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="dash-modal-head">
              <h3 className="dash-modal-title">Maintenance request details</h3>
              <button
                type="button"
                className="dash-modal-close"
                onClick={closeMaintenanceDetails}
              >
                ×
              </button>
            </div>

            {loadingRequestDetails ? (
              <div className="dash-modal-loading">Loading details...</div>
            ) : selectedRequest ? (
              <>
                <div className="dash-modal-section">
                  <div className="dash-modal-grid">
                    <div>
                      <span className="dash-modal-label">Type</span>
                      <p className="dash-modal-value">{selectedRequest.maintenance_type}</p>
                    </div>
                    <div>
                      <span className="dash-modal-label">Status</span>
                      <p className="dash-modal-value">{selectedRequest.status}</p>
                    </div>
                    <div>
                      <span className="dash-modal-label">Unit</span>
                      <p className="dash-modal-value">{selectedRequest.unit_number}</p>
                    </div>
                    <div>
                      <span className="dash-modal-label">Preferred date</span>
                      <p className="dash-modal-value">{selectedRequest.preferred_date}</p>
                    </div>
                    <div>
                      <span className="dash-modal-label">Resident</span>
                      <p className="dash-modal-value">
                        {selectedRequest.resident_username || "Unknown"}
                      </p>
                    </div>
                    <div>
                      <span className="dash-modal-label">Resident email</span>
                      <p className="dash-modal-value">
                        {selectedRequest.resident_email || "Unknown"}
                      </p>
                    </div>
                    <div>
                      <span className="dash-modal-label">Assigned technician</span>
                      <p className="dash-modal-value">
                        {selectedRequest.assigned_technician_username || "Not assigned"}
                      </p>
                    </div>
                    <div>
                      <span className="dash-modal-label">Technician ID</span>
                      <p className="dash-modal-value">
                        {selectedRequest.assigned_technician_id || "—"}
                      </p>
                    </div>
                  </div>
                </div>

                <div className="dash-modal-section">
                  <span className="dash-modal-label">Description</span>
                  <p className="dash-modal-description">
                    {selectedRequest.description}
                  </p>
                </div>

                <div className="dash-modal-section">
                  <span className="dash-modal-label">Assign technician</span>
                  <div className="dash-modal-actions-row">
                    <input
                      type="number"
                      className="dash-modal-input"
                      placeholder="Enter technician ID"
                      value={technicianId}
                      onChange={(e) => setTechnicianId(e.target.value)}
                    />
                    <button
                      type="button"
                      className="dash-modal-btn"
                      onClick={handleAssignTechnician}
                      disabled={actionLoading}
                    >
                      Assign
                    </button>
                  </div>
                </div>

                <div className="dash-modal-section">
                  <span className="dash-modal-label">Update status</span>
                  <div className="dash-modal-actions-row">
                    <select
                      className="dash-modal-select"
                      value={statusValue}
                      onChange={(e) => setStatusValue(e.target.value)}
                    >
                      <option value="pending">Pending</option>
                      <option value="in_progress">In progress</option>
                      <option value="completed">Completed</option>
                    </select>

                    <button
                      type="button"
                      className="dash-modal-btn dash-modal-btn-secondary"
                      onClick={handleUpdateStatus}
                      disabled={actionLoading}
                    >
                      Update
                    </button>
                  </div>
                </div>

                {actionError ? (
                  <div className="dash-modal-feedback dash-modal-error">
                    {actionError}
                  </div>
                ) : null}

                {actionSuccess ? (
                  <div className="dash-modal-feedback dash-modal-success">
                    {actionSuccess}
                  </div>
                ) : null}
              </>
            ) : null}
          </div>
        </div>
      )}
    </PageWrapper>
  );
};

const getGreeting = () => {
  const h = new Date().getHours();
  if (h < 12) return "morning";
  if (h < 18) return "afternoon";
  return "evening";
};

export default Dashboard;