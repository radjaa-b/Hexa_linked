import axiosInstance from "./axiosInstance";

export const loginApi = async (email, password) => {
  const formData = new URLSearchParams();
  formData.append("username", email); // FastAPI OAuth2PasswordRequestForm expects "username"
  formData.append("password", password);

  const response = await axiosInstance.post("/auth/login", formData, {
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
    },
  });

  return response.data;
};

export const logoutApi = async () => {
  const response = await axiosInstance.post("/auth/logout");
  return response.data;
};