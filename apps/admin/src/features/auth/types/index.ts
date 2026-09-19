export type AuthErrorCode =
  | 'ACCESS_DENIED'
  | 'INVALID_CREDENTIALS'
  | 'MISSING_CREDENTIALS'
  | 'ACCOUNT_BANNED'
  | 'ACCOUNT_LOCKED'
  | 'NETWORK_ERROR'
  | 'SERVER_ERROR'
  | 'RESET_FAILED'
  | 'UNEXPECTED_ERROR';

export class AuthError extends Error {
  code: AuthErrorCode;

  constructor(code: AuthErrorCode, message?: string) {
    super(message || code);
    this.name = 'AuthError';
    this.code = code;
  }
}

export interface AdminUser {
  id: string;
  email: string;
  fullName: string;
  userName?: string;
  role: string;
  currency?: string;
  preferredLanguage?: string;
  avatarUrl?: string;
  phoneNumber?: string;
}

export interface LoginRequest {
  email: string;
  password: string;
}

export interface ApiResponse<T> {
  success: boolean;
  message?: string;
  data?: T;
  errors?: string[];
  statusCode?: number;
}

export interface LoginResponseData {
  user?: {
    id: string;
    email: string;
    fullName: string;
    userName: string;
    phoneNumber?: string;
    currency?: string;
    preferredLanguage?: string;
    imagePath?: string;
    role?: string;
    createdAt?: string;
  };
  token: string;
  refreshToken: string;
  refreshTokenExpiry: string;
  errorMessage?: string;
  isLockedOut?: boolean;
  isBanned?: boolean;
}

export interface RefreshTokenRequest {
  accessToken: string;
  refreshToken: string;
}

export interface TokenResponseData {
  accessToken: string;
  refreshToken: string;
  refreshTokenExpiry?: string;
}
