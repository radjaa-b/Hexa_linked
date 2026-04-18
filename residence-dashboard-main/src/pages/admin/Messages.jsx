import { useEffect, useState } from "react";
import PageWrapper from "../../components/layout/PageWrapper";
import "./Messages.css";
import {
  getContactRequests,
  getContactRequestById,
  updateContactRequestStatus,
} from "../../services/contactAdminService";
import {
  getAnnouncements,
  createAnnouncement,
  updateAnnouncement,
  deleteAnnouncement,
} from "../../services/announcementService";

const urgencyStyles = {
  urgent: { bg: "#fdf0f0", color: "#e74c3c", label: "Urgent" },
  medium: { bg: "#fdf0e0", color: "#e67e22", label: "Medium" },
  low: { bg: "#f5f5f5", color: "#888", label: "Low" },
};

const statusStyles = {
  pending: { bg: "#E6F1FB", color: "#185FA5", label: "Pending" },
  read: { bg: "#f5f5f5", color: "#888", label: "Read" },
  resolved: { bg: "#edfaf5", color: "#0F6E56", label: "Resolved" },
};

const formatTime = (iso) => {
  if (!iso) return "-";
  const d = new Date(iso);
  return (
    d.toLocaleDateString("en-GB", { day: "numeric", month: "short" }) +
    " · " +
    d.toLocaleTimeString("en-GB", { hour: "2-digit", minute: "2-digit" })
  );
};

const getInitials = (name) =>
  (name || "U")
    .split(" ")
    .map((n) => n[0])
    .join("")
    .toUpperCase()
    .slice(0, 2);

const emptyAnn = { title: "", body: "", pinned: false };

const mapContactRequestSummary = (item) => ({
  id: String(item.id),
  resident: {
    name: item.sender_username || "Unknown user",
    email: item.sender_email || "",
    role: item.sender_role || "",
    unit: "-",
  },
  subject: item.subject || "No subject",
  body: "",
  urgency: (item.urgency || "low").toLowerCase(),
  status: (item.status || "pending").toLowerCase(),
  sentAt: item.created_at || "",
  updatedAt: item.updated_at || "",
});

const mapContactRequestDetails = (item) => ({
  id: String(item.id),
  resident: {
    name: item.sender_username || "Unknown user",
    email: item.sender_email || "",
    role: item.sender_role || "",
    unit: "-",
  },
  subject: item.subject || "No subject",
  body: item.message || "",
  urgency: (item.urgency || "low").toLowerCase(),
  status: (item.status || "pending").toLowerCase(),
  sentAt: item.created_at || "",
  updatedAt: item.updated_at || "",
});

const Communication = () => {
  const storedUserRaw = localStorage.getItem("user");

  let storedUser = null;
  try {
    storedUser = storedUserRaw ? JSON.parse(storedUserRaw) : null;
  } catch (error) {
    console.error("Failed to parse stored user:", error);
  }

  const currentUserId =
    localStorage.getItem("user_id") ||
    localStorage.getItem("id") ||
    storedUser?.id ||
    "";

  const currentUserRole =
    localStorage.getItem("role") ||
    localStorage.getItem("user_role") ||
    storedUser?.role ||
    "";

  console.log("current user debug:", {
    currentUserId,
    currentUserRole,
    storedUser,
  });

  // ── Announcements state ──
  const [announcements, setAnnouncements] = useState([]);
  const [loadingAnnouncements, setLoadingAnnouncements] = useState(true);
  const [annForm, setAnnForm] = useState(emptyAnn);
  const [editAnnId, setEditAnnId] = useState(null);
  const [annError, setAnnError] = useState("");
  const [showAnnForm, setShowAnnForm] = useState(false);

  // ── Contact requests state ──
  const [messages, setMessages] = useState([]);
  const [selected, setSelected] = useState(null);
  const [filter, setFilter] = useState("all");
  const [loadingMessages, setLoadingMessages] = useState(true);
  const [messagesError, setMessagesError] = useState("");
  const [loadingDetails, setLoadingDetails] = useState(false);
  const [updatingStatus, setUpdatingStatus] = useState(false);

  const pendingCount = messages.filter((m) => m.status === "pending").length;
  const filtered = messages.filter((m) =>
    filter === "all" ? true : m.status === filter
  );

  const loadAnnouncements = async () => {
    try {
      setLoadingAnnouncements(true);

      const data = await getAnnouncements();

      const normalized = Array.isArray(data)
        ? data.map((item) => ({
            id: String(item.id),
            title: item.title,
            body: item.content,
            postedAt: item.created_at,
            updatedAt: item.updated_at,
            authorId: String(item.author_user_id),
            authorName: item.author_username || "Unknown user",
            authorRole: item.author_role || "",
            pinned: false,
          }))
        : [];

      setAnnouncements(normalized);
    } catch (err) {
      console.error("Failed to load announcements:", err);
      setAnnError("Failed to load announcements.");
    } finally {
      setLoadingAnnouncements(false);
    }
  };

  const loadContactRequests = async (silent = false) => {
    try {
      if (!silent) {
        setLoadingMessages(true);
      }

      setMessagesError("");

      const data = await getContactRequests();

      const normalized = Array.isArray(data)
        ? data.map(mapContactRequestSummary)
        : [];

      setMessages(normalized);
    } catch (error) {
      console.error("Failed to load contact requests:", error);
      setMessagesError("Failed to load contact requests.");
    } finally {
      if (!silent) {
        setLoadingMessages(false);
      }
    }
  };

  useEffect(() => {
    loadAnnouncements();
  }, []);

  useEffect(() => {
    loadContactRequests();

    const interval = setInterval(() => {
      loadContactRequests(true);
    }, 5000);

    return () => clearInterval(interval);
  }, []);

  // ── Announcement handlers ──
  const handleAnnChange = (e) => {
    const val =
      e.target.type === "checkbox" ? e.target.checked : e.target.value;
    setAnnForm({ ...annForm, [e.target.name]: val });
    setAnnError("");
  };

  const handleAnnSubmit = async (e) => {
    e.preventDefault();

    if (!annForm.title.trim() || !annForm.body.trim()) {
      setAnnError("Title and message are required.");
      return;
    }

    try {
      if (editAnnId) {
        await updateAnnouncement(editAnnId, {
          title: annForm.title,
          content: annForm.body,
        });
      } else {
        await createAnnouncement({
          title: annForm.title,
          content: annForm.body,
        });
      }

      await loadAnnouncements();

      setEditAnnId(null);
      setAnnForm(emptyAnn);
      setShowAnnForm(false);
      setAnnError("");
    } catch (err) {
      console.error("Announcement error:", err);
      setAnnError("Operation failed.");
    }
  };

  const handleEditAnn = (ann) => {
    setEditAnnId(ann.id);
    setAnnForm({
      title: ann.title,
      body: ann.body,
      pinned: ann.pinned,
    });
    setShowAnnForm(true);
    setAnnError("");
  };

  const handleDeleteAnn = async (id) => {
    try {
      await deleteAnnouncement(id);
      setAnnouncements((prev) => prev.filter((a) => a.id !== id));

      if (editAnnId === id) {
        setEditAnnId(null);
        setAnnForm(emptyAnn);
        setShowAnnForm(false);
        setAnnError("");
      }
    } catch (err) {
      console.error("Delete failed:", err);
      setAnnError("Delete failed.");
    }
  };

  const handleCancelAnn = () => {
    setEditAnnId(null);
    setAnnForm(emptyAnn);
    setShowAnnForm(false);
    setAnnError("");
  };

  // ── Contact request handlers ──
  const handleSelect = async (msg) => {
    try {
      setLoadingDetails(true);

      const data = await getContactRequestById(msg.id);
      const fullDetails = mapContactRequestDetails(data);

      let finalSelected = fullDetails;

      if (fullDetails.status === "pending") {
        try {
          await updateContactRequestStatus(fullDetails.id, "read");
          finalSelected = { ...fullDetails, status: "read" };

          setMessages((prev) =>
            prev.map((m) =>
              m.id === fullDetails.id ? { ...m, status: "read" } : m
            )
          );
        } catch (statusError) {
          console.error("Failed to mark request as read:", statusError);
        }
      }

      setSelected(finalSelected);
    } catch (error) {
      console.error("Failed to load contact request details:", error);
      alert("Failed to load request details.");
    } finally {
      setLoadingDetails(false);
    }
  };

  const handleResolve = async () => {
    if (!selected) return;

    try {
      setUpdatingStatus(true);

      await updateContactRequestStatus(selected.id, "resolved");

      setMessages((prev) =>
        prev.map((m) =>
          m.id === selected.id ? { ...m, status: "resolved" } : m
        )
      );

      setSelected((prev) =>
        prev ? { ...prev, status: "resolved" } : prev
      );
    } catch (error) {
      console.error("Failed to resolve request:", error);
      alert("Failed to update status.");
    } finally {
      setUpdatingStatus(false);
    }
  };

  return (
    <PageWrapper>
      <div className="comm-layout">
        <div className="msg-hero">
          <div className="msg-hero-hex">
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
            <div className="msg-hero-tag">Admin communication</div>
            <div className="msg-hero-title">
              Communication
              {pendingCount > 0 && (
                <span className="msg-hero-badge">{pendingCount} pending</span>
              )}
            </div>
          </div>
        </div>

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
                  <button
                    type="button"
                    className="ann-cancel-btn"
                    onClick={handleCancelAnn}
                  >
                    Cancel
                  </button>
                  <button type="submit" className="ann-submit-btn">
                    {editAnnId ? "Save changes" : "Post"}
                  </button>
                </div>
              </div>
            </form>
          )}

          <div className="ann-list">
            {loadingAnnouncements ? (
              <div className="ann-empty">Loading announcements...</div>
            ) : announcements.length === 0 ? (
              <div className="ann-empty">No announcements yet</div>
            ) : (
              announcements.map((ann) => {
                const canManageAnnouncement =
                  currentUserRole === "admin" || currentUserId == ann.authorId;

                return (
                  <div
                    key={ann.id}
                    className={`ann-card ${ann.pinned ? "pinned" : ""}`}
                  >
                    <div className="ann-card-top">
                      {ann.pinned && (
                        <span className="ann-pin-badge">Pinned</span>
                      )}

                      {canManageAnnouncement && (
                        <div className="ann-card-actions">
                          <button
                            type="button"
                            className="ann-icon-btn"
                            onClick={() => handleEditAnn(ann)}
                          >
                            <svg
                              width="12"
                              height="12"
                              viewBox="0 0 24 24"
                              fill="none"
                              stroke="currentColor"
                              strokeWidth="2"
                            >
                              <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7" />
                              <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z" />
                            </svg>
                          </button>

                          <button
                            type="button"
                            className="ann-icon-btn delete"
                            onClick={() => handleDeleteAnn(ann.id)}
                          >
                            <svg
                              width="12"
                              height="12"
                              viewBox="0 0 24 24"
                              fill="none"
                              stroke="currentColor"
                              strokeWidth="2"
                            >
                              <polyline points="3 6 5 6 21 6" />
                              <path d="M19 6l-1 14H6L5 6" />
                              <path d="M10 11v6M14 11v6" />
                              <path d="M9 6V4h6v2" />
                            </svg>
                          </button>
                        </div>
                      )}
                    </div>

                    <div className="ann-card-title">{ann.title}</div>
                    <div className="ann-card-body">{ann.body}</div>
                    <div className="ann-card-time">
                      {ann.authorName} · {formatTime(ann.postedAt)}
                    </div>
                  </div>
                );
              })
            )}
          </div>
        </div>

        <div className="msg-body" style={{ flex: 1 }}>
          <div className="msg-left">
            <div className="msg-filters">
              {["all", "pending", "read", "resolved"].map((f) => (
                <button
                  key={f}
                  className={`msg-filter-btn ${filter === f ? "active" : ""}`}
                  onClick={() => setFilter(f)}
                >
                  {f.charAt(0).toUpperCase() + f.slice(1)}
                  {f === "pending" && pendingCount > 0 && (
                    <span className="msg-filter-dot" />
                  )}
                </button>
              ))}
            </div>

            <div className="msg-list">
              {loadingMessages ? (
                <div className="msg-empty">Loading contact requests...</div>
              ) : messagesError ? (
                <div className="msg-empty">{messagesError}</div>
              ) : filtered.length === 0 ? (
                <div className="msg-empty">No contact requests</div>
              ) : (
                filtered.map((msg) => (
                  <div
                    key={msg.id}
                    className={`msg-item ${
                      selected?.id === msg.id ? "active" : ""
                    } ${msg.status === "pending" ? "unread" : ""}`}
                    onClick={() => handleSelect(msg)}
                  >
                    <div className="msg-item-top">
                      <div className="msg-item-avatar">
                        {getInitials(msg.resident.name)}
                      </div>
                      <div className="msg-item-info">
                        <div className="msg-item-name">
                          {msg.resident.name}
                          {msg.status === "pending" && (
                            <span className="msg-unread-dot" />
                          )}
                        </div>
                        <div className="msg-item-unit">
                          {msg.resident.role
                            ? msg.resident.role.replace("_", " ")
                            : "-"}
                        </div>
                      </div>
                      <div className="msg-item-right">
                        <span
                          className="msg-item-urgency"
                          style={{
                            background:
                              urgencyStyles[msg.urgency]?.bg || "#f5f5f5",
                            color: urgencyStyles[msg.urgency]?.color || "#888",
                          }}
                        >
                          {urgencyStyles[msg.urgency]?.label || msg.urgency}
                        </span>
                        <div className="msg-item-time">
                          {formatTime(msg.sentAt)}
                        </div>
                      </div>
                    </div>
                    <div className="msg-item-subject">{msg.subject}</div>
                    <div className="msg-item-preview">
                      {msg.resident.email || "No sender email"}
                    </div>
                  </div>
                ))
              )}
            </div>
          </div>

          {selected ? (
            <div className="msg-right">
              {loadingDetails ? (
                <div className="msg-no-select">Loading request details...</div>
              ) : (
                <>
                  <div className="msg-conv-head">
                    <div className="msg-conv-avatar">
                      {getInitials(selected.resident.name)}
                    </div>
                    <div className="msg-conv-info">
                      <div className="msg-conv-name">{selected.resident.name}</div>
                      <div className="msg-conv-meta">
                        {selected.resident.email || "No email"} ·{" "}
                        {formatTime(selected.sentAt)}
                      </div>
                    </div>
                    <div className="msg-conv-badges">
                      <span
                        className="msg-badge"
                        style={{
                          background:
                            urgencyStyles[selected.urgency]?.bg || "#f5f5f5",
                          color:
                            urgencyStyles[selected.urgency]?.color || "#888",
                        }}
                      >
                        {urgencyStyles[selected.urgency]?.label ||
                          selected.urgency}
                      </span>
                      <span
                        className="msg-badge"
                        style={{
                          background:
                            statusStyles[selected.status]?.bg || "#f5f5f5",
                          color: statusStyles[selected.status]?.color || "#888",
                        }}
                      >
                        {statusStyles[selected.status]?.label || selected.status}
                      </span>
                    </div>
                  </div>

                  <div className="msg-conv-subject">{selected.subject}</div>

                  <div className="msg-thread">
                    <div className="msg-bubble resident">
                      <div className="msg-bubble-body">
                        {selected.body || "No message content."}
                      </div>
                      <div className="msg-bubble-time">
                        Created: {formatTime(selected.sentAt)}
                      </div>
                    </div>
                  </div>

                  <div className="msg-reply-box">
                    <div
                      className="msg-reply-actions"
                      style={{ justifyContent: "flex-end" }}
                    >
                      <button
                        className="msg-resolve-btn"
                        onClick={handleResolve}
                        disabled={
                          selected.status === "resolved" || updatingStatus
                        }
                      >
                        {selected.status === "resolved"
                          ? "Already resolved"
                          : updatingStatus
                          ? "Updating..."
                          : "Mark as resolved"}
                      </button>
                    </div>
                  </div>
                </>
              )}
            </div>
          ) : (
            <div className="msg-right msg-no-select">
              Select a request to view
            </div>
          )}
        </div>
      </div>
    </PageWrapper>
  );
};

export default Communication;