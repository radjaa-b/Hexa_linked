import { useNavigate } from "react-router-dom";
import { clearAuth } from "../../store/authStore";
import useAuth from "../../hooks/useAuth";
import { ROUTES } from "../../constants/routes";
import { ROLES } from "../../constants/roles";
import "./Topbar.css";

// Navigation links per role
// Radja: no action needed here — purely frontend routing
const navLinks = {
  [ROLES.ADMIN]: [
    { label: "Overview",      path: ROUTES.ADMIN_DASHBOARD },
    { label: "Residents",     path: ROUTES.ADMIN_RESIDENTS },
    { label: "Staff",         path: ROUTES.ADMIN_STAFF },
    { label: "Access log",    path: ROUTES.ADMIN_ACCESS_LOG },
    { label: "Communication",      path: ROUTES.ADMIN_MESSAGES },
    { label: "Consumption",   path: ROUTES.ADMIN_CONSUMPTION },
    { label: "Alerts", path: ROUTES.ADMIN_ALERTS },
  ],
  [ROLES.SECURITY]: [
    { label: "Gate control",  path: ROUTES.SECURITY_GATE },
    { label: "Visitors",      path: ROUTES.SECURITY_VISITORS },
    { label: "Surveillance",  path: ROUTES.SECURITY_ALERTS },
    { label: "Incidents",     path: ROUTES.SECURITY_INCIDENTS },
  ],
  [ROLES.TECHNICIAN]: [
  { label: "Maintenance", path: ROUTES.TECH_MAINTENANCE },
  { label: "Energy",      path: ROUTES.TECH_ENERGY },
  { label: "IoT Devices", path: ROUTES.TECH_IOT         },
],
};

const Topbar = ({ currentPath }) => {
  const navigate  = useNavigate();
  const { user, role } = useAuth();

  const links = navLinks[role] || [];

  const initials = user?.name
    ? user.name.split(" ").map((n) => n[0]).join("").toUpperCase().slice(0, 2)
    : "??";

  const handleLogout = () => {
    clearAuth();
    navigate(ROUTES.LOGIN);
  };

  return (
    <nav className="topbar">

      {/* Logo */}
      <div className="tb-logo" onClick={() => navigate(links[0]?.path || ROUTES.LOGIN)}>
        <svg width="22" height="22" viewBox="0 0 36 36" fill="none">
          <path d="M18 2L32 10V26L18 34L4 26V10L18 2Z"
            fill="white" fillOpacity="0.15"/>
          <path d="M18 2L32 10V26L18 34L4 26V10L18 2Z"
            stroke="white" strokeWidth="1.2"/>
          <path d="M18 8L26 13V23L18 28L10 23V13L18 8Z"
            fill="white" fillOpacity="0.25"/>
          <circle cx="18" cy="18" r="3.5" fill="white"/>
        </svg>
        <span className="tb-logo-name">HexaGate</span>
      </div>

      {/* Nav links — role aware */}
      <div className="tb-links">
        {links.map((link) => (
          <button
            key={link.path}
            className={`tb-link ${currentPath === link.path ? "active" : ""}`}
            onClick={() => navigate(link.path)}
          >
            {link.label}
          </button>
        ))}
      </div>

      {/* Right side */}
      <div className="tb-right">

        {/* Notification bell */}
        {/* Radja: wire up unread count from GET /notifications */}
        <div className="tb-bell">
          <svg width="15" height="15" viewBox="0 0 24 24" fill="none"
            stroke="rgba(255,255,255,0.5)" strokeWidth="2">
            <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/>
            <path d="M13.73 21a2 2 0 0 1-3.46 0"/>
          </svg>
          {/* Show dot when there are unread notifications */}
          <span className="tb-notif-dot" />
        </div>

        {/* User + logout */}
        <div className="tb-user">
          <div className="tb-avatar">{initials}</div>
          <span className="tb-username">{user?.name || "User"}</span>
        </div>

        <button className="tb-logout" onClick={handleLogout}>
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none"
            stroke="rgba(255,255,255,0.4)" strokeWidth="2">
            <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/>
            <polyline points="16 17 21 12 16 7"/>
            <line x1="21" y1="12" x2="9" y2="12"/>
          </svg>
          Log out
        </button>

      </div>
    </nav>
  );
};

export default Topbar;