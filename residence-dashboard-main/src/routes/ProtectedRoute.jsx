// src/routes/ProtectedRoute.jsx
import { Navigate } from "react-router-dom";
import { ROUTES } from "../constants/routes";

const ProtectedRoute = ({ children, allowedRoles = [] }) => {
  const token = localStorage.getItem("token");

  let currentRole = "";
  try {
    const raw = localStorage.getItem("user");
    const parsed = raw ? JSON.parse(raw) : null;
    currentRole = parsed?.role?.toLowerCase().trim() ?? "";
  } catch {
    currentRole = "";
  }

  const allowed = allowedRoles.map((r) => r.toLowerCase().trim());

  console.log("ProtectedRoute debug:", { tokenExists: Boolean(token), currentRole, allowed });

  if (!token) return <Navigate to={ROUTES.LOGIN} replace />;
  if (allowed.length > 0 && !allowed.includes(currentRole)) return <Navigate to={ROUTES.LOGIN} replace />;

  return children;
};

export default ProtectedRoute;