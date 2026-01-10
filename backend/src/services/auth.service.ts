import { User, IUser } from '../models/User.model';
import { hashPassword, comparePassword } from '../utils/password.util';
import { generateAccessToken, generateRefreshToken, verifyToken } from '../utils/jwt.util';
import { TokenPayload, RefreshTokenPayload } from '../types/auth.types';
import { OAuth2Client } from 'google-auth-library';

const googleClient = new OAuth2Client(
  process.env.GOOGLE_CLIENT_ID,
  process.env.GOOGLE_CLIENT_SECRET
);

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
    // Find user
    const user = await User.findOne({ email });
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

  async googleAuth(googleToken: string): Promise<{
    user: IUser;
    accessToken: string;
    refreshToken: string;
  }> {
    try {
      // Verify Google token
      const ticket = await googleClient.verifyIdToken({
        idToken: googleToken,
        audience: process.env.GOOGLE_CLIENT_ID,
      });

      const payload = ticket.getPayload();
      if (!payload) {
        throw new Error('Invalid Google token');
      }

      const { email, name, sub: googleId } = payload;

      if (!email) {
        throw new Error('Email not provided by Google');
      }

      // Find or create user
      let user = await User.findOne({ $or: [{ email }, { googleId }] });

      if (user) {
        // Update Google ID if not set
        if (!user.googleId && googleId) {
          user.googleId = googleId;
          await user.save();
        }
      } else {
        // Create new user
        user = new User({
          email,
          name: name || 'User',
          googleId,
        });
        await user.save();
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
    } catch (error) {
      console.error('([LOG google_auth_error] ========= Google authentication error:', error);
      throw new Error('Google authentication failed');
    }
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

