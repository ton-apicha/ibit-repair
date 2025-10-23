/**
 * Authentication Controller
 * จัดการ Login, Logout, และ Refresh Token
 */

import { Request, Response } from 'express';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { v4 as uuidv4 } from 'uuid';
import prisma from '../utils/prisma';
import { log } from '../utils/logger';
import { config } from '../config';
import { jwtConfig, JWTPayload, RefreshTokenPayload } from '../config/jwt';
import { AuthenticationError, ValidationError, BusinessLogicError } from '../utils/errors';
import { asyncHandler } from '../middleware/errorHandler.middleware';

/**
 * Generate JWT Token
 */
const generateAccessToken = (payload: JWTPayload): string => {
  return jwt.sign(payload, jwtConfig.secret, {
    expiresIn: jwtConfig.expiresIn,
    issuer: jwtConfig.issuer,
    audience: jwtConfig.audience,
    algorithm: jwtConfig.algorithm,
  });
};

/**
 * Generate Refresh Token
 */
const generateRefreshToken = (payload: RefreshTokenPayload): string => {
  return jwt.sign(payload, jwtConfig.secret, {
    expiresIn: jwtConfig.refreshExpiresIn,
    issuer: jwtConfig.issuer,
    audience: jwtConfig.audience,
    algorithm: jwtConfig.algorithm,
  });
};

/**
 * Login - ตรวจสอบ username/password และออก JWT token
 * POST /api/auth/login
 * Body: { username: string, password: string }
 */
export const login = asyncHandler(async (req: Request, res: Response): Promise<void> => {
  const { username, password } = req.body;

  log.info('Login attempt', {
    requestId: req.requestId,
    username,
    ip: req.ip || req.connection.remoteAddress,
    userAgent: req.get('User-Agent'),
  });

  // 1. Validate input
  if (!username || !password) {
    throw new ValidationError('Username and password are required', 'credentials', { username, hasPassword: !!password }, req.requestId);
  }

  // 2. Find user
  const user = await prisma.user.findUnique({
    where: { username },
    select: {
      id: true,
      username: true,
      email: true,
      password: true,
      fullName: true,
      role: true,
      isActive: true,
      language: true,
    },
  });

  if (!user) {
    log.warn('Login failed - user not found', {
      requestId: req.requestId,
      username,
      ip: req.ip || req.connection.remoteAddress,
    });
    throw new AuthenticationError('Invalid username or password', req.requestId);
  }

  // 3. Check if user is active
  if (!user.isActive) {
    log.warn('Login failed - user inactive', {
      requestId: req.requestId,
      userId: user.id,
      username,
      ip: req.ip || req.connection.remoteAddress,
    });
    throw new AuthenticationError('Account is deactivated', req.requestId);
  }

  // 4. Verify password
  const isPasswordValid = await bcrypt.compare(password, user.password);
  if (!isPasswordValid) {
    log.warn('Login failed - invalid password', {
      requestId: req.requestId,
      userId: user.id,
      username,
      ip: req.ip || req.connection.remoteAddress,
    });
    throw new AuthenticationError('Invalid username or password', req.requestId);
  }

  // 5. Generate tokens
  const tokenId = uuidv4();
  const accessToken = generateAccessToken({
    id: user.id,
    username: user.username,
    role: user.role,
  });

  const refreshToken = generateRefreshToken({
    id: user.id,
    tokenId,
  });

  // 6. Store refresh token in database
  await prisma.refreshToken.create({
    data: {
      token: refreshToken,
      userId: user.id,
      expiresAt: new Date(Date.now() + jwtConfig.refreshExpiresIn * 1000),
    },
  });

  // 7. Log successful login
  log.auth('Login successful', user.id, {
    requestId: req.requestId,
    username: user.username,
    role: user.role,
    ip: req.ip || req.connection.remoteAddress,
    userAgent: req.get('User-Agent'),
  });

  // 8. Return response
  res.status(200).json({
    message: 'Login successful',
    token: accessToken,
    refreshToken,
    user: {
      id: user.id,
      username: user.username,
      email: user.email,
      fullName: user.fullName,
      role: user.role,
      language: user.language,
    },
  });
});

/**
 * Refresh Token - ใช้ refresh token เพื่อได้ access token ใหม่
 * POST /api/auth/refresh
 * Body: { refreshToken: string }
 */
export const refresh = asyncHandler(async (req: Request, res: Response): Promise<void> => {
  const { refreshToken } = req.body;

  if (!refreshToken) {
    throw new ValidationError('Refresh token is required', 'refreshToken', undefined, req.requestId);
  }

  log.info('Token refresh attempt', {
    requestId: req.requestId,
    ip: req.ip || req.connection.remoteAddress,
  });

  // 1. Verify refresh token
  let decoded: RefreshTokenPayload;
  try {
    decoded = jwt.verify(refreshToken, jwtConfig.secret) as RefreshTokenPayload;
  } catch (error) {
    log.warn('Invalid refresh token', {
      requestId: req.requestId,
      error: error instanceof Error ? error.message : 'Unknown error',
      ip: req.ip || req.connection.remoteAddress,
    });
    throw new AuthenticationError('Invalid refresh token', req.requestId);
  }

  // 2. Check if refresh token exists in database
  const storedToken = await prisma.refreshToken.findUnique({
    where: { token: refreshToken },
    include: { user: true },
  });

  if (!storedToken) {
    log.warn('Refresh token not found in database', {
      requestId: req.requestId,
      userId: decoded.id,
      ip: req.ip || req.connection.remoteAddress,
    });
    throw new AuthenticationError('Invalid refresh token', req.requestId);
  }

  // 3. Check if token is expired
  if (storedToken.expiresAt < new Date()) {
    // Remove expired token
    await prisma.refreshToken.delete({
      where: { id: storedToken.id },
    });

    log.warn('Expired refresh token used', {
      requestId: req.requestId,
      userId: storedToken.userId,
      ip: req.ip || req.connection.remoteAddress,
    });
    throw new AuthenticationError('Refresh token expired', req.requestId);
  }

  // 4. Check if user is still active
  if (!storedToken.user.isActive) {
    // Remove token for inactive user
    await prisma.refreshToken.delete({
      where: { id: storedToken.id },
    });

    log.warn('Refresh token used for inactive user', {
      requestId: req.requestId,
      userId: storedToken.userId,
      ip: req.ip || req.connection.remoteAddress,
    });
    throw new AuthenticationError('Account is deactivated', req.requestId);
  }

  // 5. Generate new access token
  const newAccessToken = generateAccessToken({
    id: storedToken.user.id,
    username: storedToken.user.username,
    role: storedToken.user.role,
  });

  // 6. Log successful refresh
  log.auth('Token refresh successful', storedToken.userId, {
    requestId: req.requestId,
    username: storedToken.user.username,
    ip: req.ip || req.connection.remoteAddress,
  });

  // 7. Return new access token
  res.status(200).json({
    message: 'Token refreshed successfully',
    token: newAccessToken,
    user: {
      id: storedToken.user.id,
      username: storedToken.user.username,
      email: storedToken.user.email,
      fullName: storedToken.user.fullName,
      role: storedToken.user.role,
      language: storedToken.user.language,
    },
  });
});

/**
 * Logout - ลบ refresh token และ logout
 * POST /api/auth/logout
 * Headers: { Authorization: Bearer <token> }
 * Body: { refreshToken?: string }
 */
export const logout = asyncHandler(async (req: Request, res: Response): Promise<void> => {
  const { refreshToken } = req.body;
  const userId = req.user?.id;

  log.info('Logout attempt', {
    requestId: req.requestId,
    userId,
    ip: req.ip || req.connection.remoteAddress,
  });

  // If refresh token is provided, remove it
  if (refreshToken) {
    await prisma.refreshToken.deleteMany({
      where: {
        token: refreshToken,
        userId: userId,
      },
    });

    log.auth('Refresh token revoked', userId, {
      requestId: req.requestId,
      ip: req.ip || req.connection.remoteAddress,
    });
  }

  res.status(200).json({
    message: 'Logout successful',
  });
});

/**
 * Logout All Devices - ลบ refresh tokens ทั้งหมดของผู้ใช้
 * POST /api/auth/logout-all
 * Headers: { Authorization: Bearer <token> }
 */
export const logoutAllDevices = asyncHandler(async (req: Request, res: Response): Promise<void> => {
  const userId = req.user?.id;

  if (!userId) {
    throw new AuthenticationError('User not authenticated', req.requestId);
  }

  log.info('Logout all devices attempt', {
    requestId: req.requestId,
    userId,
    ip: req.ip || req.connection.remoteAddress,
  });

  // Remove all refresh tokens for this user
  const result = await prisma.refreshToken.deleteMany({
    where: { userId },
  });

  log.auth('All devices logged out', userId, {
    requestId: req.requestId,
    tokensRemoved: result.count,
    ip: req.ip || req.connection.remoteAddress,
  });

  res.status(200).json({
    message: 'All devices logged out successfully',
    tokensRemoved: result.count,
  });
});

/**
 * Get Current User - ดึงข้อมูลผู้ใช้ปัจจุบัน
 * GET /api/auth/me
 * Headers: { Authorization: Bearer <token> }
 */
export const getCurrentUser = asyncHandler(async (req: Request, res: Response): Promise<void> => {
  const userId = req.user?.id;

  if (!userId) {
    throw new AuthenticationError('User not authenticated', req.requestId);
  }

  // Get user data
  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: {
      id: true,
      username: true,
      email: true,
      fullName: true,
      role: true,
      language: true,
      isActive: true,
      createdAt: true,
      updatedAt: true,
    },
  });

  if (!user) {
    throw new AuthenticationError('User not found', req.requestId);
  }

  res.status(200).json({
    user,
  });
});

/**
 * Change Password - เปลี่ยนรหัสผ่าน
 * POST /api/auth/change-password
 * Headers: { Authorization: Bearer <token> }
 * Body: { currentPassword: string, newPassword: string }
 */
export const changePassword = asyncHandler(async (req: Request, res: Response): Promise<void> => {
  const { currentPassword, newPassword } = req.body;
  const userId = req.user?.id;

  if (!userId) {
    throw new AuthenticationError('User not authenticated', req.requestId);
  }

  // Validate input
  if (!currentPassword || !newPassword) {
    throw new ValidationError('Current password and new password are required', 'password', undefined, req.requestId);
  }

  // Get user with password
  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: { id: true, username: true, password: true },
  });

  if (!user) {
    throw new AuthenticationError('User not found', req.requestId);
  }

  // Verify current password
  const isCurrentPasswordValid = await bcrypt.compare(currentPassword, user.password);
  if (!isCurrentPasswordValid) {
    log.warn('Change password failed - invalid current password', {
      requestId: req.requestId,
      userId,
      username: user.username,
      ip: req.ip || req.connection.remoteAddress,
    });
    throw new AuthenticationError('Current password is incorrect', req.requestId);
  }

  // Hash new password
  const hashedNewPassword = await bcrypt.hash(newPassword, 12);

  // Update password
  await prisma.user.update({
    where: { id: userId },
    data: { password: hashedNewPassword },
  });

  // Revoke all refresh tokens (force re-login on all devices)
  await prisma.refreshToken.deleteMany({
    where: { userId },
  });

  log.auth('Password changed successfully', userId, {
    requestId: req.requestId,
    username: user.username,
    ip: req.ip || req.connection.remoteAddress,
  });

  res.status(200).json({
    message: 'Password changed successfully. Please login again.',
  });
});

export default {
  login,
  refresh,
  logout,
  logoutAllDevices,
  getCurrentUser,
  changePassword,
};
