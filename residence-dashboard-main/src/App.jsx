// This is the root of the entire app.
// It defines all the routes and which role can access each one.
//
// Radja: no action needed here.
// The login page is the only public route — everything else
// is protected and requires a valid token + correct role.

import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import { ROUTES } from "./constants/routes";
import { ROLES }  from "./constants/roles";
import ProtectedRoute from "./routes/ProtectedRoute";

// Auth
import Login from "./pages/auth/Login";

// Admin pages
import AdminDashboard   from "./pages/admin/Dashboard";
import AdminResidents   from "./pages/admin/Residents";
import AdminStaff       from "./pages/admin/Staff";
import Communication    from "./pages/admin/Messages"; // handles messages + announcements
import AdminAccessLog   from "./pages/admin/AccessLog";
import AdminConsumption from "./pages/admin/Consumption";

// Security pages
import GateControl  from "./pages/security/GateControl";
import Visitors     from "./pages/security/Visitors";
import Surveillance from "./pages/security/Surveillance";
import IncidentLog  from "./pages/security/IncidentLog";

// Technician pages
import MaintenanceRequests from "./pages/technician/MaintenanceRequests";
import EnergyMonitor       from "./pages/technician/EnergyMonitor";
import IoTDevices from "./pages/technician/IoTDevices";


const App = () => {
  return (
    <BrowserRouter>
      <Routes>

        {/* ── Public route ── */}
        <Route path={ROUTES.LOGIN} element={<Login />} />

        {/* ── Admin routes ── */}
        <Route path={ROUTES.ADMIN_DASHBOARD} element={
          <ProtectedRoute allowedRoles={[ROLES.ADMIN]}>
            <AdminDashboard />
          </ProtectedRoute>
        }/>
        <Route path={ROUTES.ADMIN_RESIDENTS} element={
          <ProtectedRoute allowedRoles={[ROLES.ADMIN]}>
            <AdminResidents />
          </ProtectedRoute>
        }/>
        <Route path={ROUTES.ADMIN_STAFF} element={
          <ProtectedRoute allowedRoles={[ROLES.ADMIN]}>
            <AdminStaff />
          </ProtectedRoute>
        }/>
        <Route path={ROUTES.ADMIN_MESSAGES} element={
          <ProtectedRoute allowedRoles={[ROLES.ADMIN]}>
            <Communication />
          </ProtectedRoute>
        }/>
        <Route path={ROUTES.ADMIN_ACCESS_LOG} element={
          <ProtectedRoute allowedRoles={[ROLES.ADMIN]}>
            <AdminAccessLog />
          </ProtectedRoute>
        }/>
        <Route path={ROUTES.ADMIN_CONSUMPTION} element={
          <ProtectedRoute allowedRoles={[ROLES.ADMIN]}>
            <AdminConsumption />
          </ProtectedRoute>
        }/>

        {/* ── Security agent routes ── */}
        <Route path={ROUTES.SECURITY_GATE} element={
          <ProtectedRoute allowedRoles={[ROLES.SECURITY]}>
            <GateControl />
          </ProtectedRoute>
        }/>
        <Route path={ROUTES.SECURITY_VISITORS} element={
          <ProtectedRoute allowedRoles={[ROLES.SECURITY]}>
            <Visitors />
          </ProtectedRoute>
        }/>
        <Route path={ROUTES.SECURITY_ALERTS} element={
          <ProtectedRoute allowedRoles={[ROLES.SECURITY]}>
            <Surveillance />
          </ProtectedRoute>
        }/>
        <Route path={ROUTES.SECURITY_INCIDENTS} element={
          <ProtectedRoute allowedRoles={[ROLES.SECURITY]}>
            <IncidentLog />
          </ProtectedRoute>
        }/>

        {/* ── Technician routes ── */}
        <Route path={ROUTES.TECH_MAINTENANCE} element={
          <ProtectedRoute allowedRoles={[ROLES.TECHNICIAN]}>
            <MaintenanceRequests />
          </ProtectedRoute>
        }/>
        <Route path={ROUTES.TECH_ENERGY} element={
          <ProtectedRoute allowedRoles={[ROLES.TECHNICIAN]}>
            <EnergyMonitor />
          </ProtectedRoute>
        }/>
        <Route path={ROUTES.TECH_IOT} element={
  <ProtectedRoute allowedRoles={[ROLES.TECHNICIAN]}>
    <IoTDevices />
  </ProtectedRoute>
}/>

        {/* ── Fallback — unknown URL → login ── */}
        <Route path="*" element={<Navigate to={ROUTES.LOGIN} replace />} />

      </Routes>
    </BrowserRouter>
  );
};

export default App;