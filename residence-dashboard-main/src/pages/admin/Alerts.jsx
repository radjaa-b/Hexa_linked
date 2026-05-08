// src/pages/admin/Alerts.jsx
import { useEffect, useState } from "react";
import PageWrapper from "../../components/layout/PageWrapper";
import { getAlerts, updateAlertStatus } from "../../services/alertService";
import "./Alerts.css";

const TYPE_META = {
  fire:     { label: "Fire",     emoji: "🔥" },
  medical:  { label: "Medical",  emoji: "🚑" },
  security: { label: "Security", emoji: "🚨" },
  noise:    { label: "Noise",    emoji: "🔊" },
};

const FILTERS = ["all", "pending", "in_progress", "resolved"];
const FILTER_LABELS = { all: "All", pending: "Pending", in_progress: "In progress", resolved: "Resolved" };

const formatDate = (iso) => {
  const d = new Date(iso);
  return d.toLocaleDateString("en-GB", { day: "2-digit", month: "short", year: "numeric" })
    + " · "
    + d.toLocaleTimeString("en-GB", { hour: "2-digit", minute: "2-digit" });
};

const AdminAlerts = () => {
  const [alerts, setAlerts]     = useState([]);
  const [loading, setLoading]   = useState(true);
  const [filter, setFilter]     = useState("all");
  const [updating, setUpdating] = useState(null);
  const [error, setError]       = useState("");

  const load = async () => {
    try {
      const data = await getAlerts();
      setAlerts(Array.isArray(data) ? data : []);
    } catch (e) {
      console.error("Failed to load alerts:", e);
      setError("Failed to load alerts.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    load();
    const interval = setInterval(load, 5000);
    return () => clearInterval(interval);
  }, []);

  const handleStatusChange = async (alertId, newStatus) => {
    try {
      setUpdating(alertId);
      await updateAlertStatus(alertId, newStatus);
      setAlerts((prev) =>
        prev.map((a) => a.id === alertId ? { ...a, status: newStatus } : a)
      );
    } catch (e) {
      console.error("Failed to update alert status:", e);
    } finally {
      setUpdating(null);
    }
  };

  const filtered = filter === "all" ? alerts : alerts.filter((a) => a.status === filter);

  const total      = alerts.length;
  const pending    = alerts.filter((a) => a.status === "pending").length;
  const inProgress = alerts.filter((a) => a.status === "in_progress").length;
  const resolved   = alerts.filter((a) => a.status === "resolved").length;

  return (
    <PageWrapper>
      <div className="al-layout">

        {/* Hero */}
        <div className="al-hero">
          <div className="al-hero-hex">
            <svg width="160" height="140" viewBox="0 0 160 140" fill="none">
              <path d="M80 8L144 44V116L80 152L16 116V44L80 8Z" stroke="white" strokeWidth="1" opacity="0.15"/>
              <path d="M80 32L120 55V101L80 124L40 101V55L80 32Z" stroke="white" strokeWidth="0.8" opacity="0.1"/>
            </svg>
          </div>
          <div>
            <div className="al-hero-tag">Admin · Alerts</div>
            <div className="al-hero-title">
              Alerts
              {pending > 0 && <span className="al-hero-badge">{pending} pending</span>}
            </div>
            <div className="al-hero-sub">All incidents submitted by residents</div>
          </div>
          <div className="al-hero-stats">
            <div className="al-stat"><span>{total}</span><p>Total</p></div>
            <div className="al-stat"><span>{pending}</span><p>Pending</p></div>
            <div className="al-stat"><span>{inProgress}</span><p>In progress</p></div>
            <div className="al-stat"><span>{resolved}</span><p>Resolved</p></div>
          </div>
        </div>

        {/* Filters */}
        <div className="al-filters">
          {FILTERS.map((f) => (
            <button
              key={f}
              type="button"
              className={`al-filter-btn ${filter === f ? "active" : ""}`}
              onClick={() => setFilter(f)}
            >
              {FILTER_LABELS[f]}
            </button>
          ))}
        </div>

        {/* List */}
        <div className="al-card">
          {error && <div className="al-empty error">{error}</div>}

          {loading ? (
            <div className="al-empty">Loading alerts...</div>
          ) : filtered.length === 0 ? (
            <div className="al-empty">No alerts found.</div>
          ) : (
            <div className="al-list">
              {filtered.map((alert) => {
                const type = TYPE_META[alert.incident_type] || { label: alert.incident_type, emoji: "⚠️" };

                return (
                  <div key={alert.id} className="al-item">
                    <div className="al-item-icon">{type.emoji}</div>

                    <div className="al-item-content">
                      <div className="al-item-top">
                        <div>
                          <h3>{type.label}</h3>
                          <p>#{alert.id} · {formatDate(alert.created_at)}</p>
                        </div>
                        <select
                          className={`al-status-select ${alert.status}`}
                          value={alert.status}
                          disabled={updating === alert.id}
                          onChange={(e) => handleStatusChange(alert.id, e.target.value)}
                        >
                          <option value="pending">Pending</option>
                          <option value="in_progress">In progress</option>
                          <option value="resolved">Resolved</option>
                        </select>
                      </div>

                      <p className="al-item-desc">
                        {alert.description || "No description provided."}
                      </p>

                      <div className="al-item-meta">
                        <span>
  📍 {
    alert.location &&
    alert.location.trim() !== "" &&
    alert.location !== "String"
      ? alert.location
      : "Location not provided"
  }
</span>
                        <span>👤 {alert.resident_username}</span>
                        <span>✉️ {alert.resident_email}</span>
                        {updating === alert.id && <span>Saving...</span>}
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </div>

      </div>
    </PageWrapper>
  );
};

export default AdminAlerts;