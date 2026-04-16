// This file handles saving and reading the logged-in user's
// session from localStorage (the browser's local storage).
//
// Radja: after a successful login, your POST /auth/login
// endpoint must return this shape:
// {
//   "success": true,
//   "data": {
//     "token": "eyJ...",
//     "user": {
//       "id": "uuid",
//       "name": "John Doe",
//       "email": "john@example.com",
//       "role": "admin",      <-- must be "admin", "security", or "technician"
//       "avatar": "url"       <-- can be null
//     }
//   }
// }
// The frontend will call saveAuth(token, user) to store the session.

export const getStoredUser = () => {
  try {
    return JSON.parse(localStorage.getItem("user"));
  } catch {
    return null;
  }
};

export const getStoredToken = () => localStorage.getItem("token");

// Called right after a successful login
export const saveAuth = (token, user) => {
  localStorage.setItem("token", token);
  localStorage.setItem("user", JSON.stringify(user));
};

// Called on logout — clears everything from the browser
export const clearAuth = () => {
  localStorage.removeItem("token");
  localStorage.removeItem("user");
};