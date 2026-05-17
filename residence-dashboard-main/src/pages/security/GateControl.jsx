import { useState, useRef, useEffect } from "react";
import PageWrapper from "../../components/layout/PageWrapper";
import "./GateControl.css";

import {
  createVerifiedManualAccess,
  getSecurityAccessLogs,
  searchResidentsForManualAccess,
  searchVisitorsForManualAccess,
} from "../../services/accessLogService";

const mockGates = [
  {
    id: "gate-1",
    name: "Main gate",
    status: "open",
    lastChangedBy: "Karima Saidi",
    lastChangedAt: "2026-03-29T08:30:00Z",
  },
  {
    id: "gate-2",
    name: "Secondary gate",
    status: "closed",
    lastChangedBy: "Farid Belkacem",
    lastChangedAt: "2026-03-29T22:00:00Z",
  },
];

const emptyForm = {
  visitorName: "",
  unit: "",
  gateId: "gate-1",
  type: "visitor",
  residentId: null,
  visitorRequestId: null,
};

const typeStyles = {
  resident: { bg: "#edfaf5", color: "#0F6E56", label: "Resident" },
  staff: { bg: "#E6F1FB", color: "#185FA5", label: "Staff" },
  visitor: { bg: "#fdf0e0", color: "#854F0B", label: "Visitor" },
};

const formatTime = (iso) => {
  const d = new Date(iso);
  return d.toLocaleTimeString("en-GB", { hour: "2-digit", minute: "2-digit" });
};

const formatSince = (iso) => {
  const d = new Date(iso);
  return d.toLocaleTimeString("en-GB", { hour: "2-digit", minute: "2-digit" });
};

const getWeatherGreeting = () => {
  const hour = new Date().getHours();

  const greetings = {
    morning: ["Good morning, Agent", "Good morning – clear skies ahead", "Rise and secure, Agent"],
    afternoon: ["Good afternoon, Agent", "Good afternoon – stay vigilant", "Afternoon watch, Agent"],
    evening: ["Good evening, Agent", "Good evening – night shift ready", "Evening patrol, Agent – stay alert"],
  };

  const period = hour < 12 ? "morning" : hour < 17 ? "afternoon" : "evening";
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

  const [residentResults, setResidentResults] = useState([]);
  const [visitorResults, setVisitorResults] = useState([]);

  const [residentSearch, setResidentSearch] = useState("");
  const [visitorSearch, setVisitorSearch] = useState("");

  const logRef = useRef(null);
  const pendingCount = 2;

  const parseSecuritySource = (entry) => {
    const source = entry.source || "";

    if (source.startsWith("iot_")) {
      const [, name, unit] = source.split("|");

      return {
        id: String(entry.id),
        name: name || "RFID Resident",
        unit: unit || null,
        type: "resident",
        method: "rfid",
        gate: entry.gate_id || "Main gate",
        timestamp: entry.event_time,
      };
    }

    if (source.startsWith("qr_")) {
      const [, name, unit] = source.split("|");

      return {
        id: String(entry.id),
        name: name || "QR Resident",
        unit: unit || null,
        type: "resident",
        method: "qr_code",
        gate: entry.gate_id || "Main gate",
        timestamp: entry.event_time,
      };
    }

    if (!source.startsWith("manual_")) {
      return {
        id: String(entry.id),
        name: "Access Event",
        unit: null,
        type: "resident",
        method: "system",
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
      const normalized = Array.isArray(data) ? data.map(parseSecuritySource) : [];
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
          ? {
              ...g,
              status: action,
              lastChangedBy: "You",
              lastChangedAt: new Date().toISOString(),
            }
          : g
      )
    );
  };

  const resetManualSelection = (type) => {
    setForm({
      ...emptyForm,
      type,
      gateId: form.gateId,
    });

    setResidentSearch("");
    setVisitorSearch("");
    setResidentResults([]);
    setVisitorResults([]);
    setFormError("");
    setFormSuccess("");
  };

  const handleFormChange = (e) => {
    setForm({ ...form, [e.target.name]: e.target.value });
    setFormError("");
    setFormSuccess("");
  };

  const handleResidentSearch = async (value) => {
    setResidentSearch(value);
    setForm((prev) => ({ ...prev, residentId: null }));

    if (!value.trim()) {
      setResidentResults([]);
      return;
    }

    try {
      const results = await searchResidentsForManualAccess(value);
      setResidentResults(results);
    } catch (err) {
      console.error(err);
    }
  };

  const handleVisitorSearch = async (value) => {
    setVisitorSearch(value);
    setForm((prev) => ({ ...prev, visitorRequestId: null }));

    if (!value.trim()) {
      setVisitorResults([]);
      return;
    }

    try {
      const results = await searchVisitorsForManualAccess(value);
      setVisitorResults(results);
    } catch (err) {
      console.error(err);
    }
  };

  const selectResident = (resident) => {
    setForm((prev) => ({
      ...prev,
      residentId: resident.id,
      visitorName: resident.full_name || resident.username,
      unit: resident.unit_number || "",
    }));

    setResidentSearch(`${resident.full_name || resident.username} (${resident.unit_number || "-"})`);
    setResidentResults([]);
    setFormError("");
  };

  const selectVisitor = (visitor) => {
    setForm((prev) => ({
      ...prev,
      visitorRequestId: visitor.id,
      visitorName: visitor.visitor_name,
      unit: visitor.unit_number || "",
    }));

    setVisitorSearch(`${visitor.visitor_name} (${visitor.unit_number || "-"})`);
    setVisitorResults([]);
    setFormError("");
  };

  const handleManualEntry = async (e) => {
    e.preventDefault();

    try {
      setLoading(true);
      setFormError("");
      setFormSuccess("");

      const gateName = gates.find((g) => g.id === form.gateId)?.name || "Main gate";

      const payload = {
        type: form.type,
        gate_id: gateName,
      };

      if (form.type === "resident") {
        if (!form.residentId) {
          setFormError("Please select a resident from the list.");
          return;
        }

        payload.resident_id = form.residentId;
      }

      if (form.type === "visitor") {
        if (!form.visitorRequestId) {
          setFormError("Please select an approved visitor.");
          return;
        }

        payload.visitor_request_id = form.visitorRequestId;
      }

      if (form.type === "staff") {
        if (!form.visitorName.trim()) {
          setFormError("Staff name is required.");
          return;
        }

        payload.name = form.visitorName.trim();
        payload.unit = form.unit.trim() || "-";
      }

      await createVerifiedManualAccess(payload);

      await loadSecurityLogs();
      handleGateControl(form.gateId, "open");

      setForm(emptyForm);
      setResidentSearch("");
      setVisitorSearch("");
      setResidentResults([]);
      setVisitorResults([]);
      setFormSuccess("Entry logged successfully.");

      if (logRef.current) logRef.current.scrollTop = 0;
    } catch (error) {
      console.error(error);
      setFormError(error.response?.data?.detail || "Failed to log entry. Please try again.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <PageWrapper>
      <div className="gate-layout">
        <div className="gate-hero">
          <div className="gate-hero-hex">
            <svg width="160" height="140" viewBox="0 0 160 140" fill="none">
              <path d="M80 8L144 44V116L80 152L16 116V44L80 8Z" stroke="white" strokeWidth="1" opacity="0.15" />
              <path d="M80 32L120 55V101L80 124L40 101V55L80 32Z" stroke="white" strokeWidth="0.8" opacity="0.1" />
            </svg>
          </div>

          <div>
            <div className="gate-hero-tag">Security Operations</div>
            <div className="gate-hero-greeting">{getWeatherGreeting()}</div>
            <div className="gate-hero-title">Gate Control Center</div>

            <div className="gate-hero-stats">
              <div className="gate-hs">
                <span className="gate-hs-val">
                  {log.filter((e) => new Date(e.timestamp).toDateString() === new Date().toDateString()).length}
                </span>
                <span className="gate-hs-label">Entries today</span>
              </div>

              <div className="gate-hs-div" />

              <div className="gate-hs">
                <span className="gate-hs-val">
                  {log.filter((e) => e.method === "qr_code" && new Date(e.timestamp).toDateString() === new Date().toDateString()).length}
                </span>
                <span className="gate-hs-label">QR scans</span>
              </div>

              <div className="gate-hs-div" />

              <div className="gate-hs">
                <span className="gate-hs-val">
                  {log.filter((e) => e.method === "manual" && new Date(e.timestamp).toDateString() === new Date().toDateString()).length}
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

        <div className="gate-body">
          <div className="gate-cards">
            {gates.map((gate) => (
              <div key={gate.id} className="gate-card">
                <div className="gate-card-name">{gate.name}</div>

                <div className={`gate-ring ${gate.status}`}>
                  <div className="gate-ring-inner">
                    <svg
                      width="32"
                      height="32"
                      viewBox="0 0 24 24"
                      fill="none"
                      stroke={gate.status === "open" ? "#1D9E75" : "#e74c3c"}
                      strokeWidth="1.5"
                    >
                      {gate.status === "open" ? (
                        <>
                          <rect x="3" y="11" width="18" height="11" rx="2" ry="2" />
                          <path d="M7 11V7a5 5 0 0 1 9.9-1" />
                        </>
                      ) : (
                        <>
                          <rect x="3" y="11" width="18" height="11" rx="2" ry="2" />
                          <path d="M7 11V7a5 5 0 0 1 10 0v4" />
                        </>
                      )}
                    </svg>

                    <span className="gate-ring-status">{gate.status === "open" ? "Open" : "Closed"}</span>
                    <span className="gate-ring-since">Since {formatSince(gate.lastChangedAt)}</span>
                  </div>
                </div>

                <div className="gate-last-action">Last action by {gate.lastChangedBy}</div>

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

          <div className="gate-manual">
            <div className="gate-manual-title">Manual entry</div>
            <p className="gate-manual-sub">
              Verify residents and visitors before allowing manual access. Staff entries remain manual.
            </p>

            <form onSubmit={handleManualEntry} className="gate-manual-form">
              <label className="gate-manual-label">Person type</label>

              <div className="gate-type-select">
                {["visitor", "resident", "staff"].map((type) => (
                  <button
                    key={type}
                    type="button"
                    className={`gate-type-option ${form.type === type ? "active" : ""}`}
                    onClick={() => resetManualSelection(type)}
                  >
                    {type === "visitor" ? "👤 Visitor" : type === "resident" ? "🏠 Resident" : "🛠️ Staff"}
                  </button>
                ))}
              </div>

              {form.type === "resident" && (
                <>
                  <label className="gate-manual-label">Search resident</label>

                  <div className="gate-search-box">
                    <input
                      className="gate-manual-input"
                      placeholder="Search by resident name, username or unit"
                      value={residentSearch}
                      onChange={(e) => handleResidentSearch(e.target.value)}
                    />
                  </div>

                  {residentResults.length > 0 && (
                    <div className="gate-search-results">
                      {residentResults.map((resident) => (
                        <div
                          key={resident.id}
                          className="gate-search-item"
                          onClick={() => selectResident(resident)}
                        >
                          <strong>{resident.full_name || resident.username}</strong>
                          <div>{resident.unit_number || "—"} · {resident.email}</div>
                        </div>
                      ))}
                    </div>
                  )}
                </>
              )}

              {form.type === "visitor" && (
                <>
                  <label className="gate-manual-label">Search approved visitor</label>

                  <div className="gate-search-box">
                    <input
                      className="gate-manual-input"
                      placeholder="Search by visitor name or phone"
                      value={visitorSearch}
                      onChange={(e) => handleVisitorSearch(e.target.value)}
                    />
                  </div>

                  {visitorResults.length > 0 && (
                    <div className="gate-search-results">
                      {visitorResults.map((visitor) => (
                        <div
                          key={visitor.id}
                          className="gate-search-item"
                          onClick={() => selectVisitor(visitor)}
                        >
                          <strong>{visitor.visitor_name}</strong>
                          <div>
                            Unit {visitor.unit_number || "-"} · {visitor.resident_username}
                          </div>
                        </div>
                      ))}
                    </div>
                  )}
                </>
              )}

              {form.type === "staff" && (
                <>
                  <label className="gate-manual-label">Staff full name</label>

                  <input
                    className="gate-manual-input"
                    name="visitorName"
                    placeholder="e.g. Ahmed Security"
                    value={form.visitorName}
                    onChange={handleFormChange}
                  />

                  <label className="gate-manual-label">Department / Unit</label>

                  <input
                    className="gate-manual-input"
                    name="unit"
                    placeholder="e.g. Maintenance"
                    value={form.unit}
                    onChange={handleFormChange}
                  />
                </>
              )}

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

              <button type="submit" className="gate-manual-btn" disabled={loading}>
                {loading ? "Logging..." : "Log entry & open gate"}
              </button>
            </form>
          </div>

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
                        <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" />
                        <circle cx="12" cy="7" r="4" />
                      </svg>
                    ) : entry.type === "staff" ? (
                      <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#185FA5" strokeWidth="2">
                        <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" />
                        <circle cx="12" cy="7" r="4" />
                      </svg>
                    ) : (
                      <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#1D9E75" strokeWidth="2">
                        <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
                      </svg>
                    )}
                  </div>

                  <div className="gate-log-info">
                    <div className="gate-log-name">{entry.name}</div>
                    <div className="gate-log-meta">
                      {entry.unit ? `Unit ${entry.unit} · ` : ""}
                      {entry.gate} ·{" "}
                      {entry.method === "qr_code"
                        ? "QR scan"
                        : entry.method === "rfid"
                        ? "RFID"
                        : "Manual"}
                    </div>
                  </div>

                  <div className="gate-log-right">
                    <span
                      className="gate-log-badge"
                      style={{
                        background: typeStyles[entry.type]?.bg || "#f0f0f0",
                        color: typeStyles[entry.type]?.color || "#555",
                      }}
                    >
                      {typeStyles[entry.type]?.label || "Access"}
                    </span>

                    <div className="gate-log-time">{formatTime(entry.timestamp)}</div>
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