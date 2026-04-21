

// ============================================================
// Radja: SET YOUR BACKEND BASE URL HERE
// Replace the string below with your actual server URL.
// Example: "http://localhost:8080/api/v1" during development
//          "https://your-domain.com/api/v1" in production
// ============================================================


// Radja: every request the frontend makes will automatically
// include the user's token in the Authorization header like this:
// Authorization: Bearer <token>
// Your backend needs to read and validate this token on
// every protected endpoint.


// Radja: if your backend returns a 401 (unauthorized) response,
// the frontend will automatically clear the session and
// send the user back to the login page.
// Make sure your backend returns 401 when a token is
// missing, expired, or invalid.
import axios from "axios";

const BASE_URL = import.meta.env.VITE_API_URL;
console.log("🔍 BASE_URL is:", BASE_URL);

const axiosInstance = axios.create({
  baseURL: BASE_URL,
});

axiosInstance.interceptors.request.use((config) => {
  const token = localStorage.getItem("token");
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

axiosInstance.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem("token");
      localStorage.removeItem("user");
      window.location.href = "/";
    }
    return Promise.reject(error);
  }
);

export default axiosInstance;