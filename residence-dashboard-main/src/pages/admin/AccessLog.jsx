import { useEffect, useMemo, useState } from "react";
import PageWrapper from "../../components/layout/PageWrapper";
import { getVisitorAccessLogs } from "../../services/visitorRequestsService";
import { getSecurityAccessLogs } from "../../services/accessLogService";
import "./AccessLog.css";

const formatDateValue = (value) => {
  const d = new Date(value);
  if (Number.isNaN(d.getTime())) return "";
  return d.toISOString().split("T")[0];
};

const todayStr = formatDateValue(new Date().toISOString());
const weekAgoStr = "2020-01-01";

const formatDateTime = (value) => {
  const d = new Date(value);

  if (Number.isNaN(d.getTime())) {
    return { date: "Unknown date", time: "—" };
  }

  return {
    date: d.toLocaleDateString("en-GB", {
      day: "numeric",
      month: "short",
      year: "numeric",
    }),
    time: d.toLocaleTimeString("en-GB", {
      hour: "2-digit",
      minute: "2-digit",
    }),
  };
};

const getInitials = (name = "User") =>
  name
    .split(" ")
    .map((part) => part[0])
    .join("")
    .slice(0, 2)
    .toUpperCase();

const statusStyles = {
  PENDING: { bg: "#fdf0e0", color: "#854F0B" },
  APPROVED: { bg: "#edfaf5", color: "#0F6E56" },
  REJECTED: { bg: "#fdecec", color: "#b42318" },
  ARRIVED: { bg: "#e6f7f4", color: "#0e766e" },
  EXITED: { bg: "#f0f0f0", color: "#666" },
  MANUAL: { bg: "#fdf0e0", color: "#854F0B" },
};

const parseSecuritySource = (entry) => {
  const source = entry.source || "";

  if (!source.startsWith("manual_")) {
    return {
      id: `security-${entry.id}`,
      originalId: entry.id,
      type: "resident",
      name: "RFID / IoT entry",
      unit: "—",
      gate: entry.gate_id || "—",
      status: entry.access_status || "granted",
      timestamp: entry.event_time,
      method: source || "unknown",
    };
  }

  const [rawType, name, unit] = source.split("|");
  const type = rawType.replace("manual_", "");

  return {
    id: `security-${entry.id}`,
    originalId: entry.id,
    type,
    name: name || "Unknown",
    unit: unit && unit !== "-" ? unit : "—",
    gate: entry.gate_id || "—",
    status: entry.access_status || "granted",
    timestamp: entry.event_time,
    method: "Manual",
  };
};

const makeManualVisitorLog = (entry) => ({
  id: entry.id,
  visitor_name: entry.name,
  resident_username: "Manual entry",
  unit_number: entry.unit,
  visit_date: formatDateValue(entry.timestamp),
  created_at: entry.timestamp,
  status: "MANUAL",
  action: "MANUAL",
  gate: entry.gate,
});

const groupByDate = (entries) => {
  const groups = {};

  entries.forEach((entry) => {
    const date = formatDateTime(entry.created_at || entry.timestamp).date;
    if (!groups[date]) groups[date] = [];
    groups[date].push(entry);
  });

  return groups;
};

const AccessLog = () => {
  const [fromDate, setFromDate] = useState(weekAgoStr);
  const [toDate, setToDate] = useState(todayStr);
  const [search, setSearch] = useState("");

  const [visitorLogs, setVisitorLogs] = useState([]);
  const [loadingVisitors, setLoadingVisitors] = useState(true);
  const [visitorError, setVisitorError] = useState("");

  const [securityLogs, setSecurityLogs] = useState([]);
  const [loadingSecurityLogs, setLoadingSecurityLogs] = useState(true);
  const [securityLogError, setSecurityLogError] = useState("");

  const loadVisitorLogs = async (silent = false) => {
    try {
      if (!silent) setLoadingVisitors(true);
      setVisitorError("");

      const data = await getVisitorAccessLogs();
      setVisitorLogs(Array.isArray(data) ? data : []);
    } catch (error) {
      console.error("Failed to load visitor logs:", error);
      setVisitorLogs([]);
      setVisitorError("Failed to load visitor logs.");
    } finally {
      if (!silent) setLoadingVisitors(false);
    }
  };

  const loadSecurityLogs = async (silent = false) => {
    try {
      if (!silent) setLoadingSecurityLogs(true);
      setSecurityLogError("");

      const data = await getSecurityAccessLogs();
      const normalized = Array.isArray(data)
        ? data.map(parseSecuritySource)
        : [];

      setSecurityLogs(normalized);
    } catch (error) {
      console.error("Failed to load security access logs:", error);
      setSecurityLogs([]);
      setSecurityLogError("Failed to load security access logs.");
    } finally {
      if (!silent) setLoadingSecurityLogs(false);
    }
  };

  useEffect(() => {
    loadVisitorLogs();
    loadSecurityLogs();

    const interval = setInterval(() => {
      loadVisitorLogs(true);
      loadSecurityLogs(true);
    }, 5000);

    return () => clearInterval(interval);
  }, []);

  const manualVisitorLogs = useMemo(() => {
    return securityLogs
      .filter((entry) => entry.type === "visitor")
      .map(makeManualVisitorLog);
  }, [securityLogs]);

  const manualResidentStaffLogs = useMemo(() => {
    return securityLogs.filter((entry) => entry.type !== "visitor");
  }, [securityLogs]);

  const allVisitorLogs = useMemo(() => {
    return [...manualVisitorLogs, ...visitorLogs];
  }, [manualVisitorLogs, visitorLogs]);

  const filteredManualLogs = useMemo(() => {
    return manualResidentStaffLogs.filter((entry) => {
      const entryDate = formatDateValue(entry.timestamp);
      const matchDate =
        entryDate && entryDate >= fromDate && entryDate <= toDate;

      const text = `${entry.name || ""} ${entry.unit || ""} ${entry.type || ""} ${
        entry.gate || ""
      }`.toLowerCase();

      const matchSearch =
        search.trim() === "" || text.includes(search.toLowerCase());

      return matchDate && matchSearch;
    });
  }, [manualResidentStaffLogs, fromDate, toDate, search]);

  const filteredVisitorLogs = useMemo(() => {
    return allVisitorLogs.filter((entry) => {
      const entryDate = formatDateValue(entry.created_at || entry.timestamp);
      const matchDate =
        entryDate && entryDate >= fromDate && entryDate <= toDate;

      const text = `${entry.visitor_name || ""} ${
        entry.resident_username || ""
      } ${entry.unit_number || ""} ${entry.status || ""} ${
        entry.action || ""
      }`.toLowerCase();

      const matchSearch =
        search.trim() === "" || text.includes(search.toLowerCase());

      return matchDate && matchSearch;
    });
  }, [allVisitorLogs, fromDate, toDate, search]);

  const groupedVisitors = groupByDate(filteredVisitorLogs);

  const todayManualCount = filteredManualLogs.filter(
    (e) => formatDateValue(e.timestamp) === todayStr
  ).length;

  const todayVisitorCount = allVisitorLogs.filter(
    (e) => formatDateValue(e.created_at || e.timestamp) === todayStr
  ).length;

  const statusCounts = useMemo(() => {
    return filteredVisitorLogs.reduce((acc, item) => {
      const status = item.action || item.status || "UNKNOWN";
      acc[status] = (acc[status] || 0) + 1;
      return acc;
    }, {});
  }, [filteredVisitorLogs]);

  const maxChartValue = Math.max(1, ...Object.values(statusCounts));

  return (
    <PageWrapper>
      <div className="log-layout">
        <div className="log-hero">
          <div className="log-hero-hex">
            <svg width="160" height="140" viewBox="0 0 160 140" fill="none">
              <path
                d="M80 8L144 44V116L80 152L16 116V44L80 8Z"
                stroke="white"
                strokeWidth="1"
                opacity="0.15"
              />
              <path
                d="M80 32L120 55V101L80 124L40 101V55L80 32Z"
                stroke="white"
                strokeWidth="0.8"
                opacity="0.1"
              />
            </svg>
          </div>

          <div>
            <div className="log-hero-tag">Security</div>
            <div className="log-hero-title">Access Log</div>

            <div className="log-hero-stats">
              <div className="log-hs">
                <span className="log-hs-val">{todayManualCount}</span>
                <span className="log-hs-label">Manual entries today</span>
              </div>

              <div className="log-hs-div" />

              <div className="log-hs">
                <span className="log-hs-val">{todayVisitorCount}</span>
                <span className="log-hs-label">Visitors today</span>
              </div>

              <div className="log-hs-div" />

              <div className="log-hs">
                <span className="log-hs-val">{filteredVisitorLogs.length}</span>
                <span className="log-hs-label">Visitor logs shown</span>
              </div>
            </div>
          </div>
        </div>

        <div className="log-filters">
          <div className="log-search">
            <svg
              width="13"
              height="13"
              viewBox="0 0 24 24"
              fill="none"
              stroke="#aaa"
              strokeWidth="2"
            >
              <circle cx="11" cy="11" r="8" />
              <line x1="21" y1="21" x2="16.65" y2="16.65" />
            </svg>

            <input
              placeholder="Search by visitor, resident, unit or status..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
            />
          </div>

          <div className="log-date-filters">
            <div className="log-date-field">
              <label>From</label>
              <input
                type="date"
                value={fromDate}
                onChange={(e) => setFromDate(e.target.value)}
              />
            </div>

            <div className="log-date-sep">→</div>

            <div className="log-date-field">
              <label>To</label>
              <input
                type="date"
                value={toDate}
                onChange={(e) => setToDate(e.target.value)}
              />
            </div>
          </div>
        </div>

        <div className="log-table-wrap">
          <div className="log-section-card">
            <div className="log-section-head">
              <div>
                <h3>Manual / resident access</h3>
                <p>Manual resident and staff entries submitted by security agents.</p>
              </div>

              <span className="log-section-pill active">
                {filteredManualLogs.length} logs
              </span>
            </div>

            {loadingSecurityLogs ? (
              <div className="log-empty">Loading security logs...</div>
            ) : securityLogError ? (
              <div className="log-empty">{securityLogError}</div>
            ) : filteredManualLogs.length === 0 ? (
              <div className="log-empty">No manual resident/staff entries yet</div>
            ) : (
              <table className="log-table">
                <thead>
                  <tr>
                    <th>Person</th>
                    <th>Type</th>
                    <th>Unit</th>
                    <th>Gate</th>
                    <th>Status</th>
                    <th>Time</th>
                  </tr>
                </thead>

                <tbody>
                  {filteredManualLogs.map((entry) => {
                    const { time } = formatDateTime(entry.timestamp);

                    return (
                      <tr key={entry.id}>
                        <td>
                          <div className="log-person">
                            <div className="log-person-avatar">
                              {getInitials(entry.name)}
                            </div>
                            <span className="log-person-name">{entry.name}</span>
                          </div>
                        </td>

                        <td className="log-unit">
                          {entry.type === "staff" ? "Staff" : "Resident"}
                        </td>

                        <td className="log-unit">{entry.unit}</td>
                        <td className="log-unit">{entry.gate}</td>

                        <td>
                          <span
                            className="log-badge"
                            style={{
                              background:
                                entry.status === "granted"
                                  ? "#edfaf5"
                                  : "#fdecec",
                              color:
                                entry.status === "granted"
                                  ? "#0F6E56"
                                  : "#b42318",
                            }}
                          >
                            {entry.status}
                          </span>
                        </td>

                        <td className="log-time">{time}</td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            )}
          </div>

          <div className="log-section-card">
            <div className="log-section-head">
              <div>
                <h3>Visitor access</h3>
                <p>Visitor requests and manual visitor gate activity.</p>
              </div>

              <span className="log-section-pill active">
                {filteredVisitorLogs.length} logs
              </span>
            </div>

            <div className="visitor-chart-card">
              <div className="visitor-chart-title">Visitor status overview</div>

              {Object.keys(statusCounts).length === 0 ? (
                <div className="visitor-chart-empty">No chart data yet</div>
              ) : (
                <div className="visitor-chart">
                  {Object.entries(statusCounts).map(([status, count]) => (
                    <div key={status} className="visitor-chart-row">
                      <span className="visitor-chart-label">{status}</span>

                      <div className="visitor-chart-track">
                        <div
                          className={`visitor-chart-bar ${status}`}
                          style={{
                            width: `${Math.max(
                              10,
                              (count / maxChartValue) * 100
                            )}%`,
                          }}
                        />
                      </div>

                      <span className="visitor-chart-count">{count}</span>
                    </div>
                  ))}
                </div>
              )}
            </div>

            {loadingVisitors ? (
              <div className="log-empty">Loading visitor logs...</div>
            ) : visitorError ? (
              <div className="log-empty">{visitorError}</div>
            ) : Object.keys(groupedVisitors).length === 0 ? (
              <div className="log-empty">
                No visitor entries found for this period
              </div>
            ) : (
              Object.entries(groupedVisitors).map(([date, entries]) => (
                <div key={date} className="log-group">
                  <div className="log-group-label">
                    {date}
                    <span className="log-group-count">
                      {entries.length} visitor entries
                    </span>
                  </div>

                  <table className="log-table">
                    <thead>
                      <tr>
                        <th>Visitor</th>
                        <th>Status</th>
                        <th>Resident</th>
                        <th>Unit</th>
                        <th>Visit date</th>
                        <th>Time</th>
                      </tr>
                    </thead>

                    <tbody>
                      {entries.map((entry) => {
                        const { time } = formatDateTime(
                          entry.created_at || entry.timestamp
                        );

                        const displayStatus =
                          entry.action || entry.status || "UNKNOWN";

                        const style =
                          statusStyles[displayStatus] || {
                            bg: "#f0f0f0",
                            color: "#666",
                          };

                        return (
                          <tr key={entry.id} className="log-clickable-row">
                            <td>
                              <div className="log-person">
                                <div className="log-person-avatar visitor">
                                  {getInitials(entry.visitor_name)}
                                </div>

                                <span className="log-person-name">
                                  {entry.visitor_name || "Unknown visitor"}
                                </span>
                              </div>
                            </td>

                            <td>
                              <span
                                className="log-badge"
                                style={{
                                  background: style.bg,
                                  color: style.color,
                                }}
                              >
                                {displayStatus}
                              </span>
                            </td>

                            <td className="log-unit">
                              {entry.resident_username || "—"}
                            </td>

                            <td className="log-unit">
                              {entry.unit_number || "—"}
                            </td>

                            <td className="log-method">
                              {entry.visit_date || "—"}
                            </td>

                            <td className="log-time">{time}</td>
                          </tr>
                        );
                      })}
                    </tbody>
                  </table>
                </div>
              ))
            )}
          </div>
        </div>
      </div>
    </PageWrapper>
  );
};

export default AccessLog;