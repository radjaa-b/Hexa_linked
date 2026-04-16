import { useState } from "react";
import PageWrapper from "../../components/layout/PageWrapper";
import "./Staff.css";

// ============================================================
// Radja: this page uses:
//   GET    /admin/staff              — list all staff
//   POST   /admin/staff              — create new staff account
//   PUT    /admin/staff/:id          — edit staff info
//   PATCH  /admin/staff/:id/status   — activate or deactivate
//
// Role must be exactly: "security" | "technician"
// Backend sends credentials to staff after account creation.
// ============================================================

const mockStaff = [
  { id: "1", name: "Karima Saidi",   email: "karima@hexagate.com",  phone: "+213 550 111 222", role: "security",   status: "active"   },
  { id: "2", name: "Mourad Kaci",    email: "mourad@hexagate.com",  phone: "+213 661 333 444", role: "technician", status: "active"   },
  { id: "3", name: "Farid Belkacem", email: "farid@hexagate.com",   phone: "+213 770 555 666", role: "security",   status: "active"   },
  { id: "4", name: "Amina Zerrouk",  email: "amina@hexagate.com",   phone: "+213 555 777 888", role: "technician", status: "inactive" },
  { id: "5", name: "Yassine Hamdi",  email: "yassine@hexagate.com", phone: "+213 660 999 000", role: "security",   status: "active"   },
];

const emptyForm = { name: "", role: "security", phone: "", email: "" };

const roleStyles = {
  security:   { bg: "#E6F1FB", color: "#185FA5", label: "Security agent"  },
  technician: { bg: "#fdf0e0", color: "#854F0B", label: "Technician"      },
};

const Staff = () => {
  const [staff,       setStaff]       = useState(mockStaff);
  const [search,      setSearch]      = useState("");
  const [roleFilter,  setRoleFilter]  = useState("all");
  const [form,        setForm]        = useState(emptyForm);
  const [editId,      setEditId]      = useState(null);
  const [loading,     setLoading]     = useState(false);
  const [formError,   setFormError]   = useState("");
  const [formSuccess, setFormSuccess] = useState("");

  // Radja: uncomment when backend is ready
  // useEffect(() => {
  //   getStaff().then(res => setStaff(res.data));
  // }, []);

  const filtered = staff.filter((s) => {
    const matchSearch =
      s.name.toLowerCase().includes(search.toLowerCase()) ||
      s.email.toLowerCase().includes(search.toLowerCase());
    const matchRole =
      roleFilter === "all" || s.role === roleFilter;
    return matchSearch && matchRole;
  });

  const totalSecurity   = staff.filter((s) => s.role === "security").length;
  const totalTechnician = staff.filter((s) => s.role === "technician").length;
  const totalActive     = staff.filter((s) => s.status === "active").length;

  const handleFormChange = (e) => {
    setForm({ ...form, [e.target.name]: e.target.value });
    setFormError("");
    setFormSuccess("");
  };

  const handleEdit = (member) => {
    setEditId(member.id);
    setForm({
      name:  member.name,
      role:  member.role,
      phone: member.phone,
      email: member.email,
    });
    setFormError("");
    setFormSuccess("");
  };

  const handleCancelEdit = () => {
    setEditId(null);
    setForm(emptyForm);
    setFormError("");
    setFormSuccess("");
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!form.name || !form.phone || !form.email) {
      setFormError("All fields are required.");
      return;
    }
    setLoading(true);
    setFormError("");

    try {
      if (editId) {
        // Radja: PUT /admin/staff/:id
        setStaff((prev) =>
          prev.map((s) => (s.id === editId ? { ...s, ...form } : s))
        );
        setFormSuccess("Staff member updated successfully.");
        setEditId(null);
        setForm(emptyForm);
      } else {
        // Radja: POST /admin/staff
        // Backend sends credentials automatically
        const newMember = {
          id: String(Date.now()),
          ...form,
          status: "active",
        };
        setStaff((prev) => [newMember, ...prev]);
        setFormSuccess("Account created. Credentials sent automatically.");
        setForm(emptyForm);
      }
    } catch (err) {
      setFormError(err.response?.data?.message || "Something went wrong.");
    } finally {
      setLoading(false);
    }
  };

  const handleToggleStatus = (member) => {
    const newStatus = member.status === "active" ? "inactive" : "active";
    // Radja: PATCH /admin/staff/:id/status { status: newStatus }
    setStaff((prev) =>
      prev.map((s) => (s.id === member.id ? { ...s, status: newStatus } : s))
    );
  };

  return (
    <PageWrapper>
      <div className="staff-layout">

        {/* ── Hero ── */}
        <div className="staff-hero">
          <div className="staff-hero-hex">
            <svg width="160" height="140" viewBox="0 0 160 140" fill="none">
              <path d="M80 8L144 44V116L80 152L16 116V44L80 8Z"
                stroke="white" strokeWidth="1" opacity="0.15"/>
              <path d="M80 32L120 55V101L80 124L40 101V55L80 32Z"
                stroke="white" strokeWidth="0.8" opacity="0.1"/>
            </svg>
          </div>
          <div>
            <div className="staff-hero-tag">Staff management</div>
            <div className="staff-hero-title">All Staff</div>
            <div className="staff-hero-stats">
              <div className="staff-hs">
                <span className="staff-hs-val">{staff.length}</span>
                <span className="staff-hs-label">Total</span>
              </div>
              <div className="staff-hs-div" />
              <div className="staff-hs">
                <span className="staff-hs-val">{totalActive}</span>
                <span className="staff-hs-label">Active</span>
              </div>
              <div className="staff-hs-div" />
              <div className="staff-hs">
                <span className="staff-hs-val">{totalSecurity}</span>
                <span className="staff-hs-label">Security agents</span>
              </div>
              <div className="staff-hs-div" />
              <div className="staff-hs">
                <span className="staff-hs-val">{totalTechnician}</span>
                <span className="staff-hs-label">Technicians</span>
              </div>
            </div>
          </div>
        </div>

        {/* ── Body ── */}
        <div className="staff-body">

          {/* Left — table */}
          <div className="staff-left">
            <div className="staff-search-row">
              <div className="staff-search">
                <svg width="13" height="13" viewBox="0 0 24 24" fill="none"
                  stroke="#aaa" strokeWidth="2">
                  <circle cx="11" cy="11" r="8"/>
                  <line x1="21" y1="21" x2="16.65" y2="16.65"/>
                </svg>
                <input
                  placeholder="Search by name or email..."
                  value={search}
                  onChange={(e) => setSearch(e.target.value)}
                />
              </div>
              <select
                className="staff-filter"
                value={roleFilter}
                onChange={(e) => setRoleFilter(e.target.value)}
              >
                <option value="all">All roles</option>
                <option value="security">Security agents</option>
                <option value="technician">Technicians</option>
              </select>
            </div>

            <div className="staff-table-wrap">
              <table className="staff-table">
                <thead>
                  <tr>
                    <th>Staff member</th>
                    <th>Role</th>
                    <th>Phone</th>
                    <th>Status</th>
                    <th>Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {filtered.length === 0 ? (
                    <tr>
                      <td colSpan={5} className="staff-empty">
                        No staff members found
                      </td>
                    </tr>
                  ) : (
                    filtered.map((s) => (
                      <tr
                        key={s.id}
                        className={editId === s.id ? "editing" : ""}
                      >
                        <td>
                          <div className="staff-td-name">{s.name}</div>
                          <div className="staff-td-sub">{s.email}</div>
                        </td>
                        <td>
                          <span
                            className="staff-role-badge"
                            style={{
                              background: roleStyles[s.role].bg,
                              color: roleStyles[s.role].color,
                            }}
                          >
                            {roleStyles[s.role].label}
                          </span>
                        </td>
                        <td>{s.phone}</td>
                        <td>
                          <span className={`staff-status-badge ${s.status}`}>
                            {s.status.charAt(0).toUpperCase() + s.status.slice(1)}
                          </span>
                        </td>
                        <td>
                          <div className="staff-actions">
                            <button
                              className="staff-act edit"
                              onClick={() => handleEdit(s)}
                            >
                              Edit
                            </button>
                            <button
                              className={`staff-act ${s.status === "active" ? "deactivate" : "activate"}`}
                              onClick={() => handleToggleStatus(s)}
                            >
                              {s.status === "active" ? "Deactivate" : "Activate"}
                            </button>
                          </div>
                        </td>
                      </tr>
                    ))
                  )}
                </tbody>
              </table>
            </div>
          </div>

          {/* Right — add / edit panel */}
          <div className="staff-right">
            <div className="staff-rp-label">Quick action</div>
            <div className="staff-rp-head">
              {editId ? "Edit staff member" : "Add staff member"}
            </div>

            <form onSubmit={handleSubmit} className="staff-rp-form">

              <label className="staff-rp-field-label">Full name</label>
              <input
                className="staff-rp-input"
                name="name"
                placeholder="e.g. Karima Saidi"
                value={form.name}
                onChange={handleFormChange}
              />

              <label className="staff-rp-field-label">Role</label>
              <select
                className="staff-rp-input staff-rp-select"
                name="role"
                value={form.role}
                onChange={handleFormChange}
              >
                <option value="security">Security agent</option>
                <option value="technician">Technician</option>
              </select>

              <label className="staff-rp-field-label">Phone</label>
              <input
                className="staff-rp-input"
                name="phone"
                placeholder="+213..."
                value={form.phone}
                onChange={handleFormChange}
              />

              <label className="staff-rp-field-label">Email</label>
              <input
                className="staff-rp-input"
                name="email"
                type="email"
                placeholder="staff@hexagate.com"
                value={form.email}
                onChange={handleFormChange}
              />

              {formError   && <p className="staff-rp-error">{formError}</p>}
              {formSuccess && <p className="staff-rp-success">{formSuccess}</p>}

              <button
                type="submit"
                className="staff-rp-btn"
                disabled={loading}
              >
                {loading
                  ? "Saving..."
                  : editId
                  ? "Save changes"
                  : "Create account"}
              </button>

              {editId && (
                <button
                  type="button"
                  className="staff-rp-cancel"
                  onClick={handleCancelEdit}
                >
                  Cancel
                </button>
              )}

              {!editId && (
                <p className="staff-rp-note">
                  Credentials will be sent to the staff member automatically
                </p>
              )}
            </form>
          </div>
        </div>
      </div>
    </PageWrapper>
  );
};

export default Staff;