// A hook that any component can use to get the current
// logged-in user and check if they are authenticated.
//
// Usage example:
//   const { user, isAuthenticated, role } = useAuth();
//
// Radja: no action needed here — this reads from localStorage
// which is populated by your login endpoint response.

import { getStoredUser, getStoredToken } from "../store/authStore";

const useAuth = () => {
  const user  = getStoredUser();
  const token = getStoredToken();

  return {
    user,           // { id, name, email, role, avatar }
    token,          // the JWT token string
    isAuthenticated: !!token && !!user,
    role: user?.role || null,
  };
};

export default useAuth;