import { useState } from "react";
import PageWrapper from "../../components/layout/PageWrapper";
import "./Visitors.css";

// ============================================================
// Radja: this page uses:
//   GET   /security/visitors?status=pending|approved|rejected|all
//   PATCH /security/visitors/:id
//         body: { status: "approved"|"rejected", note: string }
//
// After approving or rejecting:
//   → Send push notification to the resident mobile app
//
// Expected visitor request shape:
// {
//   id: "uuid",
//   visitorName: "string",
//   visitorPhone: "string",
//   requestedBy: { id, name, unit },
//   expectedAt: "timestamp",
//   status: "pending"|"approved"|"rejected",
//   note: "string or null",
//   createdAt: "timestamp"
// }
// ============================================================

const mockVisitors = [
  { id: "1", visitorName: "Karim Ouali",    visitorPhone: "+213 550 111 222", requestedBy: { name: "Ahmed Benali",  unit: "A-12" }, expectedAt: "2026-03-29T15:00:00Z", status: "pending",  note: null,                              createdAt: "2026-03-29T08:00:00Z" },
  { id: "2", visitorName: "Sara Meziane",   visitorPhone: "+213 661 333 444", requestedBy: { name: "Karima Ouali",  unit: "B-04" }, expectedAt: "2026-03-29T17:30:00Z", status: "pending",  note: null,                              createdAt: "2026-03-29T09:30:00Z" },
  { id: "3", visitorName: "Hamid Tounsi",   visitorPhone: "+213 770 555 666", requestedBy: { name: "Sara Bensaid",  unit: "A-03" }, expectedAt: "2026-03-30T10:00:00Z", status: "pending",  note: null,                              createdAt: "2026-03-29T10:00:00Z" },
  { id: "4", visitorName: "Nadia Ferhat",   visitorPhone: "+213 555 777 888", requestedBy: { name: "Youcef Amrani", unit: "C-07" }, expectedAt: "2026-03-28T14:00:00Z", status: "approved", note: "Approved — ID verified.",          createdAt: "2026-03-28T09:00:00Z" },
  { id: "5", visitorName: "Unknown person", visitorPhone: "+213 660 999 000", requestedBy: { name: "Ahmed Benali",  unit: "A-12" }, expectedAt: "2026-03-27T11:00:00Z", status: "rejected", note: "Rejected — suspicious request.",   createdAt: "2026-03-27T08:00:00Z" },
];

const statusConfig = {
  pending:  { label: "Pending",  bg: "#E6F1FB", color: "#185FA5" },
  approved: { label: "Approved", bg: "#edfaf5", color: "#0F6E56" },
  rejected: { label: "Rejected", bg: "#fdf0f0", color: "#e74c3c" },
};

const formatDateTime = (iso) => {
  const d = new Date(iso);
  return d.toLocaleDateString("en-GB", { day: "numeric", month: "short" }) +
    " at " + d.toLocaleTimeString("en-GB", { hour: "2-digit", minute: "2-digit" });
};

const getInitials = (name) =>
  name.split(" ").map((n) => n[0]).join("").toUpperCase().slice(0, 2);

const Visitors = () => {
  const [visitors,   setVisitors]   = useState(mockVisitors);
  const [filter,     setFilter]     = useState("all");
  const [actionId,   setActionId]   = useState(null);
  const [note,       setNote]       = useState("");
  const [noteError,  setNoteError]  = useState("");
  const [processing, setProcessing] = useState(false);

  const pendingCount  = visitors.filter((v) => v.status === "pending").length;
  const approvedCount = visitors.filter((v) => v.status === "approved").length;
  const rejectedCount = visitors.filter((v) => v.status === "rejected").length;

  const filtered = visitors.filter((v) =>
    filter === "all" ? true : v.status === filter
  );

  const handleAction = (id) => {
    setActionId(id);
    setNote("");
    setNoteError("");
  };

  const handleDecision = (decision) => {
    if (!note.trim()) {
      setNoteError("Please add a note before confirming.");
      return;
    }
    setProcessing(true);
    // Radja: PATCH /security/visitors/:id { status: decision, note }
    // After this, send push notification to resident mobile app
    setVisitors((prev) =>
      prev.map((v) =>
        v.id === actionId ? { ...v, status: decision, note } : v
      )
    );
    setActionId(null);
    setNote("");
    setProcessing(false);
  };

  return (
    <PageWrapper>
      <div className="vis-layout">

        {/* ── Hero ── */}
        <div className="vis-hero">
          <div className="vis-hero-hex">
            <svg width="160" height="140" viewBox="0 0 160 140" fill="none">
              <path d="M80 8L144 44V116L80 152L16 116V44L80 8Z"
                stroke="white" strokeWidth="1" opacity="0.15"/>
              <path d="M80 32L120 55V101L80 124L40 101V55L80 32Z"
                stroke="white" strokeWidth="0.8" opacity="0.1"/>
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
                <span className="vis-hs-val">{visitors.length}</span>
                <span className="vis-hs-label">Total</span>
              </div>
            </div>
          </div>
        </div>

        {/* ── Filters ── */}
        <div className="vis-filters">
          {["all", "pending", "approved", "rejected"].map((f) => (
            <button
              key={f}
              className={`vis-filter-btn ${filter === f ? "active" : ""}`}
              onClick={() => setFilter(f)}
            >
              {f.charAt(0).toUpperCase() + f.slice(1)}
              {f === "pending" && pendingCount > 0 && (
                <span className="vis-filter-dot" />
              )}
            </button>
          ))}
        </div>

        {/* ── Visitor list ── */}
        <div className="vis-list">
          {filtered.length === 0 ? (
            <div className="vis-empty">No visitor requests found</div>
          ) : (
            filtered.map((visitor) => (
              <div
                key={visitor.id}
                className={`vis-card ${visitor.status}`}
              >
                {/* Left — visitor info */}
                <div className="vis-card-left">
                  <div className="vis-avatar">
                    {getInitials(visitor.visitorName)}
                  </div>
                  <div className="vis-info">
                    <div className="vis-name">{visitor.visitorName}</div>
                    <div className="vis-phone">{visitor.visitorPhone}</div>
                  </div>
                </div>

                {/* Middle — request details */}
                <div className="vis-card-middle">
                  <div className="vis-detail-row">
                    <svg width="11" height="11" viewBox="0 0 24 24" fill="none"
                      stroke="#aaa" strokeWidth="2">
                      <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
                      <circle cx="12" cy="7" r="4"/>
                    </svg>
                    <span>Requested by <strong>{visitor.requestedBy.name}</strong> — Unit {visitor.requestedBy.unit}</span>
                  </div>
                  <div className="vis-detail-row">
                    <svg width="11" height="11" viewBox="0 0 24 24" fill="none"
                      stroke="#aaa" strokeWidth="2">
                      <circle cx="12" cy="12" r="10"/>
                      <polyline points="12 6 12 12 16 14"/>
                    </svg>
                    <span>Expected {formatDateTime(visitor.expectedAt)}</span>
                  </div>
                  <div className="vis-detail-row">
                    <svg width="11" height="11" viewBox="0 0 24 24" fill="none"
                      stroke="#aaa" strokeWidth="2">
                      <circle cx="12" cy="12" r="10"/>
                      <polyline points="12 6 12 12 16 14"/>
                    </svg>
                    <span>Submitted {formatDateTime(visitor.createdAt)}</span>
                  </div>
                  {visitor.note && (
                    <div className="vis-note">
                      {visitor.note}
                    </div>
                  )}
                </div>

                {/* Right — status + action */}
                <div className="vis-card-right">
                  <span
                    className="vis-status-badge"
                    style={{
                      background: statusConfig[visitor.status].bg,
                      color: statusConfig[visitor.status].color,
                    }}
                  >
                    {statusConfig[visitor.status].label}
                  </span>

                  {visitor.status === "pending" && (
                    <>
                      {actionId === visitor.id ? (
                        <div className="vis-action-form">
                          <textarea
                            className="vis-action-input"
                            placeholder="Add a note..."
                            value={note}
                            onChange={(e) => {
                              setNote(e.target.value);
                              setNoteError("");
                            }}
                            rows={2}
                          />
                          {noteError && (
                            <p className="vis-note-error">{noteError}</p>
                          )}
                          <div className="vis-action-btns">
                            <button
                              className="vis-cancel-btn"
                              onClick={() => setActionId(null)}
                            >
                              Cancel
                            </button>
                            <button
                              className="vis-reject-btn"
                              onClick={() => handleDecision("rejected")}
                              disabled={processing}
                            >
                              Reject
                            </button>
                            <button
                              className="vis-approve-btn"
                              onClick={() => handleDecision("approved")}
                              disabled={processing}
                            >
                              Approve
                            </button>
                          </div>
                        </div>
                      ) : (
                        <button
                          className="vis-review-btn"
                          onClick={() => handleAction(visitor.id)}
                        >
                          Review
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

export default Visitors;