import { useState, useEffect } from "react";
import { useNavigate, useSearchParams } from "react-router-dom";
import { activateAccountApi } from "../../api/auth.api";
import { ROUTES } from "../../constants/routes";
import "./ActivateAccount.css";

// ============================================================
// Radja: this page is shown when a new user clicks the
// activation link sent to their email.
//
// The link format is:
//   https://yourapp.com/activate?token=ABC123&name=Ahmed&role=admin
//
// Backend needs:
//   POST /auth/activate
//   body: { token: string, password: string }
//   → validates token, sets password, marks account active
//   → returns { success: true, user: { name, role } }
//
// The token expires after 24 hours.
// If token is invalid or expired, return 400 with a message.
// ============================================================

const ActivateAccount = () => {
  const navigate       = useNavigate();
  const [searchParams] = useSearchParams();

  const token = searchParams.get("token");
  const name  = searchParams.get("name")  || "there";
  const role  = searchParams.get("role")  || "";

  const [password,  setPassword]  = useState("");
  const [confirm,   setConfirm]   = useState("");
  const [showPass,  setShowPass]  = useState(false);
  const [showConf,  setShowConf]  = useState(false);
  const [loading,   setLoading]   = useState(false);
  const [error,     setError]     = useState("");
  const [success,   setSuccess]   = useState(false);
  const [strength,  setStrength]  = useState(0);

  // Password strength checker
  useEffect(() => {
    let score = 0;
    if (password.length >= 8)              score++;
    if (/[A-Z]/.test(password))           score++;
    if (/[0-9]/.test(password))           score++;
    if (/[^A-Za-z0-9]/.test(password))    score++;
    setStrength(score);
  }, [password]);

  const strengthLabel = ["", "Weak", "Fair", "Good", "Strong"];
  const strengthColor = ["", "#e74c3c", "#e67e22", "#EF9F27", "#1D9E75"];

  const roleLabel = {
    admin:      "Administrator",
    security:   "Security Agent",
    technician: "Technician",
    resident:   "Resident",
  }[role] || "";

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");

    if (password.length < 8) {
      setError("Password must be at least 8 characters.");
      return;
    }
    if (password !== confirm) {
      setError("Passwords do not match.");
      return;
    }
    if (strength < 2) {
      setError("Please choose a stronger password.");
      return;
    }
    if (!token) {
      setError("Invalid activation link. Please contact your administrator.");
      return;
    }

    setLoading(true);
    try {
      // Radja: POST /auth/activate { token, password }
      await activateAccountApi(token, password);
      setSuccess(true);
      // Redirect to login after 3 seconds
      setTimeout(() => navigate(ROUTES.LOGIN), 3000);
    } catch (err) {
      setError(
        err.response?.data?.message ||
        "This activation link is invalid or has expired. Please contact your administrator."
      );
    } finally {
      setLoading(false);
    }
  };

  // No token in URL
  if (!token) {
    return (
      <div className="act-page">
        <div className="act-left">
          <div className="act-left-hex">
            <svg width="160" height="140" viewBox="0 0 160 140" fill="none">
              <path d="M80 8L144 44V116L80 152L16 116V44L80 8Z" stroke="white" strokeWidth="1" opacity="0.15"/>
              <path d="M80 32L120 55V101L80 124L40 101V55L80 32Z" stroke="white" strokeWidth="0.8" opacity="0.1"/>
            </svg>
          </div>
          <div className="act-left-content">
            <div className="act-left-tag">Account activation</div>
            <h1>HexaGate</h1>
            <p>Secure residential community management</p>
          </div>
          <div className="act-wave" />
        </div>
        <div className="act-right">
          <div className="act-logo-row">
            <svg width="36" height="36" viewBox="0 0 36 36" fill="none">
              <path d="M18 2L32 10V26L18 34L4 26V10L18 2Z" fill="#1a3a1a" fillOpacity="0.15"/>
              <path d="M18 2L32 10V26L18 34L4 26V10L18 2Z" stroke="#1a3a1a" strokeWidth="1.2"/>
              <path d="M18 8L26 13V23L18 28L10 23V13L18 8Z" fill="#1a3a1a" fillOpacity="0.3"/>
              <circle cx="18" cy="18" r="3.5" fill="#1a3a1a"/>
            </svg>
            <span className="act-app-name">HexaGate</span>
          </div>
          <div className="act-invalid">
            <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="#e74c3c" strokeWidth="1.5">
              <circle cx="12" cy="12" r="10"/>
              <line x1="12" y1="8" x2="12" y2="12"/>
              <line x1="12" y1="16" x2="12.01" y2="16"/>
            </svg>
            <h2>Invalid link</h2>
            <p>This activation link is invalid or missing. Please contact your administrator to get a new one.</p>
            <button className="act-login-btn" onClick={() => navigate(ROUTES.LOGIN)}>
              Back to login
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="act-page">

      {/* ── Left panel ── */}
      <div className="act-left">
        <div className="act-left-hex">
          <svg width="160" height="140" viewBox="0 0 160 140" fill="none">
            <path d="M80 8L144 44V116L80 152L16 116V44L80 8Z"
              stroke="white" strokeWidth="1" opacity="0.15"/>
            <path d="M80 32L120 55V101L80 124L40 101V55L80 32Z"
              stroke="white" strokeWidth="0.8" opacity="0.1"/>
          </svg>
        </div>
        <div className="act-left-content">
          <div className="act-left-tag">Account activation</div>
          <h1>Welcome to<br />HexaGate</h1>
          <p>Your account has been created by the residence administration. Set your password to get started.</p>
        </div>
        <div className="act-wave" />
      </div>

      {/* ── Right panel ── */}
      <div className="act-right">

        <div className="act-logo-row">
          <svg width="36" height="36" viewBox="0 0 36 36" fill="none">
            <path d="M18 2L32 10V26L18 34L4 26V10L18 2Z"
              fill="#1a3a1a" fillOpacity="0.15"/>
            <path d="M18 2L32 10V26L18 34L4 26V10L18 2Z"
              stroke="#1a3a1a" strokeWidth="1.2"/>
            <path d="M18 8L26 13V23L18 28L10 23V13L18 8Z"
              fill="#1a3a1a" fillOpacity="0.3"/>
            <circle cx="18" cy="18" r="3.5" fill="#1a3a1a"/>
          </svg>
          <span className="act-app-name">HexaGate</span>
        </div>

        {success ? (
          /* ── Success state ── */
          <div className="act-success">
            <div className="act-success-icon">
              <svg width="40" height="40" viewBox="0 0 24 24" fill="none"
                stroke="#1D9E75" strokeWidth="1.5">
                <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/>
                <polyline points="22 4 12 14.01 9 11.01"/>
              </svg>
            </div>
            <h2>Password set!</h2>
            <p>Your account is now active. Redirecting you to login in a few seconds...</p>
            <button
              className="act-submit-btn"
              onClick={() => navigate(ROUTES.LOGIN)}
            >
              Go to login now
            </button>
          </div>
        ) : (
          /* ── Form ── */
          <>
            {/* Account info banner */}
            <div className="act-banner">
              <div className="act-banner-avatar">
                {name.split(" ").map(n => n[0]).join("").toUpperCase().slice(0, 2)}
              </div>
              <div className="act-banner-info">
                <div className="act-banner-title">
                  Account created successfully
                </div>
                <div className="act-banner-name">
                  {name}
                  {roleLabel && <span className="act-role-badge">{roleLabel}</span>}
                </div>
              </div>
              <div className="act-banner-check">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none"
                  stroke="#1D9E75" strokeWidth="2">
                  <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/>
                  <polyline points="22 4 12 14.01 9 11.01"/>
                </svg>
              </div>
            </div>

            <h2 className="act-title">Set your password</h2>
            <p className="act-subtitle">
              Choose a strong password to secure your account.
              You will use it every time you log in.
            </p>

            <form onSubmit={handleSubmit} className="act-form">

              {/* Password field */}
              <label className="act-label">New password</label>
              <div className="act-input-wrap">
                <input
                  type={showPass ? "text" : "password"}
                  placeholder="Minimum 8 characters"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="act-input"
                  required
                />
                <button
                  type="button"
                  className="act-eye"
                  onClick={() => setShowPass(!showPass)}
                >
                  {showPass ? (
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none"
                      stroke="#aaa" strokeWidth="2">
                      <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94"/>
                      <path d="M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19"/>
                      <line x1="1" y1="1" x2="23" y2="23"/>
                    </svg>
                  ) : (
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none"
                      stroke="#aaa" strokeWidth="2">
                      <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
                      <circle cx="12" cy="12" r="3"/>
                    </svg>
                  )}
                </button>
              </div>

              {/* Strength indicator */}
              {password.length > 0 && (
                <div className="act-strength">
                  <div className="act-strength-bars">
                    {[1, 2, 3, 4].map((i) => (
                      <div
                        key={i}
                        className="act-strength-bar"
                        style={{
                          background: i <= strength
                            ? strengthColor[strength]
                            : "#e0e0da",
                        }}
                      />
                    ))}
                  </div>
                  <span
                    className="act-strength-label"
                    style={{ color: strengthColor[strength] }}
                  >
                    {strengthLabel[strength]}
                  </span>
                </div>
              )}

              {/* Confirm password */}
              <label className="act-label" style={{ marginTop: "12px" }}>
                Confirm password
              </label>
              <div className="act-input-wrap">
                <input
                  type={showConf ? "text" : "password"}
                  placeholder="Repeat your password"
                  value={confirm}
                  onChange={(e) => setConfirm(e.target.value)}
                  className={`act-input ${
                    confirm && confirm !== password ? "mismatch" : ""
                  } ${
                    confirm && confirm === password && confirm.length > 0 ? "match" : ""
                  }`}
                  required
                />
                <button
                  type="button"
                  className="act-eye"
                  onClick={() => setShowConf(!showConf)}
                >
                  {showConf ? (
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none"
                      stroke="#aaa" strokeWidth="2">
                      <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94"/>
                      <path d="M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19"/>
                      <line x1="1" y1="1" x2="23" y2="23"/>
                    </svg>
                  ) : (
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none"
                      stroke="#aaa" strokeWidth="2">
                      <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
                      <circle cx="12" cy="12" r="3"/>
                    </svg>
                  )}
                </button>
              </div>

              {/* Match indicator */}
              {confirm.length > 0 && (
                <p className={`act-match-msg ${confirm === password ? "ok" : "no"}`}>
                  {confirm === password ? "✓ Passwords match" : "✗ Passwords do not match"}
                </p>
              )}

              {/* Requirements */}
              <div className="act-requirements">
                <div className={`act-req ${password.length >= 8 ? "met" : ""}`}>
                  {password.length >= 8 ? "✓" : "○"} At least 8 characters
                </div>
                <div className={`act-req ${/[A-Z]/.test(password) ? "met" : ""}`}>
                  {/[A-Z]/.test(password) ? "✓" : "○"} One uppercase letter
                </div>
                <div className={`act-req ${/[0-9]/.test(password) ? "met" : ""}`}>
                  {/[0-9]/.test(password) ? "✓" : "○"} One number
                </div>
              </div>

              {/* Error */}
              {error && <p className="act-error">{error}</p>}

              {/* Submit */}
              <button
                type="submit"
                className="act-submit-btn"
                disabled={loading}
              >
                {loading ? "Setting password..." : "Set password & activate account"}
              </button>
            </form>
          </>
        )}

        <p className="act-footer">
          HexaGate · Secure Residential Platform
        </p>
      </div>
    </div>
  );
};

export default ActivateAccount;