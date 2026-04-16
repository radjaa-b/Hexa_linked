// This component wraps every page that requires authentication.
// It does two checks before allowing access:
//   1. Is the user logged in? (has a valid token)
//   2. Does the user have the correct role for this page?
// If either check fails, it redirects automatically.
//
// Radja: no action needed here — this is purely frontend logic.
// It reads the token and role from localStorage (set at login).

import { Navigate } from "react-router-dom";
import useAuth from "../hooks/useAuth";
import { ROUTES } from "../constants/routes";

// allowedRoles: array of roles that can access the wrapped page
// Example: <ProtectedRoute allowedRoles={["admin"]}> ... </ProtectedRoute>

const ProtectedRoute = ({ children, allowedRoles }) => {
  const { isAuthenticated, role } = useAuth();

  // Not logged in at all → go to login page
  if (!isAuthenticated) {
    return <Navigate to={ROUTES.LOGIN} replace />;
  }

  // Logged in but wrong role → go to login page
  // (this handles the case where someone manually types a URL)
  if (allowedRoles && !allowedRoles.includes(role)) {
    return <Navigate to={ROUTES.LOGIN} replace />;
  }

  // All good → render the page
  return children;
};

export default ProtectedRoute;