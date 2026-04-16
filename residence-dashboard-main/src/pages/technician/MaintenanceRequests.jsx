import { useState } from "react";
import PageWrapper from "../../components/layout/PageWrapper";
import "./MaintenanceRequests.css";
import useAuth from "../../hooks/useAuth";

const getGreeting = () => {
  const h = new Date().getHours();
  if (h < 12) return "morning";
  if (h < 18) return "afternoon";
  return "evening";
};
// ============================================================
// Radja: this page uses:
//   GET   /technician/maintenance?status=pending|in_progress|completed
//   PATCH /technician/maintenance/:id/status
//         body: { status: "in_progress"|"completed", note: string }
//
// After status update → send push notification to resident mobile app
//
// Expected shape:
// {
//   id: "uuid",
//   title: "string",
//   description: "string",
//   category: "electrical"|"plumbing"|"general"|"other",
//   priority: "low"|"medium"|"high",
//   status: "pending"|"in_progress"|"completed",
//   submittedBy: { id, name, unit },
//   submittedAt: "timestamp",
//   photos: ["url1", "url2"],
//   notes: "string or null"
// }
// ============================================================

const mockRequests = [
  { id: "1", title: "Broken hallway light",   description: "The light in the hallway near unit A-13 has been broken for 3 days. It is very dark at night and residents are complaining.", category: "electrical", priority: "medium", status: "pending",     submittedBy: { name: "Ahmed Benali",  unit: "A-12" }, submittedAt: "2026-03-29T08:00:00Z", notes: null },
  { id: "2", title: "Water leak under sink",   description: "There is a water leak under the kitchen sink in my unit. Water is dripping constantly and causing damage to the cabinet below.", category: "plumbing",   priority: "high",   status: "pending",     submittedBy: { name: "Karima Ouali",  unit: "B-04" }, submittedAt: "2026-03-29T09:30:00Z", notes: null },
  { id: "3", title: "Door lock malfunction",   description: "The main door lock is not working properly. It sometimes gets stuck and I cannot enter my unit without struggling for several minutes.", category: "general",    priority: "high",   status: "in_progress", submittedBy: { name: "Sara Bensaid",  unit: "A-03" }, submittedAt: "2026-03-28T14:00:00Z", notes: "Ordered replacement lock, will install tomorrow." },
  { id: "4", title: "Elevator strange noise",  description: "The elevator in building C is making a loud grinding noise every time it moves. It feels unsafe to use.", category: "general",    priority: "high",   status: "in_progress", submittedBy: { name: "Youcef Amrani", unit: "C-07" }, submittedAt: "2026-03-28T10:00:00Z", notes: "Technician inspected — cable tension adjustment needed." },
  { id: "5", title: "AC not cooling",          description: "The air conditioning unit in the living room stopped working. It turns on but does not cool the room at all.", category: "electrical", priority: "medium", status: "pending",     submittedBy: { name: "Mourad Kaci",   unit: "B-09" }, submittedAt: "2026-03-27T16:00:00Z", notes: null },
  { id: "6", title: "Broken window handle",    description: "The handle on the bedroom window is broken and the window cannot be closed properly.", category: "general",    priority: "low",    status: "completed",   submittedBy: { name: "Ahmed Benali",  unit: "A-12" }, submittedAt: "2026-03-26T11:00:00Z", notes: "Replaced window handle. Resident confirmed fixed." },
];

// Category badges — dark adapted
const categoryConfig = {
  electrical: { label: "Electrical", bg: "rgba(133,79,11,0.2)",   color: "#EF9F27" },
  plumbing:   { label: "Plumbing",   bg: "rgba(24,95,165,0.2)",   color: "#85B7EB" },
  general:    { label: "General",    bg: "rgba(255,255,255,0.07)", color: "rgba(255,255,255,0.4)" },
  other:      { label: "Other",      bg: "rgba(255,255,255,0.07)", color: "rgba(255,255,255,0.3)" },
};

const priorityConfig = {
  high:   { label: "High",   bg: "rgba(231,76,60,0.15)",  color: "#f08080" },
  medium: { label: "Medium", bg: "rgba(230,126,34,0.15)", color: "#e67e22" },
  low:    { label: "Low",    bg: "rgba(255,255,255,0.07)", color: "rgba(255,255,255,0.35)" },
};

const statusConfig = {
  pending:     { label: "Pending",     bg: "rgba(24,95,165,0.2)",   color: "#85B7EB" },
  in_progress: { label: "In progress", bg: "rgba(239,159,39,0.15)", color: "#EF9F27" },
  completed:   { label: "Completed",   bg: "rgba(29,158,117,0.15)", color: "#5DCAA5" },
};

const formatTime = (iso) => {
  const d = new Date(iso);
  return d.toLocaleDateString("en-GB", { day: "numeric", month: "short" }) +
    " · " + d.toLocaleTimeString("en-GB", { hour: "2-digit", minute: "2-digit" });
};

const getInitials = (name) =>
  name.split(" ").map((n) => n[0]).join("").toUpperCase().slice(0, 2);

const MaintenanceRequests = () => {
  const { user } = useAuth();
  const [requests,   setRequests]   = useState(mockRequests);
  const [filter,     setFilter]     = useState("all");
  const [actionId,   setActionId]   = useState(null);
  const [note,       setNote]       = useState("");
  const [noteError,  setNoteError]  = useState("");
  const [processing, setProcessing] = useState(false);

  const pendingCount    = requests.filter((r) => r.status === "pending").length;
  const inProgressCount = requests.filter((r) => r.status === "in_progress").length;
  const completedCount  = requests.filter((r) => r.status === "completed").length;
  const highCount       = requests.filter((r) => r.priority === "high" && r.status !== "completed").length;

  const filtered = requests.filter((r) =>
    filter === "all" ? true : r.status === filter
  );

  const handleAction = (id) => {
    setActionId(id);
    setNote("");
    setNoteError("");
  };

  const handleStatusUpdate = (newStatus) => {
    if (!note.trim()) {
      setNoteError("Please add a note before updating.");
      return;
    }
    setProcessing(true);
    // Radja: PATCH /technician/maintenance/:id/status { status: newStatus, note }
    // After update → send push notification to resident mobile app
    setRequests((prev) =>
      prev.map((r) =>
        r.id === actionId ? { ...r, status: newStatus, notes: note } : r
      )
    );
    setActionId(null);
    setNote("");
    setProcessing(false);
  };

  return (
    <PageWrapper>
      <div className="maint-layout">

        {/* ── Hero ── */}
<div className="maint-hero">
  <div className="maint-hero-hex">
    <svg width="160" height="140" viewBox="0 0 160 140" fill="none">
      <path d="M80 8L144 44V116L80 152L16 116V44L80 8Z"
        stroke="white" strokeWidth="1" opacity="0.15"/>
      <path d="M80 32L120 55V101L80 124L40 101V55L80 32Z"
        stroke="white" strokeWidth="0.8" opacity="0.1"/>
    </svg>
  </div>
  <div className="maint-hero-content">
    <div className="maint-hero-left">
      <div className="maint-hero-tag">
        {new Date().toLocaleDateString("en-GB", {
          weekday: "long", year: "numeric",
          month: "long", day: "numeric"
        })}
      </div>
      <div className="maint-hero-greeting">
        Good {getGreeting()},<br />{user?.name || "Technician"}
      </div>
      <div className="maint-hero-sub">
        {pendingCount > 0
          ? `You have ${pendingCount} pending request${pendingCount > 1 ? "s" : ""} waiting for your attention.`
          : "All caught up — no pending requests!"}
      </div>
    </div>
    <div className="maint-hero-stats">
      <div className="maint-stat-card">
        <span className="maint-stat-val" style={{ color: "#85B7EB" }}>{pendingCount}</span>
        <span className="maint-stat-label">Pending</span>
      </div>
      <div className="maint-stat-card">
        <span className="maint-stat-val" style={{ color: "#EF9F27" }}>{inProgressCount}</span>
        <span className="maint-stat-label">In progress</span>
      </div>
      <div className="maint-stat-card">
        <span className="maint-stat-val" style={{ color: "#5DCAA5" }}>{completedCount}</span>
        <span className="maint-stat-label">Completed</span>
      </div>
      <div className="maint-stat-card highlight">
        <span className="maint-stat-val" style={{ color: "#f08080" }}>{highCount}</span>
        <span className="maint-stat-label">High priority</span>
      </div>
    </div>
  </div>
</div>

        {/* ── Filters ── */}
        <div className="maint-filters">
          {["all", "pending", "in_progress", "completed"].map((f) => (
            <button
              key={f}
              className={`maint-filter-btn ${filter === f ? "active" : ""}`}
              onClick={() => setFilter(f)}
            >
              {f === "in_progress" ? "In progress" :
               f.charAt(0).toUpperCase() + f.slice(1)}
              {f === "pending" && pendingCount > 0 && (
                <span className="maint-filter-dot" />
              )}
            </button>
          ))}
        </div>

        {/* ── Requests list ── */}
        <div className="maint-list">
          {filtered.length === 0 ? (
            <div className="maint-empty">No requests found</div>
          ) : (
            filtered.map((req) => (
              <div
                key={req.id}
                className={`maint-card ${req.status} ${req.priority}`}
              >
                {/* Top row */}
                <div className="maint-card-top">
                  <div className="maint-card-left">
                    <div className="maint-card-title">{req.title}</div>
                    <div className="maint-card-badges">
                      <span
                        className="maint-badge"
                        style={{
                          background: categoryConfig[req.category].bg,
                          color: categoryConfig[req.category].color,
                        }}
                      >
                        {categoryConfig[req.category].label}
                      </span>
                      <span
                        className="maint-badge"
                        style={{
                          background: priorityConfig[req.priority].bg,
                          color: priorityConfig[req.priority].color,
                        }}
                      >
                        {priorityConfig[req.priority].label}
                      </span>
                      <span
                        className="maint-badge"
                        style={{
                          background: statusConfig[req.status].bg,
                          color: statusConfig[req.status].color,
                        }}
                      >
                        {statusConfig[req.status].label}
                      </span>
                    </div>
                  </div>

                  {/* Resident info */}
                  <div className="maint-resident">
                    <div className="maint-resident-avatar">
                      {getInitials(req.submittedBy.name)}
                    </div>
                    <div className="maint-resident-info">
                      <div className="maint-resident-name">
                        {req.submittedBy.name}
                      </div>
                      <div className="maint-resident-unit">
                        Unit {req.submittedBy.unit}
                      </div>
                    </div>
                  </div>
                </div>

                {/* Description */}
                <div className="maint-desc">{req.description}</div>

                {/* Note if exists */}
                {req.notes && (
                  <div className="maint-note">
                    <svg width="11" height="11" viewBox="0 0 24 24" fill="none"
                      stroke="currentColor" strokeWidth="2">
                      <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
                      <polyline points="14 2 14 8 20 8"/>
                    </svg>
                    {req.notes}
                  </div>
                )}

                {/* Bottom row */}
                <div className="maint-card-bottom">
                  <div className="maint-time">
                    Submitted {formatTime(req.submittedAt)}
                  </div>

                  {/* Actions */}
                  {req.status !== "completed" && (
                    <>
                      {actionId === req.id ? (
                        <div className="maint-action-form">
                          <textarea
                            className="maint-action-input"
                            placeholder="Add a progress note..."
                            value={note}
                            onChange={(e) => {
                              setNote(e.target.value);
                              setNoteError("");
                            }}
                            rows={2}
                          />
                          {noteError && (
                            <p className="maint-note-error">{noteError}</p>
                          )}
                          <div className="maint-action-btns">
                            <button
                              className="maint-cancel-btn"
                              onClick={() => setActionId(null)}
                            >
                              Cancel
                            </button>
                            {req.status === "pending" && (
                              <button
                                className="maint-progress-btn"
                                onClick={() => handleStatusUpdate("in_progress")}
                                disabled={processing}
                              >
                                Mark in progress
                              </button>
                            )}
                            <button
                              className="maint-complete-btn"
                              onClick={() => handleStatusUpdate("completed")}
                              disabled={processing}
                            >
                              Mark completed
                            </button>
                          </div>
                        </div>
                      ) : (
                        <button
                          className="maint-update-btn"
                          onClick={() => handleAction(req.id)}
                        >
                          Update status
                        </button>
                      )}
                    </>
                  )}
                </div>
              </div>
            ))
          )}
        </div>
      </div>
    </PageWrapper>
  );
};

export default MaintenanceRequests;