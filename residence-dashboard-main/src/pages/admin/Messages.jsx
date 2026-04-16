import { useState } from "react";
import PageWrapper from "../../components/layout/PageWrapper";
import "./Messages.css";

// ============================================================
// Radja: this page combines two features:
//
// 1. ANNOUNCEMENTS (top section)
//    GET    /announcements         — list all
//    POST   /announcements         — create { title, body, pinned }
//    PUT    /announcements/:id     — edit
//    DELETE /announcements/:id     — delete
//    These appear in the resident mobile app feed.
//
// 2. MESSAGES (bottom section)
//    GET   /admin/messages?status= — list tickets from residents
//    POST  /admin/messages/:id/reply  — { body: string }
//    PATCH /admin/messages/:id/status — { status: "read"|"resolved" }
//    Residents submit these from the mobile app contact form.
// ============================================================

const mockAnnouncements = [
  { id: "1", title: "Pool maintenance",        body: "The pool will be closed for maintenance on April 2nd.", pinned: true,  postedAt: "2026-03-28T10:00:00Z" },
  { id: "2", title: "Parking rules reminder",  body: "Please ensure your vehicle is parked in your designated spot only.", pinned: false, postedAt: "2026-03-26T09:00:00Z" },
  { id: "3", title: "Community meeting",       body: "Monthly community meeting on April 5th at 6PM in the main hall.", pinned: false, postedAt: "2026-03-24T14:00:00Z" },
];

const mockMessages = [
  { id: "1", resident: { name: "Ahmed Benali",  unit: "A-12" }, subject: "Noise complaint",      body: "There has been loud noise coming from unit A-13 every night after midnight. It is affecting my sleep and my family's comfort. Please look into this matter as soon as possible.", urgency: "urgent", status: "unread",   sentAt: "2026-03-29T07:30:00Z", replies: [] },
  { id: "2", resident: { name: "Karima Ouali",  unit: "B-04" }, subject: "Water pressure issue", body: "The water pressure in our unit has been very low for the past week. Showering and washing dishes has become very difficult. Could a technician please check the pipes?",          urgency: "medium", status: "unread",   sentAt: "2026-03-28T14:20:00Z", replies: [] },
  { id: "3", resident: { name: "Sara Bensaid",  unit: "A-03" }, subject: "Parking spot occupied",body: "My designated parking spot A-03 has been occupied by an unknown vehicle for 2 days. I have nowhere to park my car. Please resolve this urgently.",                               urgency: "medium", status: "read",     sentAt: "2026-03-27T09:15:00Z", replies: [{ from: "admin", body: "We have notified the security team to look into this immediately.", sentAt: "2026-03-27T10:00:00Z" }] },
  { id: "4", resident: { name: "Youcef Amrani", unit: "C-07" }, subject: "Elevator maintenance", body: "The elevator in building C has been making strange noises for a week. It feels unsafe. Please send a technician to inspect it.",                                                  urgency: "low",    status: "resolved", sentAt: "2026-03-25T11:00:00Z", replies: [{ from: "admin", body: "A technician has been dispatched and will inspect the elevator tomorrow morning.", sentAt: "2026-03-25T12:30:00Z" }] },
];

const urgencyStyles = {
  urgent: { bg: "#fdf0f0", color: "#e74c3c", label: "Urgent" },
  medium: { bg: "#fdf0e0", color: "#e67e22", label: "Medium" },
  low:    { bg: "#f5f5f5", color: "#888",    label: "Low"    },
};

const statusStyles = {
  unread:   { bg: "#E6F1FB", color: "#185FA5", label: "Unread"   },
  read:     { bg: "#f5f5f5", color: "#888",    label: "Read"     },
  resolved: { bg: "#edfaf5", color: "#0F6E56", label: "Resolved" },
};

const formatTime = (iso) => {
  const d = new Date(iso);
  return d.toLocaleDateString("en-GB", { day: "numeric", month: "short" }) +
    " · " + d.toLocaleTimeString("en-GB", { hour: "2-digit", minute: "2-digit" });
};

const getInitials = (name) =>
  name.split(" ").map((n) => n[0]).join("").toUpperCase().slice(0, 2);

const emptyAnn = { title: "", body: "", pinned: false };

const Communication = () => {

  // ── Announcements state ──
  const [announcements, setAnnouncements] = useState(mockAnnouncements);
  const [annForm,       setAnnForm]       = useState(emptyAnn);
  const [editAnnId,     setEditAnnId]     = useState(null);
  const [annError,      setAnnError]      = useState("");
  const [showAnnForm,   setShowAnnForm]   = useState(false);

  // ── Messages state ──
  const [messages,  setMessages]  = useState(mockMessages);
  const [selected,  setSelected]  = useState(mockMessages[0]);
  const [filter,    setFilter]    = useState("all");
  const [reply,     setReply]     = useState("");
  const [sending,   setSending]   = useState(false);

  const unreadCount = messages.filter((m) => m.status === "unread").length;
  const filtered    = messages.filter((m) =>
    filter === "all" ? true : m.status === filter
  );

  // ── Announcement handlers ──
  const handleAnnChange = (e) => {
    const val = e.target.type === "checkbox" ? e.target.checked : e.target.value;
    setAnnForm({ ...annForm, [e.target.name]: val });
    setAnnError("");
  };

  const handleAnnSubmit = (e) => {
    e.preventDefault();
    if (!annForm.title.trim() || !annForm.body.trim()) {
      setAnnError("Title and message are required.");
      return;
    }
    if (editAnnId) {
      // Radja: PUT /announcements/:id
      setAnnouncements((prev) =>
        prev.map((a) => a.id === editAnnId ? { ...a, ...annForm } : a)
      );
      setEditAnnId(null);
    } else {
      // Radja: POST /announcements
      const newAnn = {
        id: String(Date.now()),
        ...annForm,
        postedAt: new Date().toISOString(),
      };
      setAnnouncements((prev) => [newAnn, ...prev]);
    }
    setAnnForm(emptyAnn);
    setShowAnnForm(false);
  };

  const handleEditAnn = (ann) => {
    setEditAnnId(ann.id);
    setAnnForm({ title: ann.title, body: ann.body, pinned: ann.pinned });
    setShowAnnForm(true);
    setAnnError("");
  };

  const handleDeleteAnn = (id) => {
    // Radja: DELETE /announcements/:id
    setAnnouncements((prev) => prev.filter((a) => a.id !== id));
  };

  const handleCancelAnn = () => {
    setEditAnnId(null);
    setAnnForm(emptyAnn);
    setShowAnnForm(false);
    setAnnError("");
  };

  // ── Message handlers ──
  const handleSelect = (msg) => {
    setSelected(msg);
    setReply("");
    if (msg.status === "unread") {
      // Radja: PATCH /admin/messages/:id/status { status: "read" }
      setMessages((prev) =>
        prev.map((m) => m.id === msg.id ? { ...m, status: "read" } : m)
      );
      setSelected({ ...msg, status: "read" });
    }
  };

  const handleReply = () => {
    if (!reply.trim()) return;
    setSending(true);
    // Radja: POST /admin/messages/:id/reply { body: reply }
    const newReply = { from: "admin", body: reply, sentAt: new Date().toISOString() };
    const updated  = { ...selected, replies: [...selected.replies, newReply], status: "read" };
    setMessages((prev) => prev.map((m) => m.id === selected.id ? updated : m));
    setSelected(updated);
    setReply("");
    setSending(false);
  };

  const handleResolve = () => {
    // Radja: PATCH /admin/messages/:id/status { status: "resolved" }
    const updated = { ...selected, status: "resolved" };
    setMessages((prev) => prev.map((m) => m.id === selected.id ? updated : m));
    setSelected(updated);
  };

  return (
    <PageWrapper>
      <div className="comm-layout">

        {/* ── Hero ── */}
        <div className="msg-hero">
          <div className="msg-hero-hex">
            <svg width="160" height="140" viewBox="0 0 160 140" fill="none">
              <path d="M80 8L144 44V116L80 152L16 116V44L80 8Z"
                stroke="white" strokeWidth="1" opacity="0.15"/>
              <path d="M80 32L120 55V101L80 124L40 101V55L80 32Z"
                stroke="white" strokeWidth="0.8" opacity="0.1"/>
            </svg>
          </div>
          <div>
            <div className="msg-hero-tag">Admin communication</div>
            <div className="msg-hero-title">
              Communication
              {unreadCount > 0 && (
                <span className="msg-hero-badge">{unreadCount} unread</span>
              )}
            </div>
          </div>
        </div>

        {/* ── Announcements bar ── */}
        <div className="ann-section">
          <div className="ann-header">
            <div className="ann-header-left">
              <span className="ann-section-title">Announcements</span>
              <span className="ann-count">{announcements.length} posted</span>
            </div>
            {!showAnnForm && (
              <button
                className="ann-add-btn"
                onClick={() => setShowAnnForm(true)}
              >
                + New announcement
              </button>
            )}
          </div>

          {/* Add / edit form */}
          {showAnnForm && (
            <form className="ann-form" onSubmit={handleAnnSubmit}>
              <input
                className="ann-input"
                name="title"
                placeholder="Announcement title..."
                value={annForm.title}
                onChange={handleAnnChange}
              />
              <textarea
                className="ann-textarea"
                name="body"
                placeholder="Write your announcement..."
                value={annForm.body}
                onChange={handleAnnChange}
                rows={2}
              />
              <div className="ann-form-footer">
                <label className="ann-pin-label">
                  <input
                    type="checkbox"
                    name="pinned"
                    checked={annForm.pinned}
                    onChange={handleAnnChange}
                  />
                  Pin this announcement
                </label>
                {annError && <span className="ann-error">{annError}</span>}
                <div className="ann-form-actions">
                  <button type="button" className="ann-cancel-btn" onClick={handleCancelAnn}>Cancel</button>
                  <button type="submit" className="ann-submit-btn">
                    {editAnnId ? "Save changes" : "Post"}
                  </button>
                </div>
              </div>
            </form>
          )}

          {/* Announcements horizontal list */}
          <div className="ann-list">
            {announcements.length === 0 ? (
              <div className="ann-empty">No announcements yet</div>
            ) : (
              announcements.map((ann) => (
                <div key={ann.id} className={`ann-card ${ann.pinned ? "pinned" : ""}`}>
                  <div className="ann-card-top">
                    {ann.pinned && <span className="ann-pin-badge">Pinned</span>}
                    <div className="ann-card-actions">
                      <button className="ann-icon-btn" onClick={() => handleEditAnn(ann)}>
                        <svg width="12" height="12" viewBox="0 0 24 24" fill="none"
                          stroke="currentColor" strokeWidth="2">
                          <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/>
                          <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/>
                        </svg>
                      </button>
                      <button className="ann-icon-btn delete" onClick={() => handleDeleteAnn(ann.id)}>
                        <svg width="12" height="12" viewBox="0 0 24 24" fill="none"
                          stroke="currentColor" strokeWidth="2">
                          <polyline points="3 6 5 6 21 6"/>
                          <path d="M19 6l-1 14H6L5 6"/>
                          <path d="M10 11v6M14 11v6"/>
                          <path d="M9 6V4h6v2"/>
                        </svg>
                      </button>
                    </div>
                  </div>
                  <div className="ann-card-title">{ann.title}</div>
                  <div className="ann-card-body">{ann.body}</div>
                  <div className="ann-card-time">{formatTime(ann.postedAt)}</div>
                </div>
              ))
            )}
          </div>
        </div>

        {/* ── Messages section ── */}
        <div className="msg-body" style={{ flex: 1 }}>

          {/* Left list */}
          <div className="msg-left">
            <div className="msg-filters">
              {["all", "unread", "read", "resolved"].map((f) => (
                <button
                  key={f}
                  className={`msg-filter-btn ${filter === f ? "active" : ""}`}
                  onClick={() => setFilter(f)}
                >
                  {f.charAt(0).toUpperCase() + f.slice(1)}
                  {f === "unread" && unreadCount > 0 && (
                    <span className="msg-filter-dot" />
                  )}
                </button>
              ))}
            </div>

            <div className="msg-list">
              {filtered.length === 0 ? (
                <div className="msg-empty">No messages</div>
              ) : (
                filtered.map((msg) => (
                  <div
                    key={msg.id}
                    className={`msg-item ${selected?.id === msg.id ? "active" : ""} ${msg.status === "unread" ? "unread" : ""}`}
                    onClick={() => handleSelect(msg)}
                  >
                    <div className="msg-item-top">
                      <div className="msg-item-avatar">
                        {getInitials(msg.resident.name)}
                      </div>
                      <div className="msg-item-info">
                        <div className="msg-item-name">
                          {msg.resident.name}
                          {msg.status === "unread" && <span className="msg-unread-dot" />}
                        </div>
                        <div className="msg-item-unit">Unit {msg.resident.unit}</div>
                      </div>
                      <div className="msg-item-right">
                        <span className="msg-item-urgency"
                          style={{ background: urgencyStyles[msg.urgency].bg, color: urgencyStyles[msg.urgency].color }}>
                          {urgencyStyles[msg.urgency].label}
                        </span>
                        <div className="msg-item-time">{formatTime(msg.sentAt)}</div>
                      </div>
                    </div>
                    <div className="msg-item-subject">{msg.subject}</div>
                    <div className="msg-item-preview">{msg.body.slice(0, 70)}...</div>
                  </div>
                ))
              )}
            </div>
          </div>

          {/* Right conversation */}
          {selected ? (
            <div className="msg-right">
              <div className="msg-conv-head">
                <div className="msg-conv-avatar">{getInitials(selected.resident.name)}</div>
                <div className="msg-conv-info">
                  <div className="msg-conv-name">{selected.resident.name}</div>
                  <div className="msg-conv-meta">Unit {selected.resident.unit} · {formatTime(selected.sentAt)}</div>
                </div>
                <div className="msg-conv-badges">
                  <span className="msg-badge"
                    style={{ background: urgencyStyles[selected.urgency].bg, color: urgencyStyles[selected.urgency].color }}>
                    {urgencyStyles[selected.urgency].label}
                  </span>
                  <span className="msg-badge"
                    style={{ background: statusStyles[selected.status].bg, color: statusStyles[selected.status].color }}>
                    {statusStyles[selected.status].label}
                  </span>
                </div>
              </div>
              <div className="msg-conv-subject">{selected.subject}</div>
              <div className="msg-thread">
                <div className="msg-bubble resident">
                  <div className="msg-bubble-body">{selected.body}</div>
                  <div className="msg-bubble-time">{formatTime(selected.sentAt)}</div>
                </div>
                {selected.replies.map((r, i) => (
                  <div key={i} className={`msg-bubble ${r.from === "admin" ? "admin" : "resident"}`}>
                    <div className="msg-bubble-body">{r.body}</div>
                    <div className="msg-bubble-time">{formatTime(r.sentAt)}</div>
                  </div>
                ))}
              </div>
              {selected.status !== "resolved" ? (
                <div className="msg-reply-box">
                  <textarea
                    className="msg-reply-input"
                    placeholder="Type your reply..."
                    value={reply}
                    onChange={(e) => setReply(e.target.value)}
                    rows={3}
                  />
                  <div className="msg-reply-actions">
                    <button className="msg-resolve-btn" onClick={handleResolve}>Mark as resolved</button>
                    <button className="msg-send-btn" onClick={handleReply}
                      disabled={sending || !reply.trim()}>
                      {sending ? "Sending..." : "Send reply"}
                    </button>
                  </div>
                </div>
              ) : (
                <div className="msg-resolved-banner">This conversation has been resolved</div>
              )}
            </div>
          ) : (
            <div className="msg-right msg-no-select">Select a message to view</div>
          )}
        </div>
      </div>
    </PageWrapper>
  );
};

export default Communication;