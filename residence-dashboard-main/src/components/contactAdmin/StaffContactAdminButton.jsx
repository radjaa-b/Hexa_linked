import { useState } from "react";
import useAuth from "../../hooks/useAuth";
import { ROLES } from "../../constants/roles";
import { createContactRequest } from "../../services/contactAdminService";
import "./StaffContactAdminButton.css";

const StaffContactAdminButton = () => {
  const { role } = useAuth();

  const isAllowed = role === ROLES.SECURITY || role === ROLES.TECHNICIAN;

  const [open, setOpen] = useState(false);
  const [urgency, setUrgency] = useState("medium");
  const [subject, setSubject] = useState("");
  const [message, setMessage] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState("");
  const [toast, setToast] = useState("");

  if (!isAllowed) return null;

  const roleLabel =
    role === ROLES.SECURITY ? "Security Agent" : "Technician";

  const resetForm = () => {
    setUrgency("medium");
    setSubject("");
    setMessage("");
    setError("");
  };

  const handleClose = () => {
    setOpen(false);
    resetForm();
  };

  const showToast = (text) => {
    setToast(text);

    setTimeout(() => {
      setToast("");
    }, 3000);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    if (!subject.trim() || !message.trim()) {
      setError("Subject and message are required.");
      return;
    }

    try {
      setSubmitting(true);
      setError("");

      await createContactRequest({
        urgency,
        subject: subject.trim(),
        message: message.trim(),
      });

      setOpen(false);
      resetForm();
      showToast("Request sent to admin successfully.");
    } catch (err) {
      console.error("Failed to send contact admin request:", err);
      setError(
        err.response?.data?.detail ||
          "Failed to send request. Please try again."
      );
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <>
      <button
        className="staff-contact-fab"
        type="button"
        onClick={() => setOpen(true)}
      >
        <span className="staff-contact-fab-icon">💬</span>
        <span>Contact Admin</span>
      </button>

      {toast && <div className="staff-contact-toast">{toast}</div>}

      {open && (
        <div className="staff-contact-overlay" onClick={handleClose}>
          <form
            className={`staff-contact-modal ${
              role === ROLES.SECURITY ? "security" : "technician"
            }`}
            onSubmit={handleSubmit}
            onClick={(e) => e.stopPropagation()}
          >
            <div className="staff-contact-head">
              <div>
                <span className="staff-contact-badge">Staff Request</span>
                <h2>Contact Administrator</h2>
                <p>Submit an internal message directly to the admin.</p>
              </div>

              <button
                type="button"
                className="staff-contact-close"
                onClick={handleClose}
              >
                ×
              </button>
            </div>

            <div className="staff-contact-field">
              <label>Role</label>
              <div className="staff-contact-role">{roleLabel}</div>
            </div>

            <div className="staff-contact-field">
              <label>Urgency</label>
              <div className="staff-urgency-row">
                {["low", "medium", "urgent"].map((level) => (
                  <button
                    key={level}
                    type="button"
                    className={`staff-urgency-btn ${level} ${
  urgency === level ? "active" : ""
}`}
                    onClick={() => setUrgency(level)}
                  >
                    {level.charAt(0).toUpperCase() + level.slice(1)}
                  </button>
                ))}
              </div>
            </div>

            <div className="staff-contact-field">
              <label>Subject</label>
              <input
                value={subject}
                onChange={(e) => setSubject(e.target.value)}
                placeholder="Equipment issue, shift concern..."
              />
            </div>

            <div className="staff-contact-field">
              <label>Message</label>
              <textarea
                value={message}
                onChange={(e) => setMessage(e.target.value)}
                placeholder="Write the details for the administrator..."
                rows={5}
              />
            </div>

            {error && <div className="staff-contact-error">{error}</div>}

            <div className="staff-contact-actions">
              <button
                type="button"
                className="staff-cancel-btn"
                onClick={handleClose}
              >
                Cancel
              </button>

              <button
                type="submit"
                className="staff-submit-btn"
                disabled={submitting}
              >
                {submitting ? "Sending..." : "Send Request"}
              </button>
            </div>
          </form>
        </div>
      )}
    </>
  );
};

export default StaffContactAdminButton;