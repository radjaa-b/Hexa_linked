import { useEffect, useRef, useState } from "react";
import { useNavigate } from "react-router-dom";

import { clearAuth } from "../../store/authStore";
import useAuth from "../../hooks/useAuth";
import { ROUTES } from "../../constants/routes";
import { ROLES } from "../../constants/roles";
import {
  getMyNotifications,
  getUnreadNotificationCount,
  markNotificationAsRead,
} from "../../store/notificationStore";

import "./Topbar.css";

const navLinks = {
  [ROLES.ADMIN]: [
    { label: "Overview", path: ROUTES.ADMIN_DASHBOARD },
    { label: "Residents", path: ROUTES.ADMIN_RESIDENTS },
    { label: "Staff", path: ROUTES.ADMIN_STAFF },
    { label: "Access log", path: ROUTES.ADMIN_ACCESS_LOG },
    { label: "Communication", path: ROUTES.ADMIN_MESSAGES },
    { label: "Consumption", path: ROUTES.ADMIN_CONSUMPTION },
    { label: "Alerts", path: ROUTES.ADMIN_ALERTS },
  ],
  [ROLES.SECURITY]: [
    { label: "Gate control", path: ROUTES.SECURITY_GATE },
    { label: "Visitors", path: ROUTES.SECURITY_VISITORS },
    { label: "Surveillance", path: ROUTES.SECURITY_ALERTS },
    { label: "Incidents", path: ROUTES.SECURITY_INCIDENTS },
    { label: "Numbers", path: ROUTES.SECURITY_NUMBERS },
  ],
  [ROLES.TECHNICIAN]: [
    { label: "Maintenance", path: ROUTES.TECH_MAINTENANCE },
    { label: "Energy", path: ROUTES.TECH_ENERGY },
    { label: "IoT Devices", path: ROUTES.TECH_IOT },
  ],
};

const canReceiveNotifications = (role) =>
  role === ROLES.ADMIN || role === ROLES.SECURITY;

const Topbar = ({ currentPath }) => {
  const navigate = useNavigate();
  const { user, role } = useAuth();

  const [notifications, setNotifications] = useState([]);
  const [unreadCount, setUnreadCount] = useState(0);
  const [isNotifOpen, setIsNotifOpen] = useState(false);

  const notifRef = useRef(null);

  const links = navLinks[role] || [];

  const initials = user?.name
    ? user.name
        .split(" ")
        .map((n) => n[0])
        .join("")
        .toUpperCase()
        .slice(0, 2)
    : "??";

  const loadNotifications = async () => {
    if (!canReceiveNotifications(role)) return;

    try {
      const [notifData, countData] = await Promise.all([
        getMyNotifications(),
        getUnreadNotificationCount(),
      ]);

      setNotifications(notifData);
      setUnreadCount(countData);
    } catch (error) {
      console.error("Failed to load notifications:", error);
    }
  };

  useEffect(() => {
    loadNotifications();

    const interval = setInterval(() => {
      loadNotifications();
    }, 10000);

    return () => clearInterval(interval);
  }, [role]);

  useEffect(() => {
    const handleClickOutside = (event) => {
      if (notifRef.current && !notifRef.current.contains(event.target)) {
        setIsNotifOpen(false);
      }
    };

    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  const handleLogout = () => {
    clearAuth();
    navigate(ROUTES.LOGIN);
  };

  const handleNotificationClick = async (notification) => {
    try {
      if (!notification.is_read) {
        await markNotificationAsRead(notification.id);
        await loadNotifications();
      }

      setIsNotifOpen(false);

      if (role === ROLES.ADMIN) {
        navigate(ROUTES.ADMIN_ALERTS);
      }

      if (role === ROLES.SECURITY) {
        navigate(ROUTES.SECURITY_INCIDENTS);
      }
    } catch (error) {
      console.error("Failed to open notification:", error);
    }
  };

  return (
    <nav className="topbar">
      <div
        className="tb-logo"
        onClick={() => navigate(links[0]?.path || ROUTES.LOGIN)}
      >
        <svg width="22" height="22" viewBox="0 0 36 36" fill="none">
          <path
            d="M18 2L32 10V26L18 34L4 26V10L18 2Z"
            fill="white"
            fillOpacity="0.15"
          />
          <path
            d="M18 2L32 10V26L18 34L4 26V10L18 2Z"
            stroke="white"
            strokeWidth="1.2"
          />
          <path
            d="M18 8L26 13V23L18 28L10 23V13L18 8Z"
            fill="white"
            fillOpacity="0.25"
          />
          <circle cx="18" cy="18" r="3.5" fill="white" />
        </svg>
        <span className="tb-logo-name">HexaGate</span>
      </div>

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

      <div className="tb-right">
        {canReceiveNotifications(role) && (
          <div className="tb-notification-wrapper" ref={notifRef}>
            <button
              className="tb-bell"
              onClick={() => setIsNotifOpen((prev) => !prev)}
              type="button"
            >
              <svg
                width="15"
                height="15"
                viewBox="0 0 24 24"
                fill="none"
                stroke="rgba(255,255,255,0.75)"
                strokeWidth="2"
              >
                <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9" />
                <path d="M13.73 21a2 2 0 0 1-3.46 0" />
              </svg>

              {unreadCount > 0 && (
                <span className="tb-notif-badge">
                  {unreadCount > 9 ? "9+" : unreadCount}
                </span>
              )}
            </button>

            {isNotifOpen && (
              <div className="tb-notif-dropdown">
                <div className="tb-notif-header">
                  <span>Notifications</span>
                  <small>{unreadCount} unread</small>
                </div>

                {notifications.length === 0 ? (
                  <div className="tb-notif-empty">
                    No emergency notifications.
                  </div>
                ) : (
                  <div className="tb-notif-list">
                    {notifications.slice(0, 6).map((notification) => (
                      <button
                        key={notification.id}
                        className={`tb-notif-item ${
                          !notification.is_read ? "unread" : ""
                        }`}
                        onClick={() => handleNotificationClick(notification)}
                        type="button"
                      >
                        <div className="tb-notif-icon">🚨</div>

                        <div className="tb-notif-content">
                          <strong>{notification.title}</strong>
                          <p>{notification.message}</p>
                          <small>
                            {new Date(notification.created_at).toLocaleString()}
                          </small>
                        </div>
                      </button>
                    ))}
                  </div>
                )}
              </div>
            )}
          </div>
        )}

        <div className="tb-user">
          <div className="tb-avatar">{initials}</div>
          <span className="tb-username">{user?.name || "User"}</span>
        </div>

        <button className="tb-logout" onClick={handleLogout}>
          <svg
            width="14"
            height="14"
            viewBox="0 0 24 24"
            fill="none"
            stroke="rgba(255,255,255,0.4)"
            strokeWidth="2"
          >
            <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4" />
            <polyline points="16 17 21 12 16 7" />
            <line x1="21" y1="12" x2="9" y2="12" />
          </svg>
          Log out
        </button>
      </div>
    </nav>
  );
};

export default Topbar;