import axios from 'axios';

const API_BASE_URL =
  import.meta.env.VITE_API_URL ||
  (import.meta.env.DEV ? '/api' : 'https://mahfazati.runasp.net/api');

export const apiClient = axios.create({
  baseURL: API_BASE_URL,
  timeout: 15000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request Interceptor: Attach Access Token
apiClient.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('mahfazti_admin_access_token');
    if (token && config.headers) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Response Interceptor: Handle Token Refresh on 401, redirect to 401 on failure, and handle 403
apiClient.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config;
    const status = error.response?.status;

    if (status === 401) {
      if (originalRequest && !originalRequest._retry) {
        originalRequest._retry = true;
        const refreshToken = localStorage.getItem('mahfazti_admin_refresh_token');
        const currentAccessToken = localStorage.getItem('mahfazti_admin_access_token') || '';

        if (refreshToken) {
          try {
            const res = await axios.post(`${API_BASE_URL}/Auth/refresh`, {
              accessToken: currentAccessToken,
              refreshToken,
            });

            const data = res.data?.data;
            if (res.data?.success && data) {
              const newAccessToken = data.accessToken || data.token;
              const newRefreshToken = data.refreshToken;

              if (newAccessToken) {
                localStorage.setItem('mahfazti_admin_access_token', newAccessToken);
                originalRequest.headers.Authorization = `Bearer ${newAccessToken}`;
              }
              if (newRefreshToken) {
                localStorage.setItem('mahfazti_admin_refresh_token', newRefreshToken);
              }
              return apiClient(originalRequest);
            }
          } catch {
            localStorage.removeItem('mahfazti_admin_access_token');
            localStorage.removeItem('mahfazti_admin_refresh_token');
            localStorage.removeItem('mahfazti_admin_session');
            if (window.location.pathname !== '/login' && window.location.pathname !== '/401') {
              window.location.href = '/401';
            }
          }
        } else {
          localStorage.removeItem('mahfazti_admin_access_token');
          localStorage.removeItem('mahfazti_admin_refresh_token');
          localStorage.removeItem('mahfazti_admin_session');
          if (window.location.pathname !== '/login' && window.location.pathname !== '/401') {
            window.location.href = '/401';
          }
        }
      }
    } else if (status === 403) {
      if (window.location.pathname !== '/403') {
        window.location.href = '/403';
      }
    }

    return Promise.reject(error);
  }
);
