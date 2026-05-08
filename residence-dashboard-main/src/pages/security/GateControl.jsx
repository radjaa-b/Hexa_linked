import { useState, useRef, useEffect } from "react";
import PageWrapper from "../../components/layout/PageWrapper";
import "./GateControl.css";
import { createSecurityAccessLog, getSecurityAccessLogs } from "../../services/accessLogService";

// ============================================================
// Gate Control - Security Agent Page with Dynamic Greeting
// ============================================================

const mockGates = [
  { id: "gate-1", name: "Main gate",      status: "open",   lastChangedBy: "Karima Saidi",   lastChangedAt: "2026-03-29T08:30:00Z" },
  { id: "gate-2", name: "Secondary gate", status: "closed", lastChangedBy: "Farid Belkacem", lastChangedAt: "2026-03-29T22:00:00Z" },
];



const emptyForm = { visitorName: "", unit: "", gateId: "gate-1", type: "visitor" };

const typeStyles = {
  resident: { bg: "#edfaf5", color: "#0F6E56", label: "Resident" },
  staff:    { bg: "#E6F1FB", color: "#185FA5", label: "Staff" },
  visitor:  { bg: "#fdf0e0", color: "#854F0B", label: "Visitor" },
};

const formatTime = (iso) => {
  const d = new Date(iso);
  return d.toLocaleTimeString("en-GB", { hour: "2-digit", minute: "2-digit" });
};

const formatSince = (iso) => {
  const d = new Date(iso);
  return d.toLocaleTimeString("en-GB", { hour: "2-digit", minute: "2-digit" });
};

// Dynamic Greeting based on time
const getWeatherGreeting = () => {
  const hour = new Date().getHours();
  const greetings = {
    morning: [
      "Good morning, Agent",
      "Good morning – clear skies ahead",
      "Rise and secure, Agent"
    ],
    afternoon: [
      "Good afternoon, Agent",
      "Good afternoon – stay vigilant",
      "Afternoon watch, Agent"
    ],
    evening: [
      "Good evening, Agent",
      "Good evening – night shift ready",
      "Evening patrol, Agent – stay alert"
    ]
  };

  let period;
  if (hour < 12) period = "morning";
  else if (hour < 17) period = "afternoon";
  else period = "evening";

  const options = greetings[period];
  return options[Math.floor(Math.random() * options.length)];
};

const GateControl = () => {
  const [gates, setGates] = useState(mockGates);
  const [log, setLog] = useState([]);
 
  const [form, setForm] = useState(emptyForm);
  const [formError, setFormError] = useState("");
  const [formSuccess, setFormSuccess] = useState("");
  const [loading, setLoading] = useState(false);
  const logRef = useRef(null);

  const pendingCount = 2;
  const parseSecuritySource = (entry) => {
  const source = entry.source || "";

  if (!source.startsWith("manual_")) {
    return {
      id: String(entry.id),
      name: "RFID / IoT entry",
      unit: null,
      type: "resident",
      method: "qr_code",
      gate: entry.gate_id || "Main gate",
      timestamp: entry.event_time,
    };
  }

  const [rawType, name, unit] = source.split("|");
  const type = rawType.replace("manual_", "");

  return {
    id: String(entry.id),
    name: name || "Unknown",
    unit: unit && unit !== "-" ? unit : null,
    type: type || "visitor",
    method: "manual",
    gate: entry.gate_id || "Main gate",
    timestamp: entry.event_time,
  };
};

const loadSecurityLogs = async () => {
  try {
    const data = await getSecurityAccessLogs();

    const normalized = Array.isArray(data)
      ? data.map(parseSecuritySource)
      : [];

    setLog(normalized);
  } catch (error) {
    console.error("Failed to load security logs:", error);
  }
};

useEffect(() => {
  loadSecurityLogs();

  const interval = setInterval(loadSecurityLogs, 5000);

  return () => clearInterval(interval);
}, []);

  const handleGateControl = (gateId, action) => {
    setGates((prev) =>
      prev.map((g) =>
        g.id === gateId
          ? { ...g, status: action, lastChangedBy: "You", lastChangedAt: new Date().toISOString() }
          : g
      )
    );
  };

  const handleFormChange = (e) => {
    setForm({ ...form, [e.target.name]: e.target.value });
    setFormError("");
    setFormSuccess("");
  };

  const handleManualEntry = async (e) => {
  e.preventDefault();

  if (!form.visitorName.trim()) {
    setFormError("Name is required.");
    return;
  }

  try {
    setLoading(true);
    setFormError("");
    setFormSuccess("");

    const gateName = gates.find((g) => g.id === form.gateId)?.name || "Main gate";

    const source = `manual_${form.type}|${form.visitorName.trim()}|${form.unit.trim() || "-"}`;

    const savedLog = await createSecurityAccessLog({
      resident_id: null,
      access_status: "granted",
      gate_id: gateName,
      source,
      event_time: new Date().toISOString(),
    });

    const newEntry = {
      id: String(savedLog.id),
      name: form.visitorName.trim(),
      unit: form.unit || null,
      type: form.type,
      method: "manual",
      gate: gateName,
      timestamp: savedLog.event_time || new Date().toISOString(),
    };

    setLog((prev) => [newEntry, ...prev]);
    setForm(emptyForm);
    setFormSuccess("Entry logged successfully.");
    handleGateControl(form.gateId, "open");

    if (logRef.current) logRef.current.scrollTop = 0;
  } catch (error) {
    console.error("Failed to create access log:", error);
    setFormError(
      error.response?.data?.detail ||
        "Failed to log entry. Please try again."
    );
  } finally {
    setLoading(false);
  }
};

 

  return (
    <PageWrapper>
      <div className="gate-layout">

        {/* Hero with Dynamic Greeting */}
        <div className="gate-hero">
          <div className="gate-hero-hex">
            <svg width="160" height="140" viewBox="0 0 160 140" fill="none">
              <path d="M80 8L144 44V116L80 152L16 116V44L80 8Z" stroke="white" strokeWidth="1" opacity="0.15"/>
              <path d="M80 32L120 55V101L80 124L40 101V55L80 32Z" stroke="white" strokeWidth="0.8" opacity="0.1"/>
            </svg>
          </div>
          <div>
            <div className="gate-hero-tag">Security Operations</div>
            <div className="gate-hero-greeting">
              {getWeatherGreeting()}
            </div>
            <div className="gate-hero-title">Gate Control Center</div>

            <div className="gate-hero-stats">
              <div className="gate-hs">
                <span className="gate-hs-val">
                  {log.filter(e => new Date(e.timestamp).toDateString() === new Date().toDateString()).length}
                </span>
                <span className="gate-hs-label">Entries today</span>
              </div>
              <div className="gate-hs-div" />
              <div className="gate-hs">
                <span className="gate-hs-val">
                  {log.filter(e => e.method === "qr_code" && 
                    new Date(e.timestamp).toDateString() === new Date().toDateString()).length}
                </span>
                <span className="gate-hs-label">QR scans</span>
              </div>
              <div className="gate-hs-div" />
              <div className="gate-hs">
                <span className="gate-hs-val">
                  {log.filter(e => e.method === "manual" && 
                    new Date(e.timestamp).toDateString() === new Date().toDateString()).length}
                </span>
                <span className="gate-hs-label">Manual entries</span>
              </div>
              <div className="gate-hs-div" />
              <div className="gate-hs">
                <span className="gate-hs-val">{pendingCount}</span>
                <span className="gate-hs-label">Pending visitors</span>
              </div>
            </div>
          </div>
        </div>

        {/* Main Body */}
        <div className="gate-body">

          {/* Gate Cards */}
          <div className="gate-cards">
            {gates.map((gate) => (
              <div key={gate.id} className="gate-card">
                <div className="gate-card-name">{gate.name}</div>
                <div className={`gate-ring ${gate.status}`}>
                  <div className="gate-ring-inner">
                    <svg width="32" height="32" viewBox="0 0 24 24" fill="none"
                      stroke={gate.status === "open" ? "#1D9E75" : "#e74c3c"} strokeWidth="1.5">
                      {gate.status === "open" ? (
                        <>
                          <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
                          <path d="M7 11V7a5 5 0 0 1 9.9-1"/>
                        </>
                      ) : (
                        <>
                          <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
                          <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
                        </>
                      )}
                    </svg>
                    <span className="gate-ring-status">
                      {gate.status === "open" ? "Open" : "Closed"}
                    </span>
                    <span className="gate-ring-since">
                      Since {formatSince(gate.lastChangedAt)}
                    </span>
                  </div>
                </div>
                <div className="gate-last-action">
                  Last action by {gate.lastChangedBy}
                </div>
                <div className="gate-btns">
                  <button
                    className={`gate-btn open ${gate.status === "open" ? "current" : ""}`}
                    onClick={() => handleGateControl(gate.id, "open")}
                    disabled={gate.status === "open"}
                  >
                    Open
                  </button>
                  <button
                    className={`gate-btn close ${gate.status === "closed" ? "current" : ""}`}
                    onClick={() => handleGateControl(gate.id, "close")}
                    disabled={gate.status === "closed"}
                  >
                    Close
                  </button>
                </div>
              </div>
            ))}
          </div>

          {/* Manual Entry */}
          <div className="gate-manual">
            <div className="gate-manual-title">Manual entry</div>
            <p className="gate-manual-sub">
              Use this to let in a visitor or staff member manually.
              The gate will open automatically on submit.
            </p>
            <form onSubmit={handleManualEntry} className="gate-manual-form">
              <label className="gate-manual-label">Person type</label>
              <select
                className="gate-manual-input"
                name="type"
                value={form.type}
                onChange={handleFormChange}
              >
                <option value="visitor">Visitor</option>
                <option value="staff">Staff</option>
                <option value="resident">Resident</option>
              </select>

              <label className="gate-manual-label">Full name</label>
              <input
                className="gate-manual-input"
                name="visitorName"
                placeholder="e.g. Karim Ouali"
                value={form.visitorName}
                onChange={handleFormChange}
              />

              <label className="gate-manual-label">Visiting unit (optional)</label>
              <input
                className="gate-manual-input"
                name="unit"
                placeholder="e.g. A-12"
                value={form.unit}
                onChange={handleFormChange}
              />

              <label className="gate-manual-label">Gate</label>
              <select
                className="gate-manual-input"
                name="gateId"
                value={form.gateId}
                onChange={handleFormChange}
              >
                {gates.map((g) => (
                  <option key={g.id} value={g.id}>{g.name}</option>
                ))}
              </select>

              {formError && <p className="gate-form-error">{formError}</p>}
              {formSuccess && <p className="gate-form-success">{formSuccess}</p>}

              <button
                type="submit"
                className="gate-manual-btn"
                disabled={loading}
              >
                {loading ? "Logging..." : "Log entry & open gate"}
              </button>
            </form>

           
          </div>

          {/* Live Log */}
          <div className="gate-log">
            <div className="gate-log-head">
              <span className="gate-log-title">Live entry log</span>
              <span className="gate-log-count">{log.length} entries</span>
            </div>
            <div className="gate-log-list" ref={logRef}>
              {log.map((entry) => (
                <div key={entry.id} className="gate-log-item">
                  <div className={`gate-log-icon ${entry.type}`}>
                    {entry.type === "visitor" ? (
                      <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#854F0B" strokeWidth="2">
                        <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
                        <circle cx="12" cy="7" r="4"/>
                      </svg>
                    ) : entry.type === "staff" ? (
                      <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#185FA5" strokeWidth="2">
                        <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
                        <circle cx="12" cy="7" r="4"/>
                      </svg>
                    ) : (
                      <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#1D9E75" strokeWidth="2">
                        <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
                      </svg>
                    )}
                  </div>
                  <div className="gate-log-info">
                    <div className="gate-log-name">{entry.name}</div>
                    <div className="gate-log-meta">
                      {entry.unit ? `Unit ${entry.unit} · ` : ""}
                      {entry.gate} · {entry.method === "qr_code" ? "QR scan" : "Manual"}
                    </div>
                  </div>
                  <div className="gate-log-right">
                    <span
                      className="gate-log-badge"
                      style={{ background: typeStyles[entry.type].bg, color: typeStyles[entry.type].color }}
                    >
                      {typeStyles[entry.type].label}
                    </span>
                    <div className="gate-log-time">
                      {formatTime(entry.timestamp)}
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </PageWrapper>
  );
};

export default GateControl;