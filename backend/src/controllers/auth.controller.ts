import { Request, Response, NextFunction } from 'express';
import { AuthService } from '../services/auth.service';
import { AuthRequest } from '../middleware/auth.middleware';
import { RegisterRequest, LoginRequest, RefreshTokenRequest } from '../types/auth.types';

const authService = new AuthService();

export const register = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { email, password, name }: RegisterRequest = req.body;

    const result = await authService.register(email, password, name);

    res.status(201).json({
      success: true,
      data: {
        user: {
          id: result.user._id.toString(),
          email: result.user.email,
          name: result.user.name,
        },
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      },
    });
  } catch (error: any) {
    if (error.message === 'Email already registered') {
      res.status(400).json({
        success: false,
        error: {
          message: error.message,
          code: 'DUPLICATE_ENTRY',
        },
      });
      return;
    }
    next(error);
  }
};

export const login = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { email, password }: LoginRequest = req.body;

    const result = await authService.login(email, password);

    res.status(200).json({
      success: true,
      data: {
        user: {
          id: result.user._id.toString(),
          email: result.user.email,
          name: result.user.name,
        },
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      },
    });
  } catch (error: any) {
    if (error.message === 'Invalid credentials') {
      res.status(401).json({
        success: false,
        error: {
          message: error.message,
          code: 'UNAUTHORIZED',
        },
      });
      return;
    }
    next(error);
  }
};

export const refreshToken = async (req: Request, res: Response, _next: NextFunction): Promise<void> => {
  try {
    const { refreshToken }: RefreshTokenRequest = req.body;

    if (!refreshToken) {
      res.status(400).json({
        success: false,
        error: {
          message: 'Refresh token is required',
          code: 'VALIDATION_ERROR',
        },
      });
      return;
    }

    const accessToken = await authService.refreshAccessToken(refreshToken);

    res.status(200).json({
      success: true,
      data: {
        accessToken,
      },
    });
  } catch (error: any) {
    res.status(401).json({
      success: false,
      error: {
        message: error.message || 'Invalid or expired refresh token',
        code: 'UNAUTHORIZED',
      },
    });
  }
};

export const getCurrentUser = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    if (!req.user) {
      res.status(401).json({
        success: false,
        error: {
          message: 'Authentication required',
          code: 'UNAUTHORIZED',
        },
      });
      return;
    }

    const user = await authService.getUserById(req.user.userId);

    if (!user) {
      res.status(404).json({
        success: false,
        error: {
          message: 'User not found',
          code: 'NOT_FOUND',
        },
      });
      return;
    }

    res.status(200).json({
      success: true,
      data: {
        user: {
          id: user._id.toString(),
          email: user.email,
          name: user.name,
          createdAt: user.createdAt,
        },
      },
    });
  } catch (error) {
    next(error);
  }
};

export const logout = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    if (!req.user) {
      res.status(401).json({
        success: false,
        error: {
          message: 'Authentication required',
          code: 'UNAUTHORIZED',
        },
      });
      return;
    }

    const { refreshToken } = req.body;

    if (refreshToken) {
      await authService.logout(req.user.userId, refreshToken);
    }

    res.status(200).json({
      success: true,
      message: 'Logged out successfully',
    });
  } catch (error) {
    next(error);
  }
};

