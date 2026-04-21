import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { loginApi } from "../../api/auth.api";
import { saveAuth } from "../../store/authStore";
import { ROUTES } from "../../constants/routes";
import { ROLES } from "../../constants/roles";
import "./Login.css";

const Login = () => {
  const navigate = useNavigate();
 

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [remember, setRemember] = useState(false);
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  const decodeJwtPayload = (token) => {
    try {
      const payload = token.split(".")[1];
      const decoded = JSON.parse(atob(payload));
      return decoded;
    } catch {
      return null;
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");
    setLoading(true);

    try {
      const res = await loginApi(email, password);

      const token = res?.access_token;

      if (!token) {
        setError("No token returned by server.");
        return;
      }

      const payload = decodeJwtPayload(token);

      if (!payload) {
        setError("Failed to decode authentication token.");
      return;
}
      const role = payload.role;
      console.log("ROLE FROM TOKEN:", role);
      const user = {
        id: payload.sub,
        email,
        role,
      };

      if (!role) {
        setError("No role found inside token.");
        return;
      }

      // Save token + decoded role locally
      saveAuth(token, user);

      // Redirect based on role
      if (role === ROLES.ADMIN) {
        navigate(ROUTES.ADMIN_DASHBOARD);
      } else if (role === ROLES.SECURITY) {
        navigate(ROUTES.SECURITY_GATE);
      } else if (role === ROLES.TECHNICIAN) {
        navigate(ROUTES.TECH_MAINTENANCE);
      } else {
        setError("Unauthorized role.");
      }
    } catch (err) {
      setError(
        err?.response?.data?.detail ||
        "Invalid email or password."
      );
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="login-page">
      <div className="login-left">
        <div className="login-hex-grid">
          <svg
            width="100%"
            height="100%"
            viewBox="0 0 300 700"
            preserveAspectRatio="xMidYMid slice"
          >
            <g stroke="white" strokeWidth="0.8" fill="none" opacity="0.12">
              {[0, 1, 2, 3, 4, 5, 6, 7, 8].map((row) =>
                [0, 1, 2, 3].map((col) => {
                  const x = col * 60 + (row % 2 === 0 ? 0 : 30) + 20;
                  const y = row * 65 + 20;
                  const pts = [
                    [x + 15, y],
                    [x + 45, y],
                    [x + 60, y + 26],
                    [x + 45, y + 52],
                    [x + 15, y + 52],
                    [x, y + 26],
                  ]
                    .map((p) => p.join(","))
                    .join(" ");

                  return <polygon key={`${row}-${col}`} points={pts} />;
                })
              )}
            </g>
          </svg>
        </div>

        <div className="login-left-overlay" />

        <div className="login-left-content">
          <div className="login-left-tag">
            <span className="login-dot" />
            Residential Management
          </div>
          <h1>
            Manage your
            <br />
            community smarter
          </h1>
          <p>
            Access control, residents,
            <br />
            maintenance and more — all in one place.
          </p>
        </div>

        <div className="login-wave" />
      </div>

      <div className="login-right">
        <div className="login-logo-row">
          <svg width="36" height="36" viewBox="0 0 36 36" fill="none">
            <path
              d="M18 2L32 10V26L18 34L4 26V10L18 2Z"
              fill="#1a3a1a"
              fillOpacity="0.15"
            />
            <path
              d="M18 2L32 10V26L18 34L4 26V10L18 2Z"
              stroke="#1a3a1a"
              strokeWidth="1.2"
            />
            <path
              d="M18 8L26 13V23L18 28L10 23V13L18 8Z"
              fill="#1a3a1a"
              fillOpacity="0.3"
            />
            <circle cx="18" cy="18" r="3.5" fill="#1a3a1a" />
          </svg>
          <span className="login-app-name">HexaGate</span>
        </div>

        <h2 className="login-title">Welcome back.</h2>
        <p className="login-subtitle">
          Sign in to continue.
          <br />
          Your account is provided by the residence administration.
        </p>

        <form onSubmit={handleSubmit} className="login-form">
          <input
            type="email"
            placeholder="Email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
            className="login-input"
          />

          <input
            type="password"
            placeholder="Password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
            className="login-input"
          />

          <div className="login-row">
            <label className="login-remember">
              <input
                type="checkbox"
                checked={remember}
                onChange={(e) => setRemember(e.target.checked)}
              />
              Remember me
            </label>
            <span className="login-forgot">Forgot password?</span>
          </div>

          {error && <p className="login-error">{error}</p>}

          <button type="submit" className="login-btn" disabled={loading}>
            {loading ? "Signing in..." : "Sign in"}
          </button>
        </form>

        <p className="login-footer">HexaGate · Secure Residential Platform</p>
      </div>
    </div>
  );
};

export default Login;