import { useState, useMemo, useEffect } from "react";
import PageWrapper from "../../components/layout/PageWrapper";
import "./IncidentLog.css";



const mockAlerts = [
  { 
    id: "1",  
    type: "unauthorized_access",  
    severity: "critical", 
    description: "Unknown person attempted to enter through Gate 2 without authorization.",         
    location: "Gate 2",          
    triggeredAt: "2026-03-29T07:55:00Z", 
    status: "active",   
    resolvedBy: null,            
    resolvedAt: null,                
    note: null 
  },
  { 
    id: "2",  
    type: "fire_smoke",           
    severity: "high",     
    description: "Smoke detector triggered in the basement parking area near elevator B.",          
    location: "Basement B",      
    triggeredAt: "2026-03-29T06:30:00Z", 
    status: "active",   
    resolvedBy: null,            
    resolvedAt: null,                
    note: null 
  },
  { 
    id: "3",  
    type: "suspicious_behavior",  
    severity: "medium",   
    description: "Individual loitering near Building C entrance for over 30 minutes.",              
    location: "Building C",      
    triggeredAt: "2026-03-28T22:10:00Z", 
    status: "active",   
    resolvedBy: null,            
    resolvedAt: null,                
    note: null 
  },
  { 
    id: "4",  
    type: "other",               
    severity: "low",      
    description: "Unidentified noise reported near the pool area after closing hours.",             
    location: "Pool area",       
    triggeredAt: "2026-03-28T23:45:00Z", 
    status: "active",   
    resolvedBy: null,            
    resolvedAt: null,                
    note: null 
  },
  { 
    id: "5",  
    type: "unauthorized_access",  
    severity: "high",     
    description: "Gate 1 forced open attempt detected by sensor.",                                  
    location: "Gate 1",          
    triggeredAt: "2026-03-28T18:20:00Z", 
    status: "resolved", 
    resolvedBy: "Karima Saidi",  
    resolvedAt: "2026-03-28T18:35:00Z", 
    note: "Security team dispatched, situation handled." 
  },
  { 
    id: "6",  
    type: "suspicious_behavior",  
    severity: "medium",   
    description: "Unknown vehicle parked in restricted area for over 2 hours.",                    
    location: "Parking zone A",  
    triggeredAt: "2026-03-28T14:00:00Z", 
    status: "resolved", 
    resolvedBy: "Farid Belkacem",
    resolvedAt: "2026-03-28T16:10:00Z", 
    note: "Vehicle owner identified and warned." 
  },
  { 
    id: "7",  
    type: "fire_smoke",           
    severity: "critical", 
    description: "Fire alarm triggered in Building A, floor 3. Residents evacuated.",              
    location: "Building A - F3", 
    triggeredAt: "2026-03-27T11:15:00Z", 
    status: "resolved", 
    resolvedBy: "Karima Saidi",  
    resolvedAt: "2026-03-27T11:45:00Z", 
    note: "False alarm — faulty sensor replaced." 
  },
];

const typeConfig = {
  unauthorized_access: { label: "Unauthorized access", icon: "lock", color: "#e74c3c", bg: "#fdf0f0" },
  fire_smoke: { label: "Fire / smoke", icon: "fire", color: "#e67e22", bg: "#fdf0e0" },
  suspicious_behavior: { label: "Suspicious behavior", icon: "eye", color: "#854F0B", bg: "#faeeda" },
  other: { label: "Other", icon: "alert", color: "#888", bg: "#f5f5f5" },
};

const severityConfig = {
  critical: { label: "Critical", color: "#e74c3c", bg: "#fdf0f0" },
  high: { label: "High", color: "#e67e22", bg: "#fdf0e0" },
  medium: { label: "Medium", color: "#d97706", bg: "#fff4e5" },
  low: { label: "Low", color: "#64748b", bg: "#f8fafc" },
};

const formatTime = (iso) => {
  const d = new Date(iso);
  return d.toLocaleDateString("en-GB", { day: "numeric", month: "short" }) +
    " · " + d.toLocaleTimeString("en-GB", { hour: "2-digit", minute: "2-digit" });
};

const TypeIcon = ({ type }) => {
  const color = typeConfig[type]?.color || "#888";
  
  if (type === "unauthorized_access") return (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2.2">
      <rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/>
    </svg>
  );
  if (type === "fire_smoke") return (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2.2">
      <path d="M12 2c0 0-4 4-4 8a4 4 0 0 0 8 0c0-4-4-8-4-8z"/><path d="M12 14c0 0-2 2-2 4a2 2 0 0 0 4 0c0-2-2-4-2-4z"/>
    </svg>
  );
  if (type === "suspicious_behavior") return (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2.2">
      <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/>
    </svg>
  );
  return (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2.2">
      <circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/>
    </svg>
  );
};

const IncidentLog = () => {
  const [alerts, setAlerts] = useState(mockAlerts);
  const [filter, setFilter] = useState("all");
  const [typeFilter, setTypeFilter] = useState("all");
  const [resolveId, setResolveId] = useState(null);
  const [resolveNote, setResolveNote] = useState("");
  const [resolving, setResolving] = useState(false);
  const [lastUpdated, setLastUpdated] = useState(new Date());

  // Simulate last updated time
  useEffect(() => {
    const interval = setInterval(() => setLastUpdated(new Date()), 45000);
    return () => clearInterval(interval);
  }, []);

  const activeCount = alerts.filter(a => a.status === "active").length;
  const criticalCount = alerts.filter(a => a.severity === "critical" && a.status === "active").length;
  const resolvedCount = alerts.filter(a => a.status === "resolved").length;

  const filtered = useMemo(() => {
    return alerts
      .filter((a) => {
        const matchStatus = filter === "all" ? true : a.status === filter;
        const matchType = typeFilter === "all" ? true : a.type === typeFilter;
        return matchStatus && matchType;
      })
      .sort((a, b) => {
        const order = { critical: 4, high: 3, medium: 2, low: 1 };
        return order[b.severity] - order[a.severity] ||
               new Date(b.triggeredAt) - new Date(a.triggeredAt);
      });
  }, [alerts, filter, typeFilter]);

  const handleResolve = (id) => {
    setResolveId(id);
    setResolveNote("");
  };

  const confirmResolve = () => {
    if (!resolveNote.trim() || !resolveId) return;

    setResolving(true);

    setAlerts(prev =>
      prev.map(a =>
        a.id === resolveId
          ? {
              ...a,
              status: "resolved",
              resolvedBy: "You",
              resolvedAt: new Date().toISOString(),
              note: resolveNote.trim()
            }
          : a
      )
    );

    setResolveId(null);
    setResolveNote("");
    setResolving(false);
  };

  return (
    <PageWrapper>
      <div className="surv-layout">

        {/* Hero */}
        <div className="surv-hero">
          <div className="surv-hero-hex">
            <svg width="160" height="140" viewBox="0 0 160 140" fill="none">
              <path d="M80 8L144 44V116L80 152L16 116V44L80 8Z" stroke="white" strokeWidth="1" opacity="0.15"/>
              <path d="M80 32L120 55V101L80 124L40 101V55L80 32Z" stroke="white" strokeWidth="0.8" opacity="0.1"/>
            </svg>
          </div>
          <div>
            <div className="surv-hero-tag">Security Agent</div>
            <div className="surv-hero-title">
              Incidents & Alerts
              {criticalCount > 0 && (
                <span className="surv-critical-badge">
                  {criticalCount} CRITICAL
                </span>
              )}
            </div>

            <div className="surv-hero-stats">
              <div className="surv-hs">
                <span className="surv-hs-val" style={{color: "#f87171"}}>{activeCount}</span>
                <span className="surv-hs-label">Active alerts</span>
              </div>
              <div className="surv-hs-div" />
              <div className="surv-hs">
                <span className="surv-hs-val" style={{color: "#fb923c"}}>{criticalCount}</span>
                <span className="surv-hs-label">Critical</span>
              </div>
              <div className="surv-hs-div" />
              <div className="surv-hs">
                <span className="surv-hs-val">{resolvedCount}</span>
                <span className="surv-hs-label">Resolved</span>
              </div>
              <div className="surv-hs-div" />
              <div className="surv-hs">
                <span className="surv-hs-val">{alerts.length}</span>
                <span className="surv-hs-label">Total</span>
              </div>
            </div>
            <div style={{fontSize: "11px", color: "rgba(255,255,255,0.5)", marginTop: "12px"}}>
              Last updated {lastUpdated.toLocaleTimeString([], {hour:'2-digit', minute:'2-digit'})}
            </div>
          </div>
        </div>

        {/* Filters */}
        <div className="surv-filters">
          <div className="surv-status-filters">
            {["all", "active", "resolved"].map((f) => (
              <button
                key={f}
                className={`surv-filter-btn ${filter === f ? "active" : ""}`}
                onClick={() => setFilter(f)}
              >
                {f.charAt(0).toUpperCase() + f.slice(1)}
                {f === "active" && activeCount > 0 && <span className="surv-filter-dot" />}
              </button>
            ))}
          </div>

          <select
            className="surv-type-filter"
            value={typeFilter}
            onChange={(e) => setTypeFilter(e.target.value)}
          >
            <option value="all">All types</option>
            {Object.keys(typeConfig).map(key => (
              <option key={key} value={key}>{typeConfig[key].label}</option>
            ))}
          </select>
        </div>

        {/* Alerts List */}
        <div className="surv-list">
          {filtered.length === 0 ? (
            <div className="surv-empty">
              No alerts found for the selected filters.
            </div>
          ) : (
            filtered.map((alert) => (
              <div
                key={alert.id}
                className={`surv-alert ${alert.status} ${alert.severity}`}
              >
                <div className="surv-alert-left">
                  <div
                    className="surv-alert-icon"
                    style={{ background: typeConfig[alert.type]?.bg || "#f5f5f5" }}
                  >
                    <TypeIcon type={alert.type} />
                  </div>
                </div>

                <div className="surv-alert-body">
                  <div className="surv-alert-top">
                    <span className="surv-alert-type">
                      {typeConfig[alert.type]?.label || alert.type}
                    </span>
                    <span
                      className="surv-alert-severity"
                      style={{
                        background: severityConfig[alert.severity].bg,
                        color: severityConfig[alert.severity].color,
                      }}
                    >
                      {severityConfig[alert.severity].label}
                    </span>
                    {alert.status === "active" && <span className="surv-active-pill">Active</span>}
                    {alert.status === "resolved" && <span className="surv-resolved-pill">Resolved</span>}
                  </div>

                  <div className="surv-alert-desc">{alert.description}</div>

                  <div className="surv-alert-meta">
                    <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                      <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/>
                      <circle cx="12" cy="10" r="3"/>
                    </svg>
                    {alert.location}
                    <span className="surv-meta-sep">·</span>
                    {formatTime(alert.triggeredAt)}
                    {alert.status === "resolved" && (
                      <>
                        <span className="surv-meta-sep">·</span>
                        Resolved by {alert.resolvedBy}
                      </>
                    )}
                  </div>

                  {alert.note && (
                    <div className="surv-alert-note">
                      Note: {alert.note}
                    </div>
                  )}
                </div>

                {alert.status === "active" && (
                  <div className="surv-alert-action">
                    {resolveId === alert.id ? (
                      <div className="surv-resolve-panel">
                        <textarea
                          className="surv-resolve-input"
                          placeholder="Add a resolution note... (required)"
                          value={resolveNote}
                          onChange={(e) => setResolveNote(e.target.value)}
                          rows={3}
                        />
                        <div className="surv-resolve-btns">
                          <button
                            className="surv-cancel-btn"
                            onClick={() => setResolveId(null)}
                          >
                            Cancel
                          </button>
                          <button
                            className="surv-confirm-btn"
                            onClick={confirmResolve}
                            disabled={!resolveNote.trim() || resolving}
                          >
                            {resolving ? "Resolving..." : "Confirm Resolve"}
                          </button>
                        </div>
                      </div>
                    ) : (
                      <button
                        className="surv-resolve-btn"
                        onClick={() => handleResolve(alert.id)}
                      >
                        Mark as Resolved
                      </button>
                    )}
                  </div>
                )}
              </div>
            ))
          )}
        </div>
      </div>
    </PageWrapper>
  );
};

export default IncidentLog;