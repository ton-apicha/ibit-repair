/**
 * JWT Utilities
 * ฟังก์ชันสำหรับการสร้างและตรวจสอบ JWT Token
 */

import jwt from 'jsonwebtoken';
// Role types: "ADMIN" | "MANAGER" | "TECHNICIAN" | "RECEPTIONIST"

/**
 * Interface สำหรับ Token Payload
 */
export interface TokenPayload {
  id: string;
  username: string;
  role: string;
}

/**
 * สร้าง JWT Access Token
 * @param payload - ข้อมูลที่ต้องการเก็บใน token (user id, username, role)
 * @returns JWT token string
 */
export const generateToken = (payload: TokenPayload): string => {
  // ดึง JWT_SECRET จาก environment variable
  const JWT_SECRET = process.env.JWT_SECRET;
  if (!JWT_SECRET) {
    throw new Error('JWT_SECRET is not defined in environment variables');
  }

  // ดึงเวลา expiration (default 24 ชั่วโมง)
  const expiresIn = process.env.JWT_EXPIRES_IN || '86400'; // 86400 วินาที = 24 ชั่วโมง

  // สร้าง token
  const token = jwt.sign(payload, JWT_SECRET, {
    expiresIn: parseInt(expiresIn), // เวลาหมดอายุ (วินาที)
  });

  return token;
};

/**
 * ตรวจสอบและถอดรหัส JWT Token
 * @param token - JWT token string
 * @returns Token payload ถ้าถูกต้อง, null ถ้าไม่ถูกต้อง
 */
export const verifyToken = (token: string): TokenPayload | null => {
  try {
    const JWT_SECRET = process.env.JWT_SECRET;
    if (!JWT_SECRET) {
      throw new Error('JWT_SECRET is not defined in environment variables');
    }

    // Verify และ decode token
    const decoded = jwt.verify(token, JWT_SECRET) as TokenPayload;
    return decoded;
  } catch (error) {
    // Token ไม่ถูกต้องหรือหมดอายุ
    return null;
  }
};

/**
 * ตัวอย่างการใช้งาน:
 * 
 * // สร้าง token
 * const token = generateToken({
 *   id: user.id,
 *   username: user.username,
 *   role: user.role
 * });
 * 
 * // ตรวจสอบ token
 * const payload = verifyToken(token);
 * if (payload) {
 *   console.log('User ID:', payload.id);
 * } else {
 *   console.log('Token ไม่ถูกต้อง');
 * }
 */

