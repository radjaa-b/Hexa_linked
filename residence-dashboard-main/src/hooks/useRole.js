// A hook to easily check which role the current user has.
// Used to show/hide UI elements based on role.
//
// Usage example:
//   const { isAdmin, isSecurity } = useRole();
//   {isAdmin && <button>Delete resident</button>}
//
// Radja: no action needed here.

import useAuth from "./useAuth";
import { ROLES } from "../constants/roles";

const useRole = () => {
  const { role } = useAuth();

  return {
    role,
    isAdmin:      role === ROLES.ADMIN,
    isSecurity:   role === ROLES.SECURITY,
    isTechnician: role === ROLES.TECHNICIAN,
  };
};

export default useRole;