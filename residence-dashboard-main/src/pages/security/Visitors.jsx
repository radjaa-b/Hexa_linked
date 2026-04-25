import { useEffect, useMemo, useState } from "react";
import PageWrapper from "../../components/layout/PageWrapper";
import "./Visitors.css";

import {
  getAllVisitorRequests,
  approveVisitorRequest,
  rejectVisitorRequest,
  markVisitorArrived,
  markVisitorExited,
} from "../../services/visitorRequestsService";

const statusConfig = {
  pending: { label: "Pending", bg: "#E6F1FB", color: "#185FA5" },
  approved: { label: "Approved", bg: "#edfaf5", color: "#0F6E56" },
  rejected: { label: "Rejected", bg: "#fdf0f0", color: "#e74c3c" },
  arrived: { label: "Arrived", bg: "#fff4e5", color: "#d97706" },
  exited: { label: "Exited", bg: "#f5f5f5", color: "#666" },
  cancelled: { label: "Cancelled", bg: "#f5f5f5", color: "#666" },
  expired: { label: "Expired", bg: "#f5f5f5", color: "#666" },
};

const formatDateTime = (date, start, end) => {
  if (!date) return "Unknown time";
  return `${date} · ${start || "--"} - ${end || "--"}`;
};

const formatSubmitted = (iso) => {
  if (!iso) return "Unknown";
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return iso;

  return (
    d.toLocaleDateString("en-GB", { day: "numeric", month: "short" }) +
    " at " +
    d.toLocaleTimeString("en-GB", { hour: "2-digit", minute: "2-digit" })
  );
};

const getInitials = (name = "") =>
  name
    .split(" ")
    .map((n) => n[0])
    .join("")
    .toUpperCase()
    .slice(0, 2) || "V";

const normalizeVisitor = (item) => ({
  id: item.id,
  visitorName: item.visitor_name,
  visitorPhone: item.visitor_phone || "No phone",
  visitorEmail: item.visitor_email || "No email",
  purpose: item.purpose || "Unknown purpose",
  visitDate: item.visit_date,
  startTime: item.start_time,
  endTime: item.end_time,
  status: (item.status || "PENDING").toLowerCase(),
  requestedBy: {
    name: item.resident_username || `Resident #${item.resident_id}`,
    unit: item.unit_number || "Unknown",
  },
  createdAt: item.created_at,
  note: item.note,
});

const Visitors = () => {
  const [visitors, setVisitors] = useState([]);
  const [filter, setFilter] = useState("all");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [processingId, setProcessingId] = useState(null);
  const [lastUpdated, setLastUpdated] = useState(new Date());

  const loadVisitors = async () => {
    try {
      setLoading(true);
      setError("");

      const data = await getAllVisitorRequests();
      console.log("VISITOR REQUESTS RAW:", data);

      const normalized = Array.isArray(data) ? data.map(normalizeVisitor) : [];
      setVisitors(normalized);
      setLastUpdated(new Date());
    } catch (err) {
      console.error("Failed to load visitor requests:", err);
      setError(err?.response?.data?.detail || "Failed to load visitor requests.");
      setVisitors([]);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadVisitors();

    const intervalId = setInterval(loadVisitors, 15000);
    return () => clearInterval(intervalId);
  }, []);

  const updateLocalVisitor = (updated) => {
    const normalized = normalizeVisitor(updated);
    setVisitors((prev) =>
      prev.map((visitor) => (visitor.id === normalized.id ? normalized : visitor))
    );
    setLastUpdated(new Date());
  };

  const handleApprove = async (id) => {
    try {
      setProcessingId(id);
      const updated = await approveVisitorRequest(id);
      updateLocalVisitor(updated);
    } catch (err) {
      alert(err?.response?.data?.detail || "Failed to approve request.");
    } finally {
      setProcessingId(null);
    }
  };

  const handleReject = async (id) => {
    const confirmed = window.confirm("Reject this visitor request?");
    if (!confirmed) return;

    try {
      setProcessingId(id);
      const updated = await rejectVisitorRequest(id);
      updateLocalVisitor(updated);
    } catch (err) {
      alert(err?.response?.data?.detail || "Failed to reject request.");
    } finally {
      setProcessingId(null);
    }
  };

  const handleArrived = async (id) => {
    try {
      setProcessingId(id);
      const updated = await markVisitorArrived(id);
      updateLocalVisitor(updated);
    } catch (err) {
      alert(err?.response?.data?.detail || "Failed to mark visitor as arrived.");
    } finally {
      setProcessingId(null);
    }
  };

  const handleExited = async (id) => {
    try {
      setProcessingId(id);
      const updated = await markVisitorExited(id);
      updateLocalVisitor(updated);
    } catch (err) {
      alert(err?.response?.data?.detail || "Failed to mark visitor as exited.");
    } finally {
      setProcessingId(null);
    }
  };

  const pendingCount = visitors.filter((v) => v.status === "pending").length;
  const approvedCount = visitors.filter((v) => v.status === "approved").length;
  const rejectedCount = visitors.filter((v) => v.status === "rejected").length;
  const arrivedCount = visitors.filter((v) => v.status === "arrived").length;

  const filtered = useMemo(() => {
    return visitors.filter((v) => (filter === "all" ? true : v.status === filter));
  }, [visitors, filter]);

  return (
    <PageWrapper>
      <div className="vis-layout">
        <div className="vis-hero">
          <div className="vis-hero-hex">
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
            <div className="vis-hero-tag">Security agent</div>

            <div className="vis-hero-title">
              Visitor Requests
              {pendingCount > 0 && (
                <span className="vis-pending-badge">{pendingCount} pending</span>
              )}
            </div>

            <div className="vis-hero-stats">
              <div className="vis-hs">
                <span className="vis-hs-val" style={{ color: "#85B7EB" }}>
                  {pendingCount}
                </span>
                <span className="vis-hs-label">Pending</span>
              </div>

              <div className="vis-hs-div" />

              <div className="vis-hs">
                <span className="vis-hs-val" style={{ color: "#5DCAA5" }}>
                  {approvedCount}
                </span>
                <span className="vis-hs-label">Approved</span>
              </div>

              <div className="vis-hs-div" />

              <div className="vis-hs">
                <span className="vis-hs-val" style={{ color: "#f08080" }}>
                  {rejectedCount}
                </span>
                <span className="vis-hs-label">Rejected</span>
              </div>

              <div className="vis-hs-div" />

              <div className="vis-hs">
                <span className="vis-hs-val" style={{ color: "#fbbf24" }}>
                  {arrivedCount}
                </span>
                <span className="vis-hs-label">Inside</span>
              </div>

              <div className="vis-hs-div" />

              <div className="vis-hs">
                <span className="vis-hs-val">{visitors.length}</span>
                <span className="vis-hs-label">Total</span>
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

        <div className="vis-filters">
          {["all", "pending", "approved", "arrived", "exited", "rejected"].map((f) => (
            <button
              key={f}
              className={`vis-filter-btn ${filter === f ? "active" : ""}`}
              onClick={() => setFilter(f)}
            >
              {f.charAt(0).toUpperCase() + f.slice(1)}
              {f === "pending" && pendingCount > 0 && <span className="vis-filter-dot" />}
            </button>
          ))}
        </div>

        <div className="vis-list">
          {loading ? (
            <div className="vis-empty">Loading visitor requests...</div>
          ) : error ? (
            <div className="vis-empty">{error}</div>
          ) : filtered.length === 0 ? (
            <div className="vis-empty">No visitor requests found</div>
          ) : (
            filtered.map((visitor) => {
              const config = statusConfig[visitor.status] || statusConfig.pending;

              return (
                <div key={visitor.id} className={`vis-card ${visitor.status}`}>
                  <div className="vis-card-left">
                    <div className="vis-avatar">{getInitials(visitor.visitorName)}</div>

                    <div className="vis-info">
                      <div className="vis-name">{visitor.visitorName}</div>
                      <div className="vis-phone">{visitor.visitorPhone}</div>
                      <div className="vis-phone">{visitor.visitorEmail}</div>
                    </div>
                  </div>

                  <div className="vis-card-middle">
                    <div className="vis-detail-row">
                      <span>
                        Requested by <strong>{visitor.requestedBy.name}</strong> — Unit{" "}
                        {visitor.requestedBy.unit}
                      </span>
                    </div>

                    <div className="vis-detail-row">
                      <span>
                        Visit window{" "}
                        <strong>
                          {formatDateTime(
                            visitor.visitDate,
                            visitor.startTime,
                            visitor.endTime
                          )}
                        </strong>
                      </span>
                    </div>

                    <div className="vis-detail-row">
                      <span>
                        Purpose: <strong>{visitor.purpose}</strong>
                      </span>
                    </div>

                    <div className="vis-detail-row">
                      <span>Submitted {formatSubmitted(visitor.createdAt)}</span>
                    </div>

                    {visitor.note && <div className="vis-note">{visitor.note}</div>}
                  </div>

                  <div className="vis-card-right">
                    <span
                      className="vis-status-badge"
                      style={{
                        background: config.bg,
                        color: config.color,
                      }}
                    >
                      {config.label}
                    </span>

                    {visitor.status === "pending" && (
                      <div className="vis-action-btns">
                        <button
                          className="vis-reject-btn"
                          onClick={() => handleReject(visitor.id)}
                          disabled={processingId === visitor.id}
                        >
                          Reject
                        </button>

                        <button
                          className="vis-approve-btn"
                          onClick={() => handleApprove(visitor.id)}
                          disabled={processingId === visitor.id}
                        >
                          {processingId === visitor.id ? "Approving..." : "Approve"}
                        </button>
                      </div>
                    )}

                    {visitor.status === "approved" && (
                      <button
                        className="vis-approve-btn"
                        onClick={() => handleArrived(visitor.id)}
                        disabled={processingId === visitor.id}
                      >
                        {processingId === visitor.id ? "Updating..." : "Mark arrived"}
                      </button>
                    )}

                    {visitor.status === "arrived" && (
                      <button
                        className="vis-review-btn"
                        onClick={() => handleExited(visitor.id)}
                        disabled={processingId === visitor.id}
                      >
                        {processingId === visitor.id ? "Updating..." : "Mark exited"}
                      </button>
                    )}
                  </div>
                </div>
              );
            })
          )}
        </div>
      </div>
    </PageWrapper>
  );
};

export default Visitors;