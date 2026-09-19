import { apiClient } from '../../../api/client';
import {
  AuthError,
  type LoginRequest,
  type LoginResponseData,
  type ApiResponse,
  type RefreshTokenRequest,
  type TokenResponseData,
} from '../types';

export const authApi = {
  /**
   * Authenticates an admin user via POST /api/Auth/Login
   */
  async login(credentials: LoginRequest): Promise<LoginResponseData> {
    try {
      const response = await apiClient.post<ApiResponse<LoginResponseData>>(
        '/Auth/Login',
        credentials
      );

      const payload = response.data;

      // Handle unified ApiResponse failure
      if (!payload.success || !payload.data) {
        throw new AuthError('INVALID_CREDENTIALS');
      }

      const data = payload.data;

      // Check account flags
      if (data.isBanned) {
        throw new AuthError('ACCOUNT_BANNED');
      }

      if (data.isLockedOut) {
        throw new AuthError('ACCOUNT_LOCKED');
      }

      if (data.errorMessage) {
        const lower = data.errorMessage.toLowerCase();
        if (lower.includes('banned')) throw new AuthError('ACCOUNT_BANNED');
        if (lower.includes('lock')) throw new AuthError('ACCOUNT_LOCKED');
        if (lower.includes('credential') || lower.includes('password') || lower.includes('email') || lower.includes('invalid') || lower.includes('user')) {
          throw new AuthError('INVALID_CREDENTIALS');
        }
        throw new AuthError('UNEXPECTED_ERROR');
      }

      // Verify Administrator Authorization
      const userRole = data.user?.role?.toLowerCase();
      const isAuthorizedAdmin =
        userRole === 'admin' || userRole === 'superadmin' || userRole === 'auditor';

      if (!isAuthorizedAdmin) {
        throw new AuthError('ACCESS_DENIED');
      }

      return data;
    } catch (err: unknown) {
      if (err instanceof AuthError) {
        throw err;
      }

      if (err instanceof Error) {
        const axiosError = err as {
          response?: {
            data?: ApiResponse<LoginResponseData> | string;
            status?: number;
          };
          code?: string;
        };

        if (axiosError.response?.status === 401) {
          throw new AuthError('INVALID_CREDENTIALS');
        }

        if (axiosError.response?.data && typeof axiosError.response.data === 'object') {
          const apiErr = axiosError.response.data as ApiResponse<LoginResponseData>;
          const msg = (
            apiErr.data?.errorMessage ||
            apiErr.message ||
            (apiErr.errors && apiErr.errors.length > 0 ? apiErr.errors[0] : '')
          ).toLowerCase();

          if (msg.includes('banned')) throw new AuthError('ACCOUNT_BANNED');
          if (msg.includes('lock')) throw new AuthError('ACCOUNT_LOCKED');
          if (msg.includes('credential') || msg.includes('password') || msg.includes('email') || msg.includes('invalid') || msg.includes('user') || msg.includes('not found')) {
            throw new AuthError('INVALID_CREDENTIALS');
          }
        }

        // Vite proxy failure or connection refused
        if (
          typeof axiosError.response?.data === 'string' &&
          (axiosError.response.data.includes('ECONNREFUSED') ||
            axiosError.response.data.includes('Proxy error') ||
            axiosError.response.data.includes('AggregateError'))
        ) {
          throw new AuthError('NETWORK_ERROR');
        }

        if (
          axiosError.response?.status === 500 ||
          axiosError.response?.status === 502 ||
          axiosError.response?.status === 504
        ) {
          throw new AuthError('SERVER_ERROR');
        }

        // Network error (backend server offline / unreachable)
        if (err.message.includes('Network Error') || axiosError.code === 'ERR_NETWORK') {
          throw new AuthError('NETWORK_ERROR');
        }

        throw new AuthError('UNEXPECTED_ERROR');
      }
      throw new AuthError('UNEXPECTED_ERROR');
    }
  },

  /**
   * Dispatches admin password recovery link via POST /api/Auth/admin/forgot-password
   * Dedicated action exclusively for administrators. Rejects non-admin users.
   */
  async forgotPassword(email: string): Promise<void> {
    try {
      const response = await apiClient.post<ApiResponse<object>>(
        '/Auth/admin/forgot-password',
        { email }
      );

      if (!response.data.success) {
        const fullErr = JSON.stringify(response.data).toLowerCase();
        if (
          fullErr.includes('admin') ||
          fullErr.includes('صلاحيات') ||
          fullErr.includes('access denied') ||
          fullErr.includes('غير مسجل') ||
          fullErr.includes('مسؤول')
        ) {
          throw new AuthError('ACCESS_DENIED');
        }
        throw new AuthError('RESET_FAILED');
      }
    } catch (err: unknown) {
      if (err instanceof AuthError) {
        throw err;
      }
      if (err instanceof Error) {
        const axiosError = err as {
          response?: {
            data?: unknown;
            status?: number;
          };
          code?: string;
        };

        if (axiosError.response?.status === 403) {
          throw new AuthError('ACCESS_DENIED');
        }

        if (axiosError.response?.data) {
          const fullErr = JSON.stringify(axiosError.response.data).toLowerCase();

          if (
            fullErr.includes('admin') ||
            fullErr.includes('صلاحيات') ||
            fullErr.includes('access denied') ||
            fullErr.includes('غير مسجل') ||
            fullErr.includes('مسؤول') ||
            fullErr.includes('not found') ||
            fullErr.includes('not registered')
          ) {
            throw new AuthError('ACCESS_DENIED');
          }
        }

        if (axiosError.response?.status === 404) {
          throw new AuthError('ACCESS_DENIED');
        }

        if (err.message.includes('Network Error') || axiosError.code === 'ERR_NETWORK') {
          throw new AuthError('NETWORK_ERROR');
        }

        if (axiosError.response?.status === 500 || axiosError.response?.status === 502) {
          throw new AuthError('SERVER_ERROR');
        }
      }
      throw new AuthError('RESET_FAILED');
    }
  },

  /**
   * Resets administrator password using token via POST /api/Auth/admin/reset-password
   */
  async resetPassword(data: {
    email: string;
    token: string;
    newPassword: string;
    confirmPassword: string;
  }): Promise<void> {
    try {
      const response = await apiClient.post<ApiResponse<object>>(
        '/Auth/admin/reset-password',
        data
      );

      if (!response.data.success) {
        const msg = (response.data.message || '').toLowerCase();
        if (msg.includes('admin') || msg.includes('صلاحيات') || msg.includes('access denied')) {
          throw new AuthError('ACCESS_DENIED');
        }
        throw new AuthError('RESET_FAILED');
      }
    } catch (err: unknown) {
      if (err instanceof AuthError) {
        throw err;
      }
      if (err instanceof Error) {
        const axiosError = err as {
          response?: {
            data?: ApiResponse<object>;
            status?: number;
          };
          code?: string;
        };

        if (axiosError.response?.status === 403) {
          throw new AuthError('ACCESS_DENIED');
        }

        if (err.message.includes('Network Error') || axiosError.code === 'ERR_NETWORK') {
          throw new AuthError('NETWORK_ERROR');
        }

        if (axiosError.response?.status === 500) {
          throw new AuthError('SERVER_ERROR');
        }
      }
      throw new AuthError('RESET_FAILED');
    }
  },

  /**
   * Refreshes JWT token via POST /api/Auth/refresh
   */
  async refreshToken(params: RefreshTokenRequest): Promise<TokenResponseData> {
    const response = await apiClient.post<ApiResponse<TokenResponseData>>(
      '/Auth/refresh',
      params
    );

    if (!response.data.success || !response.data.data) {
      throw new Error(response.data.message || 'Failed to refresh authentication token.');
    }

    return response.data.data;
  },
};
