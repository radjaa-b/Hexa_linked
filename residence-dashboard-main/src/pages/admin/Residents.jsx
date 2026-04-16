import { useState, useEffect } from "react";
import PageWrapper from "../../components/layout/PageWrapper";
import {
  getResidents,
  createResident,
  updateResident,
  updateResidentStatus,
} from "../../api/residents.api";
import "./Residents.css";

// ============================================================
// Radja: this page uses:
//   GET    /admin/residents       — list all residents
//   POST   /admin/residents       — create new resident
//   PUT    /admin/residents/:id   — edit resident
//   PATCH  /admin/residents/:id/status — suspend/activate
// ============================================================

const mockResidents = [
  { id: "1", name: "Touati Selsabil",  email: "ahmed@email.com",  unit: "A-12", phone: "+213 550 123 456", status: "active"    },
  { id: "2", name: "Radja Bennamoun",  email: "karima@email.com", unit: "B-04", phone: "+213 661 987 654", status: "active"    },
  { id: "3", name: "anfel amani", email: "youcef@email.com", unit: "C-07", phone: "+213 770 456 789", status: "suspended" },
  { id: "4", name: "alex volkov",  email: "sara@email.com",   unit: "A-03", phone: "+213 555 321 654", status: "active"    },
  { id: "5", name: "miwmiw michou",   email: "mourad@email.com", unit: "B-09", phone: "+213 660 111 222", status: "active"    },
];

const emptyForm = { name: "", unit: "", phone: "", email: "" };

const Residents = () => {
  const [residents,   setResidents]   = useState(mockResidents);
  const [search,      setSearch]      = useState("");
  const [statusFilter,setStatusFilter]= useState("all");
  const [form,        setForm]        = useState(emptyForm);
  const [editId,      setEditId]      = useState(null);
  const [loading,     setLoading]     = useState(false);
  const [formError,   setFormError]   = useState("");
  const [formSuccess, setFormSuccess] = useState("");

  // Radja: uncomment when backend is ready
  // useEffect(() => {
  //   getResidents().then(res => setResidents(res.data));
  // }, []);

  const filtered = residents.filter((r) => {
    const matchSearch =
      r.name.toLowerCase().includes(search.toLowerCase()) ||
      r.unit.toLowerCase().includes(search.toLowerCase()) ||
      r.email.toLowerCase().includes(search.toLowerCase());
    const matchStatus =
      statusFilter === "all" || r.status === statusFilter;
    return matchSearch && matchStatus;
  });

  const totalActive    = residents.filter((r) => r.status === "active").length;
  const totalSuspended = residents.filter((r) => r.status === "suspended").length;

  const handleFormChange = (e) => {
    setForm({ ...form, [e.target.name]: e.target.value });
    setFormError("");
    setFormSuccess("");
  };

  const handleEdit = (resident) => {
    setEditId(resident.id);
    setForm({
      name:  resident.name,
      unit:  resident.unit,
      phone: resident.phone,
      email: resident.email,
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
    if (!form.name || !form.unit || !form.phone || !form.email) {
      setFormError("All fields are required.");
      return;
    }
    setLoading(true);
    setFormError("");

    try {
      if (editId) {
        // Radja: PUT /admin/residents/:id
        // const res = await updateResident(editId, form);
        setResidents((prev) =>
          prev.map((r) => (r.id === editId ? { ...r, ...form } : r))
        );
        setFormSuccess("Resident updated successfully.");
        setEditId(null);
        setForm(emptyForm);
      } else {
        // Radja: POST /admin/residents
        // Backend sends credentials to resident automatically
        // const res = await createResident(form);
        const newResident = { id: String(Date.now()), ...form, status: "active" };
        setResidents((prev) => [newResident, ...prev]);
        setFormSuccess("Resident created. Credentials sent automatically.");
        setForm(emptyForm);
      }
    } catch (err) {
      setFormError(err.response?.data?.message || "Something went wrong.");
    } finally {
      setLoading(false);
    }
  };

  const handleToggleStatus = async (resident) => {
    const newStatus = resident.status === "active" ? "suspended" : "active";
    try {
      // Radja: PATCH /admin/residents/:id/status
      // await updateResidentStatus(resident.id, newStatus);
      setResidents((prev) =>
        prev.map((r) => (r.id === resident.id ? { ...r, status: newStatus } : r))
      );
    } catch (err) {
      console.error("Status update failed", err);
    }
  };

  return (
    <PageWrapper>
      <div className="res-layout">

        {/* ── Hero ── */}
        <div className="res-hero">
          <div className="res-hero-hex">
            <svg width="160" height="140" viewBox="0 0 160 140" fill="none">
              <path d="M80 8L144 44V116L80 152L16 116V44L80 8Z"
                stroke="white" strokeWidth="1" opacity="0.15"/>
              <path d="M80 32L120 55V101L80 124L40 101V55L80 32Z"
                stroke="white" strokeWidth="0.8" opacity="0.1"/>
            </svg>
          </div>
          <div>
            <div className="res-hero-tag">Resident management</div>
            <div className="res-hero-title">All Residents</div>
            <div className="res-hero-stats">
              <div className="res-hs">
                <span className="res-hs-val">{residents.length}</span>
                <span className="res-hs-label">Total</span>
              </div>
              <div className="res-hs-div" />
              <div className="res-hs">
                <span className="res-hs-val">{totalActive}</span>
                <span className="res-hs-label">Active</span>
              </div>
              <div className="res-hs-div" />
              <div className="res-hs">
                <span className="res-hs-val">{totalSuspended}</span>
                <span className="res-hs-label">Suspended</span>
              </div>
            </div>
          </div>
        </div>

        {/* ── Body ── */}
        <div className="res-body">

          {/* Left — table */}
          <div className="res-left">
            <div className="res-search-row">
              <div className="res-search">
                <svg width="13" height="13" viewBox="0 0 24 24" fill="none"
                  stroke="#aaa" strokeWidth="2">
                  <circle cx="11" cy="11" r="8"/>
                  <line x1="21" y1="21" x2="16.65" y2="16.65"/>
                </svg>
                <input
                  placeholder="Search by name, unit or email..."
                  value={search}
                  onChange={(e) => setSearch(e.target.value)}
                />
              </div>
              <select
                className="res-filter"
                value={statusFilter}
                onChange={(e) => setStatusFilter(e.target.value)}
              >
                <option value="all">All status</option>
                <option value="active">Active</option>
                <option value="suspended">Suspended</option>
              </select>
            </div>

            <div className="res-table-wrap">
              <table className="res-table">
                <thead>
                  <tr>
                    <th>Resident</th>
                    <th>Unit</th>
                    <th>Phone</th>
                    <th>Status</th>
                    <th>Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {filtered.length === 0 ? (
                    <tr>
                      <td colSpan={5} className="res-empty">
                        No residents found
                      </td>
                    </tr>
                  ) : (
                    filtered.map((r) => (
                      <tr key={r.id} className={editId === r.id ? "editing" : ""}>
                        <td>
                          <div className="res-td-name">{r.name}</div>
                          <div className="res-td-sub">{r.email}</div>
                        </td>
                        <td>{r.unit}</td>
                        <td>{r.phone}</td>
                        <td>
                          <span className={`res-badge ${r.status}`}>
                            {r.status.charAt(0).toUpperCase() + r.status.slice(1)}
                          </span>
                        </td>
                        <td>
                          <div className="res-actions">
                            <button
                              className="res-act edit"
                              onClick={() => handleEdit(r)}
                            >
                              Edit
                            </button>
                            <button
                              className={`res-act ${r.status === "active" ? "suspend" : "activate"}`}
                              onClick={() => handleToggleStatus(r)}
                            >
                              {r.status === "active" ? "Suspend" : "Activate"}
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
          <div className="res-right">
            <div className="res-rp-label">Quick action</div>
            <div className="res-rp-head">
              {editId ? "Edit resident" : "Add resident"}
            </div>

            <form onSubmit={handleSubmit} className="res-rp-form">
              <label className="res-rp-field-label">Full name</label>
              <input
                className="res-rp-input"
                name="name"
                placeholder="e.g. Ahmed Benali"
                value={form.name}
                onChange={handleFormChange}
              />
              <label className="res-rp-field-label">Unit number</label>
              <input
                className="res-rp-input"
                name="unit"
                placeholder="e.g. A-12"
                value={form.unit}
                onChange={handleFormChange}
              />
              <label className="res-rp-field-label">Phone</label>
              <input
                className="res-rp-input"
                name="phone"
                placeholder="+213..."
                value={form.phone}
                onChange={handleFormChange}
              />
              <label className="res-rp-field-label">Email</label>
              <input
                className="res-rp-input"
                name="email"
                type="email"
                placeholder="resident@email.com"
                value={form.email}
                onChange={handleFormChange}
              />

              {formError   && <p className="res-rp-error">{formError}</p>}
              {formSuccess && <p className="res-rp-success">{formSuccess}</p>}

              <button
                type="submit"
                className="res-rp-btn"
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
                  className="res-rp-cancel"
                  onClick={handleCancelEdit}
                >
                  Cancel
                </button>
              )}

              {!editId && (
                <p className="res-rp-note">
                  Credentials will be sent to the resident automatically
                </p>
              )}
            </form>
          </div>
        </div>
      </div>
    </PageWrapper>
  );
};

export default Residents;