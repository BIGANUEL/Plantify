import { User, IUser } from '../models/User.model';
import { hashPassword, comparePassword } from '../utils/password.util';
import { generateAccessToken, generateRefreshToken, verifyToken } from '../utils/jwt.util';
import { TokenPayload, RefreshTokenPayload } from '../types/auth.types';

export class AuthService {
  async register(email: string, password: string, name: string): Promise<{
    user: IUser;
    accessToken: string;
    refreshToken: string;
  }> {
    // Check if user already exists
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      throw new Error('Email already registered');
    }

    // Hash password
    const hashedPassword = await hashPassword(password);

    // Create user
    const user = new User({
      email,
      password: hashedPassword,
      name,
    });

    await user.save();

    // Generate tokens
    const tokenPayload: TokenPayload = {
      userId: user._id.toString(),
      email: user.email,
    };

    const accessToken = generateAccessToken(tokenPayload);
    const refreshToken = generateRefreshToken(tokenPayload);

    // Store refresh token
    user.refreshTokens.push(refreshToken);
    await user.save();

    return {
      user,
      accessToken,
      refreshToken,
    };
  }

  async login(email: string, password: string): Promise<{
    user: IUser;
    accessToken: string;
    refreshToken: string;
  }> {
    // Find user - ensure email is lowercase for lookup (matches User model's lowercase: true)
    const normalizedEmail = email.toLowerCase().trim();
    const user = await User.findOne({ email: normalizedEmail });
    if (!user || !user.password) {
      throw new Error('Invalid credentials');
    }

    // Verify password
    const isPasswordValid = await comparePassword(password, user.password);
    if (!isPasswordValid) {
      throw new Error('Invalid credentials');
    }

    // Generate tokens
    const tokenPayload: TokenPayload = {
      userId: user._id.toString(),
      email: user.email,
    };

    const accessToken = generateAccessToken(tokenPayload);
    const refreshToken = generateRefreshToken(tokenPayload);

    // Store refresh token
    user.refreshTokens.push(refreshToken);
    await user.save();

    return {
      user,
      accessToken,
      refreshToken,
    };
  }

  async refreshAccessToken(refreshToken: string): Promise<string> {
    try {
      // Verify refresh token
      const decoded = verifyToken(refreshToken) as RefreshTokenPayload;

      if (!decoded.type || decoded.type !== 'refresh') {
        throw new Error('Invalid token type');
      }

      // Check if token exists in user's refresh tokens
      const user = await User.findById(decoded.userId);
      if (!user || !user.refreshTokens.includes(refreshToken)) {
        throw new Error('Invalid refresh token');
      }

      // Generate new access token
      const tokenPayload: TokenPayload = {
        userId: decoded.userId,
        email: decoded.email,
      };

      return generateAccessToken(tokenPayload);
    } catch (error) {
      console.error('([LOG refresh_token_error] ========= Refresh token error:', error);
      throw new Error('Invalid or expired refresh token');
    }
  }

  async logout(userId: string, refreshToken: string): Promise<void> {
    const user = await User.findById(userId);
    if (user) {
      user.refreshTokens = user.refreshTokens.filter((token) => token !== refreshToken);
      await user.save();
    }
  }

  async getUserById(userId: string): Promise<IUser | null> {
    return User.findById(userId).select('-password -refreshTokens');
  }
}

