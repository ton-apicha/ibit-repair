/**
 * API Client
 * ไฟล์นี้ใช้สำหรับเรียก Backend API
 */

import axios, { AxiosInstance, AxiosError } from 'axios';

// สร้าง axios instance
const api: AxiosInstance = axios.create({
  baseURL: process.env.NEXT_PUBLIC_API_URL || 'http://localhost:4000',
  timeout: 30000, // 30 วินาที
  headers: {
    'Content-Type': 'application/json',
  },
});

/**
 * Request Interceptor
 * ดักจับ request ก่อนส่งไป backend
 * ใช้สำหรับแนบ JWT token
 */
api.interceptors.request.use(
  (config) => {
    // ดึง token จาก localStorage (ถ้ามี)
    if (typeof window !== 'undefined') {
      const token = localStorage.getItem('token');
      if (token) {
        config.headers.Authorization = `Bearer ${token}`;
      }
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

/**
 * Response Interceptor
 * ดักจับ response จาก backend
 * ใช้สำหรับจัดการ error แบบรวมศูนย์
 */
api.interceptors.response.use(
  (response) => {
    // ถ้า response สำเร็จ ส่งต่อไปเลย
    return response;
  },
  (error: AxiosError) => {
    // จัดการ error ตามสถานะ HTTP
    if (error.response) {
      const status = error.response.status;

      // 401 Unauthorized - Token หมดอายุหรือไม่ถูกต้อง
      if (status === 401) {
        // ลบ token และ redirect ไป login
        if (typeof window !== 'undefined') {
          localStorage.removeItem('token');
          localStorage.removeItem('user');
          window.location.href = '/login';
        }
      }

      // 403 Forbidden - ไม่มีสิทธิ์เข้าถึง
      if (status === 403) {
        console.error('คุณไม่มีสิทธิ์เข้าถึงส่วนนี้');
      }

      // 404 Not Found
      if (status === 404) {
        console.error('ไม่พบข้อมูลที่ต้องการ');
      }

      // 500 Internal Server Error
      if (status === 500) {
        console.error('เกิดข้อผิดพลาดภายในเซิร์ฟเวอร์');
      }
    }

    return Promise.reject(error);
  }
);

export default api;

/**
 * ตัวอย่างการใช้งาน:
 * 
 * import api from '@/lib/api';
 * 
 * // GET request
 * const response = await api.get('/api/jobs');
 * const jobs = response.data;
 * 
 * // POST request
 * const response = await api.post('/api/jobs', {
 *   customerId: '123',
 *   modelId: '456',
 *   symptoms: 'ไม่ทำงาน'
 * });
 * 
 * // PUT request
 * await api.put('/api/jobs/123', { status: 'IN_REPAIR' });
 * 
 * // DELETE request
 * await api.delete('/api/jobs/123');
 */

