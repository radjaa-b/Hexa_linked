import { useState } from "react";
import PageWrapper from "../../components/layout/PageWrapper";
import {
  BarChart, Bar, XAxis, YAxis, CartesianGrid,
  Tooltip, ResponsiveContainer, Cell
} from "recharts";
import "./Consumption.css";

// ============================================================
// Radja: this page uses:
//   GET /admin/consumption/overview?period=weekly|monthly
//   GET /technician/energy/history?metric=electricity|water&period=weekly|monthly
//
// Expected shape for overview:
// {
//   electricity: { current: 1240, unit: "kWh", trend: "+5%", up: true,
//                  peak: { value: 89, day: "Wednesday" },
//                  quota: { used: 1240, total: 1720 } },
//   water:       { current: 340,  unit: "m³",  trend: "-2%", up: false,
//                  peak: { value: 28, day: "Saturday" },
//                  quota: { used: 340, total: 600 } }
// }
//
// Expected shape for history:
// [{ label: "Mon", value: 62 }, ...]
// ============================================================

const mockData = {
  weekly: {
    electricity: {
      current: 1240, unit: "kWh", trend: "+5%", up: true,
      peak: { value: 89, day: "Wednesday" },
      quota: { used: 1240, total: 1720 },
      history: [
        { label: "Mon", value: 62 }, { label: "Tue", value: 75 },
        { label: "Wed", value: 89 }, { label: "Thu", value: 71 },
        { label: "Fri", value: 68 }, { label: "Sat", value: 80 },
        { label: "Sun", value: 74 },
      ],
    },
    water: {
      current: 340, unit: "m³", trend: "-2%", up: false,
      peak: { value: 28, day: "Saturday" },
      quota: { used: 340, total: 600 },
      history: [
        { label: "Mon", value: 18 }, { label: "Tue", value: 22 },
        { label: "Wed", value: 28 }, { label: "Thu", value: 20 },
        { label: "Fri", value: 19 }, { label: "Sat", value: 25 },
        { label: "Sun", value: 23 },
      ],
    },
  },
  monthly: {
    electricity: {
      current: 1240, unit: "kWh", trend: "+5%", up: true,
      peak: { value: 1310, day: "November" },
      quota: { used: 1240, total: 1720 },
      history: [
        { label: "Jan", value: 980  }, { label: "Feb", value: 1050 },
        { label: "Mar", value: 1120 }, { label: "Apr", value: 1240 },
        { label: "May", value: 1100 }, { label: "Jun", value: 1300 },
        { label: "Jul", value: 1180 }, { label: "Aug", value: 1240 },
        { label: "Sep", value: 1090 }, { label: "Oct", value: 1200 },
        { label: "Nov", value: 1310 }, { label: "Dec", value: 1240 },
      ],
    },
    water: {
      current: 340, unit: "m³", trend: "-2%", up: false,
      peak: { value: 360, day: "June" },
      quota: { used: 340, total: 600 },
      history: [
        { label: "Jan", value: 290 }, { label: "Feb", value: 310 },
        { label: "Mar", value: 330 }, { label: "Apr", value: 340 },
        { label: "May", value: 300 }, { label: "Jun", value: 360 },
        { label: "Jul", value: 320 }, { label: "Aug", value: 340 },
        { label: "Sep", value: 310 }, { label: "Oct", value: 330 },
        { label: "Nov", value: 350 }, { label: "Dec", value: 340 },
      ],
    },
  },
};

// Donut SVG component — no library needed, clean and lightweight
const DonutGauge = ({ pct, color }) => {
  const r = 36;
  const circ = 2 * Math.PI * r;
  const filled = (pct / 100) * circ;

  return (
    <svg width="90" height="90" viewBox="0 0 90 90">
      <circle cx="45" cy="45" r={r}
        fill="none" stroke="#f0f0ec" strokeWidth="8"/>
      <circle cx="45" cy="45" r={r}
        fill="none" stroke={color} strokeWidth="8"
        strokeDasharray={`${filled} ${circ}`}
        strokeLinecap="round"
        transform="rotate(-90 45 45)"
      />
    </svg>
  );
};

const Consumption = () => {
  const [period, setPeriod] = useState("weekly");

  const data       = mockData[period];
  const elec       = data.electricity;
  const water      = data.water;
  const elecPct    = Math.round((elec.quota.used  / elec.quota.total)  * 100);
  const waterPct   = Math.round((water.quota.used / water.quota.total) * 100);

  // Radja: replace mockData with real API calls:
  // useEffect(() => {
  //   getConsumptionOverview(period).then(res => setOverview(res.data));
  //   getEnergyHistory("electricity", period).then(res => setElecHistory(res.data));
  //   getEnergyHistory("water", period).then(res => setWaterHistory(res.data));
  // }, [period]);

  const barTooltip = ({ active, payload, label }) => {
    if (!active || !payload?.length) return null;
    return (
      <div className="cons-tooltip">
        <div className="cons-tooltip-label">{label}</div>
        <div className="cons-tooltip-val">{payload[0].value}</div>
      </div>
    );
  };

  return (
    <PageWrapper>
      <div className="cons-layout">

        {/* ── Hero ── */}
        <div className="cons-hero">
          <div className="cons-hero-hex">
            <svg width="160" height="140" viewBox="0 0 160 140" fill="none">
              <path d="M80 8L144 44V116L80 152L16 116V44L80 8Z"
                stroke="white" strokeWidth="1" opacity="0.15"/>
              <path d="M80 32L120 55V101L80 124L40 101V55L80 32Z"
                stroke="white" strokeWidth="0.8" opacity="0.1"/>
            </svg>
          </div>
          <div className="cons-hero-tag">Energy & resources</div>
          <div className="cons-hero-title">Consumption Overview</div>
          <div className="cons-toggle">
            <button
              className={`cons-tog ${period === "weekly" ? "active" : ""}`}
              onClick={() => setPeriod("weekly")}
            >
              Weekly
            </button>
            <button
              className={`cons-tog ${period === "monthly" ? "active" : ""}`}
              onClick={() => setPeriod("monthly")}
            >
              Monthly
            </button>
          </div>
        </div>

        {/* ── Stat cards ── */}
        <div className="cons-stats">
          <div className="cons-stat">
            <div className="cons-stat-label">
              Electricity this {period === "weekly" ? "week" : "month"}
            </div>
            <div className="cons-stat-val">
              {elec.current.toLocaleString()}
              <span className="cons-stat-unit">{elec.unit}</span>
            </div>
            <div className={`cons-stat-trend ${elec.up ? "up" : "down"}`}>
              {elec.up ? "↑" : "↓"} {elec.trend} vs last {period === "weekly" ? "week" : "month"}
            </div>
          </div>

          <div className="cons-stat">
            <div className="cons-stat-label">
              Water this {period === "weekly" ? "week" : "month"}
            </div>
            <div className="cons-stat-val">
              {water.current}
              <span className="cons-stat-unit">{water.unit}</span>
            </div>
            <div className={`cons-stat-trend ${water.up ? "up" : "down"}`}>
              {water.up ? "↑" : "↓"} {water.trend} vs last {period === "weekly" ? "week" : "month"}
            </div>
          </div>

          <div className="cons-stat">
            <div className="cons-stat-label">Peak electricity</div>
            <div className="cons-stat-val">
              {elec.peak.value}
              <span className="cons-stat-unit">{elec.unit}</span>
            </div>
            <div className="cons-stat-trend" style={{ color: "#aaa" }}>
              {elec.peak.day}
            </div>
          </div>

          <div className="cons-stat">
            <div className="cons-stat-label">Peak water</div>
            <div className="cons-stat-val">
              {water.peak.value}
              <span className="cons-stat-unit">{water.unit}</span>
            </div>
            <div className="cons-stat-trend" style={{ color: "#aaa" }}>
              {water.peak.day}
            </div>
          </div>
        </div>

        {/* ── Bar charts ── */}
        <div className="cons-charts">

          <div className="cons-chart-card">
            <div className="cons-chart-head">
              <span className="cons-chart-title">Electricity usage</span>
              <span className="cons-chart-sub">
                {period === "weekly" ? "kWh per day" : "kWh per month"}
              </span>
            </div>
            <ResponsiveContainer width="100%" height={200}>
              <BarChart data={elec.history} barSize={period === "monthly" ? 18 : 28}>
                <CartesianGrid vertical={false} stroke="#f0f0ec"/>
                <XAxis dataKey="label" tick={{ fontSize: 10, fill: "#aaa" }}
                  axisLine={false} tickLine={false}/>
                <YAxis tick={{ fontSize: 10, fill: "#aaa" }}
                  axisLine={false} tickLine={false} width={30}/>
                <Tooltip content={barTooltip} cursor={{ fill: "rgba(0,0,0,0.04)" }}/>
                <Bar dataKey="value" radius={[5, 5, 0, 0]}>
                  {elec.history.map((entry, i) => (
                    <Cell
                      key={i}
                      fill={entry.value === Math.max(...elec.history.map(d => d.value))
                        ? "#0F6E56" : "#1D9E75"}
                    />
                  ))}
                </Bar>
              </BarChart>
            </ResponsiveContainer>
          </div>

          <div className="cons-chart-card">
            <div className="cons-chart-head">
              <span className="cons-chart-title">Water usage</span>
              <span className="cons-chart-sub">
                {period === "weekly" ? "m³ per day" : "m³ per month"}
              </span>
            </div>
            <ResponsiveContainer width="100%" height={200}>
              <BarChart data={water.history} barSize={period === "monthly" ? 18 : 28}>
                <CartesianGrid vertical={false} stroke="#f0f0ec"/>
                <XAxis dataKey="label" tick={{ fontSize: 10, fill: "#aaa" }}
                  axisLine={false} tickLine={false}/>
                <YAxis tick={{ fontSize: 10, fill: "#aaa" }}
                  axisLine={false} tickLine={false} width={30}/>
                <Tooltip content={barTooltip} cursor={{ fill: "rgba(0,0,0,0.04)" }}/>
                <Bar dataKey="value" radius={[5, 5, 0, 0]}>
                  {water.history.map((entry, i) => (
                    <Cell
                      key={i}
                      fill={entry.value === Math.max(...water.history.map(d => d.value))
                        ? "#0C447C" : "#185FA5"}
                    />
                  ))}
                </Bar>
              </BarChart>
            </ResponsiveContainer>
          </div>

        </div>

        {/* ── Donut gauges ── */}
        <div className="cons-donuts">

          <div className="cons-donut-card">
            <div className="cons-donut-wrap">
              <DonutGauge pct={elecPct} color="#1D9E75"/>
              <div className="cons-donut-center">
                <span className="cons-donut-val">{elecPct}%</span>
                <span className="cons-donut-pct">used</span>
              </div>
            </div>
            <div className="cons-donut-info">
              <div className="cons-donut-title">Electricity quota</div>
              <div className="cons-donut-sub">
                {elec.quota.used.toLocaleString()} of {elec.quota.total.toLocaleString()} {elec.unit}<br/>
                monthly budget used
              </div>
              <div className="cons-donut-remaining" style={{ color: "#1D9E75" }}>
                {(elec.quota.total - elec.quota.used).toLocaleString()} {elec.unit} remaining
              </div>
            </div>
          </div>

          <div className="cons-donut-card">
            <div className="cons-donut-wrap">
              <DonutGauge pct={waterPct} color="#185FA5"/>
              <div className="cons-donut-center">
                <span className="cons-donut-val">{waterPct}%</span>
                <span className="cons-donut-pct">used</span>
              </div>
            </div>
            <div className="cons-donut-info">
              <div className="cons-donut-title">Water quota</div>
              <div className="cons-donut-sub">
                {water.quota.used} of {water.quota.total} {water.unit}<br/>
                monthly budget used
              </div>
              <div className="cons-donut-remaining" style={{ color: "#185FA5" }}>
                {water.quota.total - water.quota.used} {water.unit} remaining
              </div>
            </div>
          </div>

        </div>
      </div>
    </PageWrapper>
  );
};

export default Consumption;