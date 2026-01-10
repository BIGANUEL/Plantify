import jwt, { TokenExpiredError, JsonWebTokenError } from 'jsonwebtoken';
import { env } from '../config/env';
import { TokenPayload, RefreshTokenPayload } from '../types/auth.types';

export class TokenVerificationError extends Error {
  constructor(
    message: string,
    public code: 'TOKEN_EXPIRED' | 'INVALID_TOKEN' | 'MALFORMED_TOKEN' | 'VERIFICATION_FAILED'
  ) {
    super(message);
    this.name = 'TokenVerificationError';
  }
}

export const generateAccessToken = (payload: TokenPayload): string => {
  return jwt.sign(payload, env.jwtSecret, {
    expiresIn: env.jwtAccessExpiry as any,
  });
};

export const generateRefreshToken = (payload: TokenPayload): string => {
  const refreshPayload: RefreshTokenPayload = {
    ...payload,
    type: 'refresh',
  };
  return jwt.sign(refreshPayload, env.jwtSecret, {
    expiresIn: env.jwtRefreshExpiry as any,
  });
};

export const verifyToken = (token: string): TokenPayload | RefreshTokenPayload => {
  try {
    return jwt.verify(token, env.jwtSecret) as TokenPayload | RefreshTokenPayload;
  } catch (error) {
    if (error instanceof TokenExpiredError) {
      throw new TokenVerificationError('Token has expired', 'TOKEN_EXPIRED');
    } else if (error instanceof JsonWebTokenError) {
      if (error.message.includes('jwt malformed') || error.message.includes('invalid token')) {
        throw new TokenVerificationError('Invalid token format', 'MALFORMED_TOKEN');
      }
      throw new TokenVerificationError('Invalid token', 'INVALID_TOKEN');
    } else {
      throw new TokenVerificationError('Token verification failed', 'VERIFICATION_FAILED');
    }
  }
};

export const decodeToken = (token: string): TokenPayload | RefreshTokenPayload | null => {
  try {
    return jwt.decode(token) as TokenPayload | RefreshTokenPayload;
  } catch (error) {
    return null;
  }
};

