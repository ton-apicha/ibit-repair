/**
 * Authentication Controller
 * จัดการ Login, Logout, และ Refresh Token
 */

import { Request, Response } from 'express';
import bcrypt from 'bcrypt';
import prisma from '../utils/prisma';
import { generateToken } from '../utils/jwt';

/**
 * Login - ตรวจสอบ username/password และออก JWT token
 * POST /api/auth/login
 * Body: { username: string, password: string }
 */
export const login = async (req: Request, res: Response): Promise<void> => {
  try {
    const { username, password } = req.body;

    // 1. ตรวจสอบว่ามี username และ password หรือไม่
    if (!username || !password) {
      res.status(400).json({
        error: 'Bad Request',
        message: 'กรุณากรอก username และ password',
      });
      return;
    }

    // 2. ค้นหา user จาก database
    const user = await prisma.user.findUnique({
      where: { username },
      select: {
        id: true,
        username: true,
        email: true,
        passwordHash: true,
        fullName: true,
        role: true,
        isActive: true,
      },
    });

    // 3. ตรวจสอบว่า user มีอยู่หรือไม่
    if (!user) {
      res.status(401).json({
        error: 'Unauthorized',
        message: 'ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง',
      });
      return;
    }

    // 4. ตรวจสอบว่า user ถูก active หรือไม่
    if (!user.isActive) {
      res.status(401).json({
        error: 'Unauthorized',
        message: 'บัญชีนี้ถูกระงับการใช้งาน กรุณาติดต่อผู้ดูแลระบบ',
      });
      return;
    }

    // 5. ตรวจสอบ password (เปรียบเทียบ password ที่กรอกกับ hash ในฐานข้อมูล)
    const isPasswordValid = await bcrypt.compare(password, user.passwordHash);

    if (!isPasswordValid) {
      res.status(401).json({
        error: 'Unauthorized',
        message: 'ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง',
      });
      return;
    }

    // 6. สร้าง JWT token
    const token = generateToken({
      id: user.id,
      username: user.username,
      role: user.role,
    });

    // 7. ส่ง response พร้อม token และข้อมูล user (ไม่ส่ง passwordHash)
    res.status(200).json({
      message: 'เข้าสู่ระบบสำเร็จ',
      token,
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        fullName: user.fullName,
        role: user.role,
      },
    });
  } catch (error) {
    console.error('❌ Login error:', error);
    res.status(500).json({
      error: 'Internal Server Error',
      message: 'เกิดข้อผิดพลาดในการเข้าสู่ระบบ',
    });
  }
};

/**
 * Get Current User - ดึงข้อมูล user ที่ login อยู่
 * GET /api/auth/me
 * Headers: Authorization: Bearer <token>
 */
export const getCurrentUser = async (
  req: Request,
  res: Response
): Promise<void> => {
  try {
    // req.user ถูกตั้งค่าโดย authenticate middleware
    if (!req.user) {
      res.status(401).json({
        error: 'Unauthorized',
        message: 'กรุณา login ก่อนเข้าใช้งาน',
      });
      return;
    }

    // ดึงข้อมูล user จากฐานข้อมูล (เพื่อให้ได้ข้อมูลล่าสุด)
    const user = await prisma.user.findUnique({
      where: { id: req.user.id },
      select: {
        id: true,
        username: true,
        email: true,
        fullName: true,
        role: true,
        isActive: true,
        createdAt: true,
      },
    });

    if (!user) {
      res.status(404).json({
        error: 'Not Found',
        message: 'ไม่พบข้อมูลผู้ใช้',
      });
      return;
    }

    // ส่งข้อมูล user กลับไป
    res.status(200).json(user);
  } catch (error) {
    console.error('❌ Get current user error:', error);
    res.status(500).json({
      error: 'Internal Server Error',
      message: 'เกิดข้อผิดพลาดในการดึงข้อมูลผู้ใช้',
    });
  }
};

/**
 * Logout - ออกจากระบบ
 * POST /api/auth/logout
 * 
 * หมายเหตุ: สำหรับ JWT ไม่มีการ logout จริงๆ บน server
 * Client จะลบ token ออกจาก localStorage
 * ถ้าต้องการ implement blacklist token สามารถเพิ่มได้ในอนาคต
 */
export const logout = async (req: Request, res: Response): Promise<void> => {
  try {
    // สำหรับ JWT ปกติจะให้ client ลบ token เอง
    // แต่เราอาจจะบันทึก logout event ลง database (optional)
    
    res.status(200).json({
      message: 'ออกจากระบบสำเร็จ',
    });
  } catch (error) {
    console.error('❌ Logout error:', error);
    res.status(500).json({
      error: 'Internal Server Error',
      message: 'เกิดข้อผิดพลาดในการออกจากระบบ',
    });
  }
};

