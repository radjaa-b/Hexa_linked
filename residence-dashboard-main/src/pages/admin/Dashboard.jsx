import { useEffect, useState } from "react";
import PageWrapper from "../../components/layout/PageWrapper";
import "./Dashboard.css";
import useAuth from "../../hooks/useAuth";
// ============================================================
// Radja: this page calls GET /admin/dashboard/stats
// and GET /admin/access-log (latest 4 entries)
// and GET /technician/maintenance (latest 3 pending)
// and GET /notifications (unread)
// Replace the mock data below with real API calls
// ============================================================

const mockStats = {
  totalResidents: 120,
  todayEntries: 34,
  pendingRequests: 4,
  newMessages: 2,
};

const mockAccessLog = [
  { id: 1, name: "Ahmed Benali",  unit: "Unit A-12 · Resident", type: "entry",    time: "08:30" },
  { id: 2, name: "Karima Saidi",  unit: "Security Agent · Staff", type: "entry",  time: "08:15" },
  { id: 3, name: "Unknown visitor",unit: "Gate 2 · Unauthorized", type: "alert",  time: "07:55" },
  { id: 4, name: "Youcef Amrani", unit: "Unit B-04 · Resident",  type: "entry",   time: "07:40" },
];

const mockMaintenance = [
  { id: 1, title: "Hallway light B3", category: "Electrical", priority: "medium" },
  { id: 2, title: "Water leak A-07",  category: "Plumbing",   priority: "high"   },
  { id: 3, title: "Door lock C-11",   category: "General",    priority: "low"    },
];

const mockAlerts = [
  { id: 1, title: "Unauthorized access", sub: "Gate 2 · 07:55 today", type: "danger" },
  { id: 2, title: "High consumption",    sub: "Building B · Electricity", type: "warning" },
];

const mockVisitors = [
  { id: 1, name: "Karim Ouali",  initials: "KO" },
  { id: 2, name: "Sara Bensaid", initials: "SB" },
];

const mockConsumption = {
  electricity: { value: 1240, unit: "kWh", trend: "+5%", up: true  },
  water:       { value: 340,  unit: "m³",  trend: "-2%", up: false },
};

const priorityStyles = {
  high:   { bg: "#fdf0f0", color: "#e74c3c" },
  medium: { bg: "#fdf0e0", color: "#e67e22" },
  low:    { bg: "#f5f5f5", color: "#aaa"    },
};

const today = new Date().toLocaleDateString("en-GB", {
  weekday: "long", year: "numeric", month: "long", day: "numeric"
});

const Dashboard = () => {
   const { user } = useAuth();
  const [stats,       setStats]       = useState(mockStats);
  const [accessLog,   setAccessLog]   = useState(mockAccessLog);
  const [maintenance, setMaintenance] = useState(mockMaintenance);
  const [alerts,      setAlerts]      = useState(mockAlerts);
  const [visitors,    setVisitors]    = useState(mockVisitors);
  const [consumption, setConsumption] = useState(mockConsumption);

  // Radja: uncomment and implement when backend is ready
  // useEffect(() => {
  //   fetchDashboardStats().then(setStats);
  //   fetchAccessLog({ limit: 4 }).then(setAccessLog);
  //   fetchMaintenance({ status: "pending", limit: 3 }).then(setMaintenance);
  // }, []);

  return (
    <PageWrapper>
      <div className="dash-layout">

        {/* ── Main content ── */}
        <div className="dash-main">

          {/* Hero banner */}
          <div className="dash-hero">
            <div className="dash-hero-hex">
              <svg width="220" height="200" viewBox="0 0 200 180" fill="none">
                <path d="M100 10L180 55V145L100 190L20 145V55L100 10Z"
                  stroke="white" strokeWidth="1" opacity="0.15"/>
                <path d="M100 40L150 68V122L100 150L50 122V68L100 40Z"
                  stroke="white" strokeWidth="0.8" opacity="0.1"/>
                <path d="M100 70L125 84V110L100 124L75 110V84L100 70Z"
                  stroke="white" strokeWidth="0.6" opacity="0.08"/>
              </svg>
            </div>
            <div className="dash-hero-tag">{today}</div>
            <div className="dash-hero-title">
  Good {getGreeting()},<br />{user?.name || "Administrator"}
</div>
            <div className="dash-hero-stats">
              <div className="dash-hs">
                <span className="dash-hs-val">{stats.totalResidents}</span>
                <span className="dash-hs-label">Residents</span>
              </div>
              <div className="dash-hs-divider" />
              <div className="dash-hs">
                <span className="dash-hs-val">{stats.todayEntries}</span>
                <span className="dash-hs-label">Entries today</span>
              </div>
              <div className="dash-hs-divider" />
              <div className="dash-hs">
                <span className="dash-hs-val">{stats.pendingRequests}</span>
                <span className="dash-hs-label">Pending requests</span>
              </div>
              <div className="dash-hs-divider" />
              <div className="dash-hs">
                <span className="dash-hs-val">{stats.newMessages}</span>
                <span className="dash-hs-label">New messages</span>
              </div>
            </div>
          </div>

          {/* Two column cards */}
          <div className="dash-cards">

            {/* Access log */}
            <div className="dash-card">
              <div className="dash-card-head">
                <span className="dash-card-title">Recent access</span>
                <span className="dash-card-more">View all</span>
              </div>
              {accessLog.map((item) => (
                <div key={item.id} className="dash-log-item">
                  <div className={`dash-log-icon ${item.type}`}>
                    {item.type === "alert" ? (
                      <svg width="13" height="13" viewBox="0 0 24 24" fill="none"
                        stroke="#e74c3c" strokeWidth="2">
                        <circle cx="12" cy="12" r="10"/>
                        <line x1="12" y1="8" x2="12" y2="12"/>
                        <line x1="12" y1="16" x2="12.01" y2="16"/>
                      </svg>
                    ) : (
                      <svg width="13" height="13" viewBox="0 0 24 24" fill="none"
                        stroke="#1D9E75" strokeWidth="2">
                        <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
                      </svg>
                    )}
                  </div>
                  <div className="dash-log-info">
                    <span className="dash-log-name">{item.name}</span>
                    <span className="dash-log-unit">{item.unit}</span>
                  </div>
                  <span className="dash-log-time">{item.time}</span>
                </div>
              ))}
            </div>

            {/* Maintenance */}
            <div className="dash-card">
              <div className="dash-card-head">
                <span className="dash-card-title">Maintenance requests</span>
                <span className="dash-card-more">View all</span>
              </div>
              {maintenance.map((item) => (
                <div key={item.id} className="dash-log-item">
                  <div className="dash-log-info">
                    <span className="dash-log-name">{item.title}</span>
                    <span className="dash-log-unit">{item.category}</span>
                  </div>
                  <span
                    className="dash-badge"
                    style={{
                      background: priorityStyles[item.priority].bg,
                      color:      priorityStyles[item.priority].color,
                    }}
                  >
                    {item.priority.charAt(0).toUpperCase() + item.priority.slice(1)}
                  </span>
                </div>
              ))}
            </div>

          </div>
        </div>

        {/* ── Right panel ── */}
        <div className="dash-right">

          {/* Consumption */}
          <div className="dash-rp-section">
            <div className="dash-rp-title">Live consumption</div>
            <div className="dash-rp-stat">
              <div className="dash-rp-val">{consumption.electricity.value.toLocaleString()}</div>
              <div className="dash-rp-label">{consumption.electricity.unit} this month</div>
              <div className={`dash-rp-trend ${consumption.electricity.up ? "up" : "down"}`}>
                {consumption.electricity.up ? "↑" : "↓"} {consumption.electricity.trend} vs last month
              </div>
            </div>
            <div className="dash-rp-stat">
              <div className="dash-rp-val">{consumption.water.value}</div>
              <div className="dash-rp-label">{consumption.water.unit} water used</div>
              <div className={`dash-rp-trend ${consumption.water.up ? "up" : "down"}`}>
                {consumption.water.up ? "↑" : "↓"} {consumption.water.trend} vs last month
              </div>
            </div>
          </div>

          {/* Alerts */}
          <div className="dash-rp-section">
            <div className="dash-rp-title">Alerts</div>
            {alerts.map((alert) => (
              <div key={alert.id} className={`dash-rp-alert ${alert.type}`}>
                <div className="dash-rp-alert-title">{alert.title}</div>
                <div className="dash-rp-alert-sub">{alert.sub}</div>
              </div>
            ))}
          </div>

          {/* Pending visitors */}
          <div className="dash-rp-section">
            <div className="dash-rp-title">Pending visitors</div>
            {visitors.map((v) => (
              <div key={v.id} className="dash-rp-visitor">
                <div className="dash-rp-avatar">{v.initials}</div>
                <span className="dash-rp-vname">{v.name}</span>
                <span className="dash-rp-vbadge">Pending</span>
              </div>
            ))}
          </div>

        </div>
      </div>
    </PageWrapper>
  );
};

// Helper for greeting
const getGreeting = () => {
  const h = new Date().getHours();
  if (h < 12) return "morning";
  if (h < 18) return "afternoon";
  return "evening";
};

export default Dashboard;