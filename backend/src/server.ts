/**
 * Express Server หลักสำหรับ Backend API
 * ไฟล์นี้เป็นจุดเริ่มต้นของระบบ Backend
 */

import express, { Express, Request, Response, NextFunction } from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import path from 'path';

// โหลดค่า environment variables จากไฟล์ .env
dotenv.config();

// สร้าง Express application
const app: Express = express();
const PORT = process.env.PORT || 4000;

// ========================
// Middleware Configuration
// ========================

// 1. CORS - อนุญาตให้ Frontend เรียก API ได้
app.use(
  cors({
    origin: process.env.CORS_ORIGIN || 'http://localhost:3000', // URL ของ Frontend
    credentials: true, // อนุญาตให้ส่ง cookies/credentials
  })
);

// 2. Parse JSON request body
app.use(express.json());

// 3. Parse URL-encoded request body
app.use(express.urlencoded({ extended: true }));

// 4. Static files สำหรับรูปภาพที่ upload
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

// ========================
// Routes
// ========================

// Health check endpoint (ทดสอบว่า server รันอยู่)
app.get('/health', (req: Request, res: Response) => {
  res.status(200).json({
    status: 'OK',
    message: 'Server is running',
    timestamp: new Date().toISOString(),
  });
});

// ========================
// API Routes
// ========================

// Import routes
import authRoutes from './routes/auth.routes';
import customerRoutes from './routes/customer.routes';

// Authentication routes
app.use('/api/auth', authRoutes);

// Customer routes
app.use('/api/customers', customerRoutes);

// TODO: เพิ่ม routes อื่นๆ
// app.use('/api/jobs', jobRoutes);
// app.use('/api/parts', partRoutes);
// app.use('/api/reports', reportRoutes);

// ========================
// Error Handling
// ========================

// 404 Not Found handler
app.use((req: Request, res: Response) => {
  res.status(404).json({
    error: 'Not Found',
    message: `ไม่พบ API endpoint: ${req.method} ${req.path}`,
  });
});

// Global Error Handler
app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
  console.error('❌ Error:', err);
  
  res.status(500).json({
    error: 'Internal Server Error',
    message: err.message || 'เกิดข้อผิดพลาดภายในเซิร์ฟเวอร์',
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack }), // แสดง stack trace ใน development mode
  });
});

// ========================
// Start Server
// ========================

app.listen(PORT, () => {
  console.log('');
  console.log('🚀 ระบบซ่อมเครื่องขุดบิทคอยน์ ASIC - Backend API');
  console.log('================================================');
  console.log(`📡 Server กำลังรันที่: http://localhost:${PORT}`);
  console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`📁 Upload folder: ${path.join(__dirname, '../uploads')}`);
  console.log('================================================');
  console.log('');
});

// Graceful Shutdown (ปิด server อย่างสง่างาม)
process.on('SIGTERM', () => {
  console.log('👋 SIGTERM signal received: closing server...');
  process.exit(0);
});

process.on('SIGINT', () => {
  console.log('\n👋 SIGINT signal received: closing server...');
  process.exit(0);
});

