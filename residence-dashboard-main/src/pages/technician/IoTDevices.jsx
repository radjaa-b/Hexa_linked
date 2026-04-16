import { useState, useEffect } from "react";
import PageWrapper from "../../components/layout/PageWrapper";
import "./IoTDevices.css";

// ============================================================
// Radja: this page uses:
//   GET /technician/iot/devices — list all IoT devices
//   PATCH /technician/iot/devices/:id/status — mark needs maintenance
//
// For real-time sensor readings use WebSocket:
//   Event: "sensor.reading" → { deviceId, value, unit, timestamp }
//   Event: "device.status_changed" → { deviceId, status }
//
// Expected device shape:
// {
//   id: "uuid",
//   name: "string",
//   type: "temperature"|"humidity"|"motion"|"smoke"|"gate"|"light"|"water_leak",
//   location: "string",
//   status: "online"|"offline"|"error"|"maintenance",
//   battery: number (0-100) or null,
//   lastReading: { value: number, unit: string, timestamp: string },
//   alert: bool
// }
// ============================================================

const mockDevices = [
  { id: "d-01",  name: "Temp sensor A1",    type: "temperature", location: "Building A - Floor 1", status: "online",      battery: 85,  lastReading: { value: 24,   unit: "°C",  timestamp: new Date().toISOString() }, alert: false },
  { id: "d-02",  name: "Smoke detector B3", type: "smoke",       location: "Building B - Floor 3", status: "online",      battery: 62,  lastReading: { value: 0.02, unit: "ppm", timestamp: new Date().toISOString() }, alert: false },
  { id: "d-03",  name: "Motion sensor G1",  type: "motion",      location: "Gate 1",              status: "online",      battery: null,lastReading: { value: 1,    unit: "",    timestamp: new Date().toISOString() }, alert: true  },
  { id: "d-04",  name: "Gate actuator G1",  type: "gate",        location: "Gate 1",              status: "online",      battery: null,lastReading: { value: 1,    unit: "",    timestamp: new Date().toISOString() }, alert: false },
  { id: "d-05",  name: "Temp sensor B2",    type: "temperature", location: "Building B - Floor 2", status: "error",       battery: 20,  lastReading: { value: 38,   unit: "°C",  timestamp: new Date().toISOString() }, alert: true  },
  { id: "d-06",  name: "Humidity sensor P", type: "humidity",    location: "Pool area",           status: "online",      battery: 91,  lastReading: { value: 72,   unit: "%",   timestamp: new Date().toISOString() }, alert: false },
  { id: "d-07",  name: "Smoke detector A1", type: "smoke",       location: "Building A - Floor 1", status: "offline",     battery: 5,   lastReading: { value: 0,    unit: "ppm", timestamp: new Date().toISOString() }, alert: false },
  { id: "d-08",  name: "Water leak C3",     type: "water_leak",  location: "Building C - Floor 3", status: "online",      battery: 78,  lastReading: { value: 0,    unit: "",    timestamp: new Date().toISOString() }, alert: false },
  { id: "d-09",  name: "Light sensor PK",   type: "light",       location: "Parking zone A",      status: "online",      battery: null,lastReading: { value: 320,  unit: "lux", timestamp: new Date().toISOString() }, alert: false },
  { id: "d-10",  name: "Motion sensor B1",  type: "motion",      location: "Basement",            status: "maintenance", battery: 44,  lastReading: { value: 0,    unit: "",    timestamp: new Date().toISOString() }, alert: false },
  { id: "d-11",  name: "Temp sensor C1",    type: "temperature", location: "Building C - Floor 1", status: "online",      battery: 67,  lastReading: { value: 22,   unit: "°C",  timestamp: new Date().toISOString() }, alert: false },
  { id: "d-12",  name: "Gate actuator G2",  type: "gate",        location: "Gate 2",              status: "online",      battery: null,lastReading: { value: 0,    unit: "",    timestamp: new Date().toISOString() }, alert: false },
];

const typeConfig = {
  temperature: { label: "Temperature", icon: "temp",   color: "#e67e22", bg: "#fdf0e0" },
  humidity:    { label: "Humidity",    icon: "drop",   color: "#185FA5", bg: "#E6F1FB" },
  motion:      { label: "Motion",      icon: "motion", color: "#854F0B", bg: "#faeeda" },
  smoke:       { label: "Smoke",       icon: "smoke",  color: "#e74c3c", bg: "#fdf0f0" },
  gate:        { label: "Gate",        icon: "gate",   color: "#0F6E56", bg: "#edfaf5" },
  light:       { label: "Light",       icon: "light",  color: "#854F0B", bg: "#faeeda" },
  water_leak:  { label: "Water leak",  icon: "water",  color: "#185FA5", bg: "#E6F1FB" },
};

const statusConfig = {
  online:      { label: "Online",      color: "#0F6E56", bg: "#edfaf5"  },
  offline:     { label: "Offline",     color: "#888",    bg: "#f5f5f5"  },
  error:       { label: "Error",       color: "#e74c3c", bg: "#fdf0f0"  },
  maintenance: { label: "Maintenance", color: "#854F0B", bg: "#faeeda"  },
};

const DeviceIcon = ({ type, color }) => {
  const s = { width: 18, height: 18 };
  if (type === "temperature") return (
    <svg {...s} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2">
      <path d="M14 14.76V3.5a2.5 2.5 0 0 0-5 0v11.26a4.5 4.5 0 1 0 5 0z"/>
    </svg>
  );
  if (type === "humidity") return (
    <svg {...s} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2">
      <path d="M12 2v1M12 21v1M4.22 4.22l.7.7M18.36 18.36l.7.7M2 12h1M21 12h1M4.22 19.78l.7-.7M18.36 5.64l.7-.7"/>
      <circle cx="12" cy="12" r="4"/>
    </svg>
  );
  if (type === "motion") return (
    <svg {...s} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2">
      <circle cx="12" cy="12" r="3"/>
      <path d="M12 1v4M12 19v4M4.22 4.22l2.83 2.83M16.95 16.95l2.83 2.83M1 12h4M19 12h4M4.22 19.78l2.83-2.83M16.95 7.05l2.83-2.83"/>
    </svg>
  );
  if (type === "smoke") return (
    <svg {...s} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2">
      <path d="M8 8a4 4 0 0 1 8 0c0 3-2 4-2 7h-4c0-3-2-4-2-7z"/>
      <path d="M10 19h4M11 22h2"/>
    </svg>
  );
  if (type === "gate") return (
    <svg {...s} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2">
      <rect x="3" y="11" width="18" height="11" rx="2"/>
      <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
    </svg>
  );
  if (type === "light") return (
    <svg {...s} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2">
      <circle cx="12" cy="12" r="4"/>
      <path d="M12 2v2M12 20v2M4.93 4.93l1.41 1.41M17.66 17.66l1.41 1.41M2 12h2M20 12h2M4.93 19.07l1.41-1.41M17.66 6.34l1.41-1.41"/>
    </svg>
  );
  return (
    <svg {...s} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2">
      <path d="M12 2v6l3 3"/>
      <circle cx="12" cy="14" r="8"/>
    </svg>
  );
};

// Simulate live readings
const useSimulatedReadings = (devices) => {
  const [readings, setReadings] = useState({});

  useEffect(() => {
    // Radja: replace this with real WebSocket event "sensor.reading"
    const interval = setInterval(() => {
      const updates = {};
      devices.forEach((d) => {
        if (d.status !== "online") return;
        let val = d.lastReading.value;
        if (d.type === "temperature") val = +(val + (Math.random() - 0.5) * 0.5).toFixed(1);
        if (d.type === "humidity")    val = Math.min(100, Math.max(0, +(val + (Math.random() - 0.5) * 1).toFixed(1)));
        if (d.type === "light")       val = Math.max(0, Math.round(val + (Math.random() - 0.5) * 10));
        updates[d.id] = { value: val, timestamp: new Date().toISOString() };
      });
      setReadings((prev) => ({ ...prev, ...updates }));
    }, 2000);
    return () => clearInterval(interval);
  }, [devices]);

  return readings;
};

const formatReading = (device, liveVal) => {
  const val = liveVal !== undefined ? liveVal : device.lastReading.value;
  if (device.type === "motion")     return val ? "Motion detected" : "No motion";
  if (device.type === "gate")       return val ? "Open" : "Closed";
  if (device.type === "water_leak") return val ? "Leak detected!" : "No leak";
  return `${val} ${device.lastReading.unit}`;
};

const isReadingAlert = (device, liveVal) => {
  const val = liveVal !== undefined ? liveVal : device.lastReading.value;
  if (device.type === "temperature" && val > 35) return true;
  if (device.type === "humidity"    && val > 85) return true;
  if (device.type === "smoke"       && val > 0.05) return true;
  if (device.type === "water_leak"  && val > 0) return true;
  return device.alert;
};

const IoTDevices = () => {
  const [devices,     setDevices]     = useState(mockDevices);
  const [filter,      setFilter]      = useState("all");
  const [typeFilter,  setTypeFilter]  = useState("all");
  const liveReadings  = useSimulatedReadings(devices);

  const onlineCount  = devices.filter((d) => d.status === "online").length;
  const errorCount   = devices.filter((d) => d.status === "error").length;
  const offlineCount = devices.filter((d) => d.status === "offline").length;
  const alertCount   = devices.filter((d) => isReadingAlert(d, liveReadings[d.id]?.value)).length;

  const filtered = devices.filter((d) => {
    const matchStatus = filter === "all" ? true : d.status === filter;
    const matchType   = typeFilter === "all" ? true : d.type === typeFilter;
    return matchStatus && matchType;
  });

  const handleMarkMaintenance = (id) => {
    // Radja: PATCH /technician/iot/devices/:id/status { status: "maintenance" }
    setDevices((prev) =>
      prev.map((d) => d.id === id ? { ...d, status: "maintenance" } : d)
    );
  };

  const handleMarkOnline = (id) => {
    // Radja: PATCH /technician/iot/devices/:id/status { status: "online" }
    setDevices((prev) =>
      prev.map((d) => d.id === id ? { ...d, status: "online" } : d)
    );
  };

  return (
    <PageWrapper>
      <div className="iot-layout">

        {/* ── Hero ── */}
        <div className="iot-hero">
          <div className="iot-hero-hex">
            <svg width="160" height="140" viewBox="0 0 160 140" fill="none">
              <path d="M80 8L144 44V116L80 152L16 116V44L80 8Z"
                stroke="white" strokeWidth="1" opacity="0.15"/>
              <path d="M80 32L120 55V101L80 124L40 101V55L80 32Z"
                stroke="white" strokeWidth="0.8" opacity="0.1"/>
            </svg>
          </div>
          <div>
            <div className="iot-hero-tag">Technician</div>
            <div className="iot-hero-title">
              IoT Devices
              {alertCount > 0 && (
                <span className="iot-alert-badge">{alertCount} alerts</span>
              )}
            </div>
            <div className="iot-hero-stats">
              <div className="iot-hs">
                <span className="iot-hs-val">{devices.length}</span>
                <span className="iot-hs-label">Total devices</span>
              </div>
              <div className="iot-hs-div"/>
              <div className="iot-hs">
                <span className="iot-hs-val" style={{ color: "#5DCAA5" }}>{onlineCount}</span>
                <span className="iot-hs-label">Online</span>
              </div>
              <div className="iot-hs-div"/>
              <div className="iot-hs">
                <span className="iot-hs-val" style={{ color: "#f08080" }}>{errorCount}</span>
                <span className="iot-hs-label">Error</span>
              </div>
              <div className="iot-hs-div"/>
              <div className="iot-hs">
                <span className="iot-hs-val" style={{ color: "#aaa" }}>{offlineCount}</span>
                <span className="iot-hs-label">Offline</span>
              </div>
            </div>
          </div>
        </div>

        {/* ── Filters ── */}
        <div className="iot-filters">
          <div className="iot-status-filters">
            {["all", "online", "error", "offline", "maintenance"].map((f) => (
              <button
                key={f}
                className={`iot-filter-btn ${filter === f ? "active" : ""}`}
                onClick={() => setFilter(f)}
              >
                {f.charAt(0).toUpperCase() + f.slice(1)}
                {f === "error" && errorCount > 0 && (
                  <span className="iot-filter-dot"/>
                )}
              </button>
            ))}
          </div>
          <select
            className="iot-type-filter"
            value={typeFilter}
            onChange={(e) => setTypeFilter(e.target.value)}
          >
            <option value="all">All types</option>
            <option value="temperature">Temperature</option>
            <option value="humidity">Humidity</option>
            <option value="motion">Motion</option>
            <option value="smoke">Smoke</option>
            <option value="gate">Gate</option>
            <option value="light">Light</option>
            <option value="water_leak">Water leak</option>
          </select>
        </div>

        {/* ── Device grid ── */}
        <div className="iot-grid">
          {filtered.map((device) => {
            const liveVal    = liveReadings[device.id]?.value;
            const isAlert    = isReadingAlert(device, liveVal);
            const reading    = formatReading(device, liveVal);
            const tc         = typeConfig[device.type];
            const sc         = statusConfig[device.status];

            return (
              <div
                key={device.id}
                className={`iot-card ${device.status} ${isAlert ? "alert" : ""}`}
              >
                {/* Top */}
                <div className="iot-card-top">
                  <div
                    className="iot-card-icon"
                    style={{ background: tc.bg }}
                  >
                    <DeviceIcon type={device.type} color={tc.color}/>
                  </div>
                  <div className="iot-card-info">
                    <div className="iot-card-name">{device.name}</div>
                    <div className="iot-card-location">{device.location}</div>
                  </div>
                  <span
  className="iot-status-badge"
  style={{
    background: device.status === "online"
      ? "rgba(29,158,117,0.2)"
      : device.status === "error"
      ? "rgba(231,76,60,0.2)"
      : device.status === "maintenance"
      ? "rgba(239,159,39,0.2)"
      : "rgba(255,255,255,0.07)",
    color: device.status === "online"
      ? "#5DCAA5"
      : device.status === "error"
      ? "#f08080"
      : device.status === "maintenance"
      ? "#EF9F27"
      : "rgba(255,255,255,0.3)",
  }}
>
  {sc.label}
</span>
                </div>

                {/* Reading */}
                <div className={`iot-reading ${isAlert ? "alert" : ""}`}>
                  <span className="iot-reading-val">{reading}</span>
                  <span className="iot-reading-label">{tc.label}</span>
                </div>

                {/* Battery */}
                {device.battery !== null && (
                  <div className="iot-battery">
                    <div className="iot-battery-bar-wrap">
                      <div
                        className="iot-battery-bar"
                        style={{
                          width: `${device.battery}%`,
                          background: device.battery < 20
                            ? "#e74c3c"
                            : device.battery < 50
                            ? "#e67e22"
                            : "#1D9E75",
                        }}
                      />
                    </div>
                    <span className="iot-battery-label">{device.battery}%</span>
                  </div>
                )}

                {/* Actions */}
                <div className="iot-card-actions">
                  {device.status === "online" || device.status === "error" ? (
                    <button
                      className="iot-maint-btn"
                      onClick={() => handleMarkMaintenance(device.id)}
                    >
                      Mark for maintenance
                    </button>
                  ) : device.status === "maintenance" ? (
                    <button
                      className="iot-online-btn"
                      onClick={() => handleMarkOnline(device.id)}
                    >
                      Mark as fixed
                    </button>
                  ) : null}
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </PageWrapper>
  );
};

export default IoTDevices;