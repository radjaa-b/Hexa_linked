import { useState } from "react";
import PageWrapper from "../../components/layout/PageWrapper";
import {
  BarChart, Bar, XAxis, YAxis, CartesianGrid,
  Tooltip, ResponsiveContainer, Cell
} from "recharts";
import "./EnergyMonitor.css";

// ============================================================
// Radja: this page uses:
//   GET /technician/energy?period=weekly|monthly
//   GET /technician/energy/history?metric=electricity|water&period=weekly|monthly
//
// Expected shape:
// {
//   zones: [
//     {
//       id: "uuid",
//       name: "Building A",
//       electricity: { current: 450, unit: "kWh", status: "normal"|"high"|"alert" },
//       water:       { current: 120, unit: "m³",  status: "normal" }
//     }
//   ],
//   alerts: [
//     { zone: "Building B", type: "high_consumption", message: "30% above average" }
//   ]
// }
// ============================================================

const mockData = {
  weekly: {
    zones: [
      { id: "1", name: "Building A", electricity: { current: 210, unit: "kWh", status: "normal" }, water: { current: 65,  unit: "m³", status: "normal" } },
      { id: "2", name: "Building B", electricity: { current: 380, unit: "kWh", status: "alert"  }, water: { current: 90,  unit: "m³", status: "high"   } },
      { id: "3", name: "Building C", electricity: { current: 175, unit: "kWh", status: "normal" }, water: { current: 55,  unit: "m³", status: "normal" } },
      { id: "4", name: "Common areas",electricity: { current: 290, unit: "kWh", status: "high"  }, water: { current: 130, unit: "m³", status: "normal" } },
    ],
    alerts: [
      { zone: "Building B",   type: "high_consumption", message: "Electricity 42% above weekly average" },
      { zone: "Building B",   type: "high_consumption", message: "Water 28% above weekly average"       },
      { zone: "Common areas", type: "high_consumption", message: "Electricity 18% above weekly average" },
    ],
    elecHistory: [
      { label: "Mon", value: 145 }, { label: "Tue", value: 160 },
      { label: "Wed", value: 210 }, { label: "Thu", value: 175 },
      { label: "Fri", value: 190 }, { label: "Sat", value: 380 },
      { label: "Sun", value: 195 },
    ],
    waterHistory: [
      { label: "Mon", value: 55 }, { label: "Tue", value: 60 },
      { label: "Wed", value: 90 }, { label: "Thu", value: 65 },
      { label: "Fri", value: 70 }, { label: "Sat", value: 85 },
      { label: "Sun", value: 75 },
    ],
  },
  monthly: {
    zones: [
      { id: "1", name: "Building A",  electricity: { current: 890,  unit: "kWh", status: "normal" }, water: { current: 280, unit: "m³", status: "normal" } },
      { id: "2", name: "Building B",  electricity: { current: 1540, unit: "kWh", status: "alert"  }, water: { current: 390, unit: "m³", status: "high"   } },
      { id: "3", name: "Building C",  electricity: { current: 720,  unit: "kWh", status: "normal" }, water: { current: 220, unit: "m³", status: "normal" } },
      { id: "4", name: "Common areas",electricity: { current: 1180, unit: "kWh", status: "high"   }, water: { current: 510, unit: "m³", status: "normal" } },
    ],
    alerts: [
      { zone: "Building B",   type: "high_consumption", message: "Electricity 38% above monthly average" },
      { zone: "Building B",   type: "high_consumption", message: "Water 25% above monthly average"       },
      { zone: "Common areas", type: "high_consumption", message: "Electricity 15% above monthly average" },
    ],
    elecHistory: [
      { label: "Jan", value: 780  }, { label: "Feb", value: 820  },
      { label: "Mar", value: 910  }, { label: "Apr", value: 890  },
      { label: "May", value: 1100 }, { label: "Jun", value: 1540 },
      { label: "Jul", value: 980  }, { label: "Aug", value: 1050 },
      { label: "Sep", value: 870  }, { label: "Oct", value: 940  },
      { label: "Nov", value: 1200 }, { label: "Dec", value: 1180 },
    ],
    waterHistory: [
      { label: "Jan", value: 260 }, { label: "Feb", value: 280 },
      { label: "Mar", value: 320 }, { label: "Apr", value: 300 },
      { label: "May", value: 390 }, { label: "Jun", value: 510 },
      { label: "Jul", value: 340 }, { label: "Aug", value: 360 },
      { label: "Sep", value: 290 }, { label: "Oct", value: 310 },
      { label: "Nov", value: 400 }, { label: "Dec", value: 380 },
    ],
  },
};

const statusConfig = {
  normal: { label: "Normal", bg: "#edfaf5", color: "#0F6E56" },
  high:   { label: "High",   bg: "#fdf0e0", color: "#854F0B" },
  alert:  { label: "Alert",  bg: "#fdf0f0", color: "#e74c3c" },
};

const barTooltip = ({ active, payload, label }) => {
  if (!active || !payload?.length) return null;
  return (
    <div className="em-tooltip">
      <div className="em-tooltip-label">{label}</div>
      <div className="em-tooltip-val">{payload[0].value}</div>
    </div>
  );
};

const EnergyMonitor = () => {
  const [period, setPeriod] = useState("weekly");
  const data = mockData[period];

  const totalElec  = data.zones.reduce((sum, z) => sum + z.electricity.current, 0);
  const totalWater = data.zones.reduce((sum, z) => sum + z.water.current, 0);
  const alertZones = data.zones.filter((z) =>
    z.electricity.status !== "normal" || z.water.status !== "normal"
  ).length;

  return (
    <PageWrapper>
      <div className="em-layout">

        {/* ── Hero ── */}
        <div className="em-hero">
          <div className="em-hero-hex">
            <svg width="160" height="140" viewBox="0 0 160 140" fill="none">
              <path d="M80 8L144 44V116L80 152L16 116V44L80 8Z"
                stroke="white" strokeWidth="1" opacity="0.15"/>
              <path d="M80 32L120 55V101L80 124L40 101V55L80 32Z"
                stroke="white" strokeWidth="0.8" opacity="0.1"/>
            </svg>
          </div>
          <div>
            <div className="em-hero-tag">Technician</div>
            <div className="em-hero-title">
              Energy Monitor
              {alertZones > 0 && (
                <span className="em-alert-badge">{alertZones} zones need attention</span>
              )}
            </div>
            <div className="em-hero-stats">
              <div className="em-hs">
                <span className="em-hs-val">{totalElec.toLocaleString()}</span>
                <span className="em-hs-label">Total kWh</span>
              </div>
              <div className="em-hs-div" />
              <div className="em-hs">
                <span className="em-hs-val">{totalWater}</span>
                <span className="em-hs-label">Total m³</span>
              </div>
              <div className="em-hs-div" />
              <div className="em-hs">
                <span className="em-hs-val">{data.zones.length}</span>
                <span className="em-hs-label">Zones</span>
              </div>
              <div className="em-hs-div" />
              <div className="em-hs">
                <span className="em-hs-val" style={{ color: "#f08080" }}>
                  {data.alerts.length}
                </span>
                <span className="em-hs-label">Active alerts</span>
              </div>
            </div>
          </div>
          <div className="em-toggle">
            <button
              className={`em-tog ${period === "weekly" ? "active" : ""}`}
              onClick={() => setPeriod("weekly")}
            >Weekly</button>
            <button
              className={`em-tog ${period === "monthly" ? "active" : ""}`}
              onClick={() => setPeriod("monthly")}
            >Monthly</button>
          </div>
        </div>

        {/* ── Alerts ── */}
        {data.alerts.length > 0 && (
          <div className="em-alerts">
            {data.alerts.map((alert, i) => (
              <div key={i} className="em-alert">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none"
                  stroke="#e67e22" strokeWidth="2">
                  <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/>
                  <line x1="12" y1="9" x2="12" y2="13"/>
                  <line x1="12" y1="17" x2="12.01" y2="17"/>
                </svg>
                <span className="em-alert-zone">{alert.zone}</span>
                <span className="em-alert-msg">{alert.message}</span>
              </div>
            ))}
          </div>
        )}

        {/* ── Zone cards ── */}
        <div className="em-zones">
          {data.zones.map((zone) => (
            <div key={zone.id} className={`em-zone ${zone.electricity.status === "alert" ? "alert" : zone.electricity.status === "high" ? "high" : ""}`}>
              <div className="em-zone-head">
                <span className="em-zone-name">{zone.name}</span>
                <span
                  className="em-zone-status"
                  style={{
                    background: statusConfig[zone.electricity.status].bg,
                    color: statusConfig[zone.electricity.status].color,
                  }}
                >
                  {statusConfig[zone.electricity.status].label}
                </span>
              </div>
              <div className="em-zone-metrics">
                <div className="em-zone-metric">
                  <div className="em-zone-metric-val">
                    {zone.electricity.current.toLocaleString()}
                    <span className="em-zone-unit">{zone.electricity.unit}</span>
                  </div>
                  <div className="em-zone-metric-label">Electricity</div>
                  <div className="em-zone-bar-wrap">
                    <div
                      className="em-zone-bar elec"
                      style={{ width: `${Math.min((zone.electricity.current / 1600) * 100, 100)}%` }}
                    />
                  </div>
                </div>
                <div className="em-zone-divider" />
                <div className="em-zone-metric">
                  <div className="em-zone-metric-val">
                    {zone.water.current}
                    <span className="em-zone-unit">{zone.water.unit}</span>
                  </div>
                  <div className="em-zone-metric-label">Water</div>
                  <div className="em-zone-bar-wrap">
                    <div
                      className="em-zone-bar water"
                      style={{ width: `${Math.min((zone.water.current / 550) * 100, 100)}%` }}
                    />
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* ── Charts ── */}
        <div className="em-charts">
          <div className="em-chart-card">
            <div className="em-chart-head">
              <span className="em-chart-title">Electricity — all zones</span>
              <span className="em-chart-sub">
                {period === "weekly" ? "kWh per day" : "kWh per month"}
              </span>
            </div>
            <ResponsiveContainer width="100%" height={200}>
              <BarChart data={data.elecHistory} barSize={period === "monthly" ? 18 : 28}>
                <CartesianGrid vertical={false} stroke="#f0f0ec"/>
                <XAxis dataKey="label" tick={{ fontSize: 10, fill: "#aaa" }}
                  axisLine={false} tickLine={false}/>
                <YAxis tick={{ fontSize: 10, fill: "#aaa" }}
                  axisLine={false} tickLine={false} width={35}/>
                <Tooltip content={barTooltip} cursor={{ fill: "rgba(0,0,0,0.04)" }}/>
                <Bar dataKey="value" radius={[5, 5, 0, 0]}>
                  {data.elecHistory.map((entry, i) => (
                    <Cell
                      key={i}
                      fill={entry.value === Math.max(...data.elecHistory.map(d => d.value))
                        ? "#e74c3c" : "#1D9E75"}
                    />
                  ))}
                </Bar>
              </BarChart>
            </ResponsiveContainer>
          </div>

          <div className="em-chart-card">
            <div className="em-chart-head">
              <span className="em-chart-title">Water — all zones</span>
              <span className="em-chart-sub">
                {period === "weekly" ? "m³ per day" : "m³ per month"}
              </span>
            </div>
            <ResponsiveContainer width="100%" height={200}>
              <BarChart data={data.waterHistory} barSize={period === "monthly" ? 18 : 28}>
                <CartesianGrid vertical={false} stroke="#f0f0ec"/>
                <XAxis dataKey="label" tick={{ fontSize: 10, fill: "#aaa" }}
                  axisLine={false} tickLine={false}/>
                <YAxis tick={{ fontSize: 10, fill: "#aaa" }}
                  axisLine={false} tickLine={false} width={35}/>
                <Tooltip content={barTooltip} cursor={{ fill: "rgba(0,0,0,0.04)" }}/>
                <Bar dataKey="value" radius={[5, 5, 0, 0]}>
                  {data.waterHistory.map((entry, i) => (
                    <Cell
                      key={i}
                      fill={entry.value === Math.max(...data.waterHistory.map(d => d.value))
                        ? "#e74c3c" : "#185FA5"}
                    />
                  ))}
                </Bar>
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>
      </div>
    </PageWrapper>
  );
};

export default EnergyMonitor;