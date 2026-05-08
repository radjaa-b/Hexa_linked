import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import PageWrapper from "../../components/layout/PageWrapper";
import "./Dashboard.css";
import useAuth from "../../hooks/useAuth";
import {
  getMaintenanceRequests,
  getMaintenanceRequestById,
 
  assignTechnicianToMaintenance,
} from "../../services/maintenanceService";
import { getAlerts } from "../../services/alertService";
import {
  getAllVisitorRequests,
  getVisitorAccessLogs,
} from "../../services/visitorRequestsService";
import { getResidents } from "../../api/residents.api";
import { getContactRequests } from "../../services/contactAdminService";
import { getSecurityAccessLogs } from "../../services/accessLogService";

import { ROUTES } from "../../constants/routes";

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
  if (Number.isNaN(parsed.getTime())) return value;

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

const isToday = (value) => {
  if (!value) return false;

  const d = new Date(value);
  if (Number.isNaN(d.getTime())) return false;

  const now = new Date();

  return (
    d.getFullYear() === now.getFullYear() &&
    d.getMonth() === now.getMonth() &&
    d.getDate() === now.getDate()
  );
};

const staffShifts = [
  {
    id: "SEC-204",
    role: "Security Agent",
    icon: "🛡️",
    name: "Youcef Bouaroudj",
    email: "youcefbouaroudj891@gmail.com",
    shift: "08:00 → 16:00",
    status: "On shift",
  },
  {
    id: "TECH-118",
    role: "Technician",
    icon: "🛠️",
    name: "Atyl Maintenance",
    email: "atyl00hv@gmail.com",
    shift: "14:00 → 22:00",
    status: "On shift",
  },
  {
    id: "SEC-332",
    role: "Security Agent",
    icon: "🛡️",
    name: "Karim Ouali",
    email: "karimBenn@gmail.com",
    shift: "22:00 → 06:00",
    status: "Upcoming",
  },
];

const Dashboard = () => {
  const { user } = useAuth();
  const navigate = useNavigate();

  const loadTechnicians = async () => {
  try {
    const data = await getResidents({ search: "" });

    const techs = Array.isArray(data)
      ? data
          .filter((user) => user.role === "technician")
          .map((user) => ({
            id: user.id,
            name: user.full_name || user.username || `Technician #${user.id}`,
            email: user.email || "No email",
          }))
      : [];

    setTechnicians(techs);
  } catch (error) {
    console.error("Failed to load technicians:", error);
    setTechnicians([]);
  }
};

  const [stats, setStats] = useState({
    totalResidents: 0,
    todayEntries: 0,
    pendingRequests: 0,
    newMessages: 0,
  });

  const [maintenance, setMaintenance] = useState([]);
  const [alerts, setAlerts] = useState([]);
  const [visitorRequests, setVisitorRequests] = useState([]);
  const [accessLogs, setAccessLogs] = useState([]);
  const [consumption] = useState(mockConsumption);

  const [loadingMaintenance, setLoadingMaintenance] = useState(true);
  const [loadingAlerts, setLoadingAlerts] = useState(true);
  const [loadingVisitors, setLoadingVisitors] = useState(true);
  const [loadingLogs, setLoadingLogs] = useState(true);

  const [selectedRequest, setSelectedRequest] = useState(null);
  const [loadingRequestDetails, setLoadingRequestDetails] = useState(false);


  const [technicianId, setTechnicianId] = useState("");
const [technicians, setTechnicians] = useState([]);
  const [actionLoading, setActionLoading] = useState(false);
  const [actionError, setActionError] = useState("");
  const [actionSuccess, setActionSuccess] = useState("");

  const loadDashboardStats = async () => {
    try {
      const [
        residentsData,
        visitorRequestsData,
        visitorLogsData,
        securityLogsData,
        maintenanceData,
        alertsData,
        contactRequestsData,
      ] = await Promise.all([
        getResidents({ search: "" }),
        getAllVisitorRequests(),
        getVisitorAccessLogs(),
        getSecurityAccessLogs(),
        getMaintenanceRequests(),
        getAlerts(),
        getContactRequests(),
      ]);

      const totalResidents = Array.isArray(residentsData)
        ? residentsData.filter((u) => u.role === "resident").length
        : 0;

      const visitorEntriesToday = Array.isArray(visitorLogsData)
        ? visitorLogsData.filter((log) =>
            isToday(log.created_at || log.event_time || log.timestamp)
          ).length
        : 0;

      const manualEntriesToday = Array.isArray(securityLogsData)
        ? securityLogsData.filter((log) =>
            isToday(log.event_time || log.created_at || log.timestamp)
          ).length
        : 0;

      const pendingMaintenance = Array.isArray(maintenanceData)
        ? maintenanceData.filter((r) =>
            ["pending", "in_progress"].includes(
              (r.status || "").toLowerCase()
            )
          ).length
        : 0;

      const pendingVisitors = Array.isArray(visitorRequestsData)
        ? visitorRequestsData.filter((v) => v.status === "PENDING").length
        : 0;

      const pendingAlerts = Array.isArray(alertsData)
        ? alertsData.filter((a) =>
            ["pending", "in_progress"].includes(
              (a.status || "").toLowerCase()
            )
          ).length
        : 0;

      const pendingContactMessages = Array.isArray(contactRequestsData)
        ? contactRequestsData.filter(
            (m) => (m.status || "").toLowerCase() === "pending"
          ).length
        : 0;

      setStats({
        totalResidents,
        todayEntries: visitorEntriesToday + manualEntriesToday,
        pendingRequests: pendingMaintenance + pendingVisitors + pendingAlerts,
        newMessages: pendingContactMessages,
      });
    } catch (error) {
      console.error("Failed to load dashboard stats:", error);
    }
  };

  const loadMaintenance = async (silent = false) => {
    try {
      if (!silent) setLoadingMaintenance(true);

      const data = await getMaintenanceRequests();

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
      if (!silent) setLoadingMaintenance(false);
    }
  };

  const loadAlerts = async (silent = false) => {
    try {
      if (!silent) setLoadingAlerts(true);

      const data = await getAlerts();

      const normalized = Array.isArray(data)
        ? data.slice(0, 3).map((item) => ({
            id: item.id,
            title: item.incident_type?.toUpperCase() || "Alert",
            sub: `${item.location || "Unknown"} · ${new Date(
              item.created_at
            ).toLocaleTimeString([], {
              hour: "2-digit",
              minute: "2-digit",
            })}`,
            type:
              item.incident_type === "fire" ||
              item.incident_type === "security"
                ? "danger"
                : "warning",
          }))
        : [];

      setAlerts(normalized);
    } catch (error) {
      console.error("Failed to load alerts:", error);
      setAlerts([]);
    } finally {
      if (!silent) setLoadingAlerts(false);
    }
  };

  const loadVisitorRequests = async (silent = false) => {
    try {
      if (!silent) setLoadingVisitors(true);

      const data = await getAllVisitorRequests();

      const pending = Array.isArray(data)
        ? data.filter((v) => v.status === "PENDING").slice(0, 5)
        : [];

      setVisitorRequests(pending);
    } catch (error) {
      console.error("Failed to load visitors:", error);
      setVisitorRequests([]);
    } finally {
      if (!silent) setLoadingVisitors(false);
    }
  };

  const loadAccessLogs = async (silent = false) => {
    try {
      if (!silent) setLoadingLogs(true);

      const data = await getVisitorAccessLogs();

      const normalized = Array.isArray(data)
        ? data.slice(0, 5).map((log) => ({
            id: log.id,
            name: log.visitor_name || "Visitor",
            unit: `Unit ${log.unit_number || "-"}`,
            status: log.status,
            time: new Date(log.created_at).toLocaleTimeString([], {
              hour: "2-digit",
              minute: "2-digit",
            }),
          }))
        : [];

      setAccessLogs(normalized);
    } catch (error) {
      console.error("Failed to load logs:", error);
      setAccessLogs([]);
    } finally {
      if (!silent) setLoadingLogs(false);
    }
  };

  useEffect(() => {
    loadDashboardStats();
    loadMaintenance();
    loadAlerts();
    loadVisitorRequests();
    loadAccessLogs();
    loadTechnicians();

    const interval = setInterval(() => {
      loadDashboardStats();
      loadMaintenance(true);
      loadAlerts(true);
      loadVisitorRequests(true);
      loadAccessLogs(true);
    }, 5000);

    return () => clearInterval(interval);
  }, []);

  const openMaintenanceDetails = async (id) => {
    try {
      setLoadingRequestDetails(true);
      setActionError("");
      setActionSuccess("");

      setTechnicianId("");

      const data = await getMaintenanceRequestById(id);
      setSelectedRequest(data);
     
      setTechnicianId(
        data.assigned_technician_id ? String(data.assigned_technician_id) : ""
      );
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
      setActionError("Please select a technician.");
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
      await loadMaintenance(true);
      await loadDashboardStats();
    } catch (error) {
      console.error("Failed to assign technician:", error);
      setActionError(
        error?.response?.data?.detail || "Failed to assign technician."
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
              {user?.full_name || "Administrator"}
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
    <span className="dash-card-title">Staff on shift</span>
    <span className="dash-card-subtitle">Today</span>
  </div>

  <div className="dash-shift-list">
    {staffShifts.map((staff) => (
      <div key={staff.id} className="dash-shift-item">
        <div className="dash-shift-icon">{staff.icon}</div>

        <div className="dash-shift-info">
          <div className="dash-shift-top">
            <span className="dash-shift-name">{staff.name}</span>
            <span
              className={`dash-shift-status ${
                staff.status === "On shift" ? "active" : "upcoming"
              }`}
            >
              {staff.status}
            </span>
          </div>

          <span className="dash-shift-role">{staff.role}</span>
          <span className="dash-shift-email">{staff.email}</span>

          <div className="dash-shift-bottom">
            <span>{staff.shift}</span>
            <span>{staff.id}</span>
          </div>
        </div>
      </div>
    ))}
  </div>
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
                          {item.category} · Unit {item.unitNumber} ·{" "}
                          {formatPreferredDate(item.preferredDate)}
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
                {consumption.water.up ? "↑" : "↓"} {consumption.water.trend} vs
                last month
              </div>
            </div>
          </div>

          <div className="dash-rp-section">
            <div
              className="dash-rp-title"
              onClick={() => navigate(ROUTES.ADMIN_ALERTS)}
              style={{ cursor: "pointer" }}
            >
              Alerts
            </div>

            {loadingAlerts ? (
              <div className="dash-empty">Loading alerts...</div>
            ) : alerts.length === 0 ? (
              <div className="dash-empty">No alerts</div>
            ) : (
              alerts.map((alert) => (
                <button
                  key={alert.id}
                  type="button"
                  className={`dash-rp-alert ${alert.type}`}
                  onClick={() => navigate(ROUTES.ADMIN_ALERTS)}
                  style={{
                    width: "100%",
                    border: "none",
                    textAlign: "left",
                    cursor: "pointer",
                  }}
                >
                  <div className="dash-rp-alert-title">{alert.title}</div>
                  <div className="dash-rp-alert-sub">{alert.sub}</div>
                </button>
              ))
            )}
          </div>

          <div className="dash-rp-section">
            <div className="dash-rp-title">Pending visitors</div>

            {loadingVisitors ? (
              <div className="dash-empty">Loading visitors...</div>
            ) : visitorRequests.length === 0 ? (
              <div className="dash-empty">No pending visitors</div>
            ) : (
              visitorRequests.map((v) => (
                <div key={v.id} className="dash-rp-visitor">
                  <div className="dash-rp-avatar">
                    {v.visitor_name?.slice(0, 2).toUpperCase()}
                  </div>

                  <span className="dash-rp-vname">{v.visitor_name}</span>

                  <span className={`dash-rp-vbadge ${v.status}`}>
                    {v.status}
                  </span>
                </div>
              ))
            )}
          </div>
        </div>
      </div>

      {(selectedRequest || loadingRequestDetails) && (
        <div className="dash-modal-overlay" onClick={closeMaintenanceDetails}>
          <div className="dash-modal" onClick={(e) => e.stopPropagation()}>
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
                      <p className="dash-modal-value">
                        {selectedRequest.maintenance_type}
                      </p>
                    </div>
                    <div>
                      <span className="dash-modal-label">Status</span>
                      <p className="dash-modal-value">
                        {selectedRequest.status}
                      </p>
                    </div>
                    <div>
                      <span className="dash-modal-label">Unit</span>
                      <p className="dash-modal-value">
                        {selectedRequest.unit_number}
                      </p>
                    </div>
                    <div>
                      <span className="dash-modal-label">Preferred date</span>
                      <p className="dash-modal-value">
                        {selectedRequest.preferred_date}
                      </p>
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
                      <span className="dash-modal-label">
                        Assigned technician
                      </span>
                      <p className="dash-modal-value">
                        {selectedRequest.assigned_technician_username ||
                          "Not assigned"}
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

  <div className="dash-tech-picker">
    {technicians.map((tech) => (
      <button
        key={tech.id}
        type="button"
        className={`dash-tech-option ${
          String(technicianId) === String(tech.id) ? "selected" : ""
        }`}
        onClick={() => setTechnicianId(String(tech.id))}
      >
        <div className="dash-tech-avatar">🛠️</div>

        <div className="dash-tech-info">
          <span className="dash-tech-name">{tech.name}</span>
          <span className="dash-tech-email">{tech.email}</span>
        </div>

        <span className="dash-tech-id">#{tech.id}</span>
      </button>
    ))}
  </div>

  <button
    type="button"
    className="dash-modal-btn dash-tech-assign-btn"
    onClick={handleAssignTechnician}
    disabled={actionLoading}
  >
    Assign selected technician
  </button>
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