import { useState } from "react";
import PageWrapper from "../../components/layout/PageWrapper";
import "./AccessLog.css";

// ============================================================
// Radja: this page uses:
//   GET /admin/access-log?from=date&to=date&page=1&limit=20
//
// Expected response shape:
// {
//   data: [
//     {
//       id: "uuid",
//       person: { id, name, type: "resident"|"visitor"|"staff" },
//       type: "entry"|"exit",
//       method: "qr_code"|"manual"|"plate_recognition",
//       unit: "A-12" or null,
//       timestamp: "2026-03-29T08:30:00Z",
//       agentId: "uuid or null"
//     }
//   ],
//   total: 120,
//   page: 1,
//   limit: 20
// }
// ============================================================

const mockLog = [
  { id: "1",  person: { name: "Ahmed Benali",   type: "resident" }, unit: "A-12", type: "entry", method: "qr_code",           timestamp: "2026-03-29T08:30:00Z" },
  { id: "2",  person: { name: "Karima Saidi",   type: "staff"    }, unit: null,   type: "entry", method: "manual",             timestamp: "2026-03-29T08:15:00Z" },
  { id: "3",  person: { name: "Unknown visitor",type: "visitor"  }, unit: null,   type: "entry", method: "manual",             timestamp: "2026-03-29T07:55:00Z" },
  { id: "4",  person: { name: "Youcef Amrani",  type: "resident" }, unit: "B-04", type: "entry", method: "qr_code",           timestamp: "2026-03-29T07:40:00Z" },
  { id: "5",  person: { name: "Sara Bensaid",   type: "resident" }, unit: "A-03", type: "entry", method: "qr_code",           timestamp: "2026-03-29T07:20:00Z" },
  { id: "6",  person: { name: "Farid Belkacem", type: "staff"    }, unit: null,   type: "entry", method: "manual",             timestamp: "2026-03-29T07:00:00Z" },
  { id: "7",  person: { name: "Mourad Kaci",    type: "staff"    }, unit: null,   type: "entry", method: "manual",             timestamp: "2026-03-28T18:30:00Z" },
  { id: "8",  person: { name: "Karim Ouali",    type: "visitor"  }, unit: null,   type: "entry", method: "manual",             timestamp: "2026-03-28T17:00:00Z" },
  { id: "9",  person: { name: "Ahmed Benali",   type: "resident" }, unit: "A-12", type: "entry", method: "qr_code",           timestamp: "2026-03-28T09:10:00Z" },
  { id: "10", person: { name: "Sara Bensaid",   type: "resident" }, unit: "A-03", type: "entry", method: "plate_recognition",  timestamp: "2026-03-28T08:55:00Z" },
  { id: "11", person: { name: "Youcef Amrani",  type: "resident" }, unit: "B-04", type: "entry", method: "qr_code",           timestamp: "2026-03-28T08:30:00Z" },
  { id: "12", person: { name: "Unknown visitor",type: "visitor"  }, unit: null,   type: "entry", method: "manual",             timestamp: "2026-03-27T14:20:00Z" },
];

const personTypeStyles = {
  resident: { bg: "#edfaf5", color: "#0F6E56", label: "Resident" },
  staff:    { bg: "#E6F1FB", color: "#185FA5", label: "Staff"    },
  visitor:  { bg: "#fdf0e0", color: "#854F0B", label: "Visitor"  },
};

const methodLabels = {
  qr_code:           "QR code",
  manual:            "Manual",
  plate_recognition: "Plate recognition",
};

const formatDateTime = (iso) => {
  const d = new Date(iso);
  return {
    date: d.toLocaleDateString("en-GB", { day: "numeric", month: "short", year: "numeric" }),
    time: d.toLocaleTimeString("en-GB", { hour: "2-digit", minute: "2-digit" }),
  };
};

const formatDateValue = (iso) => new Date(iso).toISOString().split("T")[0];

const todayStr = formatDateValue(new Date().toISOString());
const weekAgoStr = formatDateValue(
  new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString()
);

// Group entries by date
const groupByDate = (entries) => {
  const groups = {};
  entries.forEach((entry) => {
    const date = formatDateTime(entry.timestamp).date;
    if (!groups[date]) groups[date] = [];
    groups[date].push(entry);
  });
  return groups;
};

const AccessLog = () => {
  const [fromDate, setFromDate] = useState(weekAgoStr);
  const [toDate,   setToDate]   = useState(todayStr);
  const [search,   setSearch]   = useState("");

  // Radja: replace with real API call:
  // useEffect(() => {
  //   getAccessLog({ from: fromDate, to: toDate }).then(res => setLog(res.data));
  // }, [fromDate, toDate]);

  const filtered = mockLog.filter((entry) => {
    const entryDate = formatDateValue(entry.timestamp);
    const matchDate = entryDate >= fromDate && entryDate <= toDate;
    const matchSearch = search === "" ||
      entry.person.name.toLowerCase().includes(search.toLowerCase()) ||
      (entry.unit && entry.unit.toLowerCase().includes(search.toLowerCase()));
    return matchDate && matchSearch;
  });

  const grouped = groupByDate(filtered);

  const todayCount = mockLog.filter(
    (e) => formatDateValue(e.timestamp) === todayStr
  ).length;

  return (
    <PageWrapper>
      <div className="log-layout">

        {/* ── Hero ── */}
        <div className="log-hero">
          <div className="log-hero-hex">
            <svg width="160" height="140" viewBox="0 0 160 140" fill="none">
              <path d="M80 8L144 44V116L80 152L16 116V44L80 8Z"
                stroke="white" strokeWidth="1" opacity="0.15"/>
              <path d="M80 32L120 55V101L80 124L40 101V55L80 32Z"
                stroke="white" strokeWidth="0.8" opacity="0.1"/>
            </svg>
          </div>
          <div>
            <div className="log-hero-tag">Security</div>
            <div className="log-hero-title">Access Log</div>
            <div className="log-hero-stats">
              <div className="log-hs">
                <span className="log-hs-val">{filtered.length}</span>
                <span className="log-hs-label">Entries shown</span>
              </div>
              <div className="log-hs-div" />
              <div className="log-hs">
                <span className="log-hs-val">{todayCount}</span>
                <span className="log-hs-label">Today</span>
              </div>
              <div className="log-hs-div" />
              <div className="log-hs">
                <span className="log-hs-val">
                  {mockLog.filter((e) => e.person.type === "visitor").length}
                </span>
                <span className="log-hs-label">Visitors</span>
              </div>
            </div>
          </div>
        </div>

        {/* ── Filters ── */}
        <div className="log-filters">
          <div className="log-search">
            <svg width="13" height="13" viewBox="0 0 24 24" fill="none"
              stroke="#aaa" strokeWidth="2">
              <circle cx="11" cy="11" r="8"/>
              <line x1="21" y1="21" x2="16.65" y2="16.65"/>
            </svg>
            <input
              placeholder="Search by name or unit..."
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

        {/* ── Log table ── */}
        <div className="log-table-wrap">
          {Object.keys(grouped).length === 0 ? (
            <div className="log-empty">No entries found for this period</div>
          ) : (
            Object.entries(grouped).map(([date, entries]) => (
              <div key={date} className="log-group">
                <div className="log-group-label">
                  {date}
                  <span className="log-group-count">{entries.length} entries</span>
                </div>
                <table className="log-table">
                  <thead>
                    <tr>
                      <th>Person</th>
                      <th>Type</th>
                      <th>Unit</th>
                      <th>Method</th>
                      <th>Time</th>
                    </tr>
                  </thead>
                  <tbody>
                    {entries.map((entry) => {
                      const { time } = formatDateTime(entry.timestamp);
                      return (
                        <tr key={entry.id}>
                          <td>
                            <div className="log-person">
                              <div className="log-person-avatar">
                                {entry.person.name.split(" ").map((n) => n[0]).join("").slice(0, 2).toUpperCase()}
                              </div>
                              <span className="log-person-name">
                                {entry.person.name}
                              </span>
                            </div>
                          </td>
                          <td>
                            <span
                              className="log-badge"
                              style={{
                                background: personTypeStyles[entry.person.type].bg,
                                color: personTypeStyles[entry.person.type].color,
                              }}
                            >
                              {personTypeStyles[entry.person.type].label}
                            </span>
                          </td>
                          <td className="log-unit">
                            {entry.unit || "—"}
                          </td>
                          <td className="log-method">
                            {methodLabels[entry.method]}
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
    </PageWrapper>
  );
};

export default AccessLog;