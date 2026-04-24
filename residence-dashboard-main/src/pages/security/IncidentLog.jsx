import { useState, useMemo, useEffect } from "react";
import PageWrapper from "../../components/layout/PageWrapper";
import "./IncidentLog.css";
import { getAlerts, updateAlertStatus } from "../../services/alertService";

const typeConfig = {
  fire: { label: "Fire", color: "#e74c3c", bg: "#fdf0f0" },
  medical: { label: "Medical", color: "#e67e22", bg: "#fdf0e0" },
  security: { label: "Security", color: "#e74c3c", bg: "#fdf0f0" },
  noise: { label: "Noise", color: "#854F0B", bg: "#faeeda" },
  other: { label: "Other", color: "#888", bg: "#f5f5f5" },
};

const severityConfig = {
  critical: { label: "Critical", color: "#e74c3c", bg: "#fdf0f0" },
  high: { label: "High", color: "#e67e22", bg: "#fdf0e0" },
  medium: { label: "Medium", color: "#d97706", bg: "#fff4e5" },
  low: { label: "Low", color: "#64748b", bg: "#f8fafc" },
};

const statusLabels = {
  pending: "Pending",
  in_progress: "In progress",
  resolved: "Resolved",
};

const formatTime = (iso) => {
  if (!iso) return "Unknown time";

  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return iso;

  return (
    d.toLocaleDateString("en-GB", {
      day: "numeric",
      month: "short",
    }) +
    " · " +
    d.toLocaleTimeString("en-GB", {
      hour: "2-digit",
      minute: "2-digit",
    })
  );
};

const normalizeAlert = (item) => ({
  id: item.id,
  type: item.incident_type || "other",
  severity:
    item.incident_type === "fire" || item.incident_type === "security"
      ? "critical"
      : item.incident_type === "medical"
      ? "high"
      : item.incident_type === "noise"
      ? "medium"
      : "low",
  description: item.description || "No description provided.",
  location: item.location || "Unknown location",
  triggeredAt: item.created_at,
  status: item.status || "pending",
  residentId: item.resident_id,
  residentName: item.resident_name || item.resident_username || null,
});

const TypeIcon = ({ type }) => {
  const color = typeConfig[type]?.color || "#888";

  if (type === "fire") {
    return (
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2.2">
        <path d="M12 2c0 0-4 4-4 8a4 4 0 0 0 8 0c0-4-4-8-4-8z" />
        <path d="M12 14c0 0-2 2-2 4a2 2 0 0 0 4 0c0-2-2-4-2-4z" />
      </svg>
    );
  }

  if (type === "security") {
    return (
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2.2">
        <rect x="3" y="11" width="18" height="11" rx="2" />
        <path d="M7 11V7a5 5 0 0 1 10 0v4" />
      </svg>
    );
  }

  if (type === "medical") {
    return (
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2.2">
        <path d="M12 5v14" />
        <path d="M5 12h14" />
      </svg>
    );
  }

  if (type === "noise") {
    return (
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2.2">
        <path d="M11 5L6 9H3v6h3l5 4V5z" />
        <path d="M15 9a5 5 0 0 1 0 6" />
        <path d="M18 6a9 9 0 0 1 0 12" />
      </svg>
    );
  }

  return (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2.2">
      <circle cx="12" cy="12" r="10" />
      <line x1="12" y1="8" x2="12" y2="12" />
      <line x1="12" y1="16" x2="12.01" y2="16" />
    </svg>
  );
};

const IncidentLog = () => {
  const [alerts, setAlerts] = useState([]);
  const [loadingAlerts, setLoadingAlerts] = useState(true);
  const [alertError, setAlertError] = useState("");

  const [filter, setFilter] = useState("all");
  const [typeFilter, setTypeFilter] = useState("all");
  const [resolvingId, setResolvingId] = useState(null);
  const [lastUpdated, setLastUpdated] = useState(new Date());

  const loadAlerts = async () => {
    try {
      setLoadingAlerts(true);
      setAlertError("");

      const data = await getAlerts();
      console.log("SECURITY ALERTS RAW DATA:", data);

      const normalized = Array.isArray(data)
        ? data.map(normalizeAlert)
        : [];

      setAlerts(normalized);
      setLastUpdated(new Date());
    } catch (error) {
      console.error("Failed to load security alerts:", error);
      console.error("Backend response:", error?.response?.data);
      setAlertError(error?.response?.data?.detail || "Failed to load alerts.");
      setAlerts([]);
    } finally {
      setLoadingAlerts(false);
    }
  };

  useEffect(() => {
    loadAlerts();
  }, []);

  const updateStatus = async (id, newStatus) => {
    try {
      setResolvingId(id);
      setAlertError("");

      const updated = await updateAlertStatus(id, newStatus);

      setAlerts((prev) =>
        prev.map((alert) =>
          alert.id === id ? normalizeAlert(updated) : alert
        )
      );

      setLastUpdated(new Date());
    } catch (error) {
      console.error("Failed to update alert status:", error);
      console.error("Backend response:", error?.response?.data);
      setAlertError(error?.response?.data?.detail || "Failed to update alert status.");
    } finally {
      setResolvingId(null);
    }
  };

  const activeCount = alerts.filter((a) => a.status !== "resolved").length;
  const criticalCount = alerts.filter(
    (a) => a.severity === "critical" && a.status !== "resolved"
  ).length;
  const resolvedCount = alerts.filter((a) => a.status === "resolved").length;

  const filtered = useMemo(() => {
    return alerts
      .filter((a) => {
        const matchStatus = filter === "all" ? true : a.status === filter;
        const matchType = typeFilter === "all" ? true : a.type === typeFilter;
        return matchStatus && matchType;
      })
      .sort((a, b) => {
        const order = { critical: 4, high: 3, medium: 2, low: 1 };

        return (
          order[b.severity] - order[a.severity] ||
          new Date(b.triggeredAt) - new Date(a.triggeredAt)
        );
      });
  }, [alerts, filter, typeFilter]);

  return (
    <PageWrapper>
      <div className="surv-layout">
        <div className="surv-hero">
          <div className="surv-hero-hex">
            <svg width="160" height="140" viewBox="0 0 160 140" fill="none">
              <path
                d="M80 8L144 44V116L80 152L16 116V44L80 8Z"
                stroke="white"
                strokeWidth="1"
                opacity="0.15"
              />
              <path
                d="M80 32L120 55V101L80 124L40 101V55L80 32Z"
                stroke="white"
                strokeWidth="0.8"
                opacity="0.1"
              />
            </svg>
          </div>

          <div>
            <div className="surv-hero-tag">Security Agent</div>

            <div className="surv-hero-title">
              Incidents & Alerts
              {criticalCount > 0 && (
                <span className="surv-critical-badge">
                  {criticalCount} CRITICAL
                </span>
              )}
            </div>

            <div className="surv-hero-stats">
              <div className="surv-hs">
                <span className="surv-hs-val" style={{ color: "#f87171" }}>
                  {activeCount}
                </span>
                <span className="surv-hs-label">Active alerts</span>
              </div>

              <div className="surv-hs-div" />

              <div className="surv-hs">
                <span className="surv-hs-val" style={{ color: "#fb923c" }}>
                  {criticalCount}
                </span>
                <span className="surv-hs-label">Critical</span>
              </div>

              <div className="surv-hs-div" />

              <div className="surv-hs">
                <span className="surv-hs-val">{resolvedCount}</span>
                <span className="surv-hs-label">Resolved</span>
              </div>

              <div className="surv-hs-div" />

              <div className="surv-hs">
                <span className="surv-hs-val">{alerts.length}</span>
                <span className="surv-hs-label">Total</span>
              </div>
            </div>

            <div style={{ fontSize: "11px", color: "rgba(255,255,255,0.5)", marginTop: "12px" }}>
              Last updated{" "}
              {lastUpdated.toLocaleTimeString([], {
                hour: "2-digit",
                minute: "2-digit",
              })}
            </div>
          </div>
        </div>

        <div className="surv-filters">
          <div className="surv-status-filters">
            {["all", "pending", "in_progress", "resolved"].map((f) => (
              <button
                key={f}
                className={`surv-filter-btn ${filter === f ? "active" : ""}`}
                onClick={() => setFilter(f)}
              >
                {statusLabels[f] || "All"}
                {f !== "resolved" && f !== "all" && activeCount > 0 && (
                  <span className="surv-filter-dot" />
                )}
              </button>
            ))}
          </div>

          <select
            className="surv-type-filter"
            value={typeFilter}
            onChange={(e) => setTypeFilter(e.target.value)}
          >
            <option value="all">All types</option>
            {["fire", "medical", "security", "noise", "other"].map((key) => (
              <option key={key} value={key}>
                {typeConfig[key]?.label || key}
              </option>
            ))}
          </select>
        </div>

        <div className="surv-list">
          {loadingAlerts ? (
            <div className="surv-empty">Loading alerts...</div>
          ) : alertError ? (
            <div className="surv-empty">{alertError}</div>
          ) : filtered.length === 0 ? (
            <div className="surv-empty">
              No alerts found for the selected filters.
            </div>
          ) : (
            filtered.map((alert) => (
              <div
                key={alert.id}
                className={`surv-alert ${alert.status} ${alert.severity}`}
              >
                <div className="surv-alert-left">
                  <div
                    className="surv-alert-icon"
                    style={{
                      background: typeConfig[alert.type]?.bg || "#f5f5f5",
                    }}
                  >
                    <TypeIcon type={alert.type} />
                  </div>
                </div>

                <div className="surv-alert-body">
                  <div className="surv-alert-top">
                    <span className="surv-alert-type">
                      {typeConfig[alert.type]?.label || alert.type}
                    </span>

                    <span
                      className="surv-alert-severity"
                      style={{
                        background: severityConfig[alert.severity].bg,
                        color: severityConfig[alert.severity].color,
                      }}
                    >
                      {severityConfig[alert.severity].label}
                    </span>

                    <span className={`surv-${alert.status === "resolved" ? "resolved" : "active"}-pill`}>
                      {statusLabels[alert.status] || alert.status}
                    </span>
                  </div>

                  <div className="surv-alert-desc">{alert.description}</div>

                  <div className="surv-alert-meta">
                    <svg
                      width="11"
                      height="11"
                      viewBox="0 0 24 24"
                      fill="none"
                      stroke="currentColor"
                      strokeWidth="2"
                    >
                      <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z" />
                      <circle cx="12" cy="10" r="3" />
                    </svg>

                    {alert.location}

                    <span className="surv-meta-sep">·</span>
                    {formatTime(alert.triggeredAt)}

                    <span className="surv-meta-sep">·</span>
                    {alert.residentName || `Resident #${alert.residentId || "—"}`}
                  </div>
                </div>

                {alert.status !== "resolved" && (
                  <div className="surv-alert-action">
                    {alert.status === "pending" && (
                      <button
                        className="surv-resolve-btn"
                        onClick={() => updateStatus(alert.id, "in_progress")}
                        disabled={resolvingId === alert.id}
                      >
                        {resolvingId === alert.id ? "Updating..." : "Start handling"}
                      </button>
                    )}

                    {alert.status === "in_progress" && (
                      <button
                        className="surv-resolve-btn"
                        onClick={() => updateStatus(alert.id, "resolved")}
                        disabled={resolvingId === alert.id}
                      >
                        {resolvingId === alert.id ? "Updating..." : "Mark as resolved"}
                      </button>
                    )}
                  </div>
                )}
              </div>
            ))
          )}
        </div>
      </div>
    </PageWrapper>
  );
};

export default IncidentLog;