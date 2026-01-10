import { Request, Response, NextFunction, RequestHandler } from 'express';
import { verifyToken, TokenVerificationError } from '../utils/jwt.util';
import { TokenPayload } from '../types/auth.types';

export interface AuthRequest extends Request {
  user?: TokenPayload;
}

export const authenticate: RequestHandler = (req: Request, res: Response, next: NextFunction): void => {
  const authReq = req as AuthRequest;
  try {
    const authHeader = authReq.headers.authorization;

    if (!authHeader) {
      console.warn('([LOG auth_warning] ========= Authentication required: No Authorization header provided');
      res.status(401).json({
        success: false,
        error: {
          message: 'Authentication required. Please provide a valid token in the Authorization header.',
          code: 'UNAUTHORIZED',
        },
      });
      return;
    }

    if (!authHeader.startsWith('Bearer ')) {
      console.warn('([LOG auth_warning] ========= Invalid Authorization header format:', {
        header: authHeader.substring(0, 20) + '...',
      });
      res.status(401).json({
        success: false,
        error: {
          message: 'Invalid Authorization header format. Expected: Bearer <token>',
          code: 'UNAUTHORIZED',
        },
      });
      return;
    }

    const token = authHeader.substring(7);

    if (!token || token.trim().length === 0) {
      console.warn('([LOG auth_warning] ========= Empty token provided');
      res.status(401).json({
        success: false,
        error: {
          message: 'Token is required',
          code: 'UNAUTHORIZED',
        },
      });
      return;
    }

    const decoded = verifyToken(token) as TokenPayload;

    if ('type' in decoded && decoded.type === 'refresh') {
      console.warn('([LOG auth_warning] ========= Refresh token used as access token');
      res.status(401).json({
        success: false,
        error: {
          message: 'Invalid token type. Access token required.',
          code: 'UNAUTHORIZED',
        },
      });
      return;
    }

    authReq.user = decoded;
    console.log('([LOG auth_success] ========= Authentication successful:', {
      userId: decoded.userId,
      email: decoded.email,
    });
    next();
  } catch (error) {
    if (error instanceof TokenVerificationError) {
      console.error('([LOG auth_error] ========= Token verification failed:', {
        code: error.code,
        message: error.message,
        path: req.path,
        method: req.method,
      });

      let errorMessage = 'Invalid or expired token';
      if (error.code === 'TOKEN_EXPIRED') {
        errorMessage = 'Token has expired. Please login again.';
      } else if (error.code === 'MALFORMED_TOKEN') {
        errorMessage = 'Invalid token format';
      } else if (error.code === 'INVALID_TOKEN') {
        errorMessage = 'Invalid token';
      }

      res.status(401).json({
        success: false,
        error: {
          message: errorMessage,
          code: 'UNAUTHORIZED',
        },
      });
      return;
    }

    console.error('([LOG auth_error] ========= Unexpected authentication error:', error);
    res.status(401).json({
      success: false,
      error: {
        message: 'Authentication failed',
        code: 'UNAUTHORIZED',
      },
    });
  }
};

