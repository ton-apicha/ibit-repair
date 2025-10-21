/**
 * Auth Store (Zustand)
 * จัดการ state สำหรับ Authentication
 */

'use client';

import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import api from '@/lib/api';

// Interface สำหรับข้อมูล User
interface User {
  id: string;
  username: string;
  email: string;
  fullName: string;
  role: 'ADMIN' | 'MANAGER' | 'TECHNICIAN' | 'RECEPTIONIST';
}

// Interface สำหรับ Auth Store State
interface AuthState {
  // State
  user: User | null;
  token: string | null;
  isAuthenticated: boolean;
  isLoading: boolean;

  // Actions
  login: (username: string, password: string) => Promise<void>;
  logout: () => void;
  checkAuth: () => Promise<void>;
  setUser: (user: User) => void;
}

/**
 * Auth Store
 * ใช้ persist middleware เพื่อเก็บข้อมูลใน localStorage
 */
export const useAuthStore = create<AuthState>()(
  persist(
    (set, get) => ({
      // ==================
      // Initial State
      // ==================
      user: null,
      token: null,
      isAuthenticated: false,
      isLoading: false,

      // ==================
      // Login
      // ==================
      login: async (username: string, password: string) => {
        try {
          set({ isLoading: true });

          // เรียก API login
          const response = await api.post('/api/auth/login', {
            username,
            password,
          });

          const { token, user } = response.data;

          // เก็บ token ใน localStorage (ผ่าน api.ts interceptor)
          if (typeof window !== 'undefined') {
            localStorage.setItem('token', token);
            localStorage.setItem('user', JSON.stringify(user));
          }

          // อัพเดท state
          set({
            user,
            token,
            isAuthenticated: true,
            isLoading: false,
          });
        } catch (error: any) {
          set({ isLoading: false });
          
          // แสดง error message
          const message =
            error.response?.data?.message || 'เกิดข้อผิดพลาดในการเข้าสู่ระบบ';
          throw new Error(message);
        }
      },

      // ==================
      // Logout
      // ==================
      logout: () => {
        // ลบข้อมูลจาก localStorage
        if (typeof window !== 'undefined') {
          localStorage.removeItem('token');
          localStorage.removeItem('user');
        }

        // Reset state
        set({
          user: null,
          token: null,
          isAuthenticated: false,
        });
      },

      // ==================
      // Check Authentication
      // ตรวจสอบว่า token ยังใช้ได้หรือไม่
      // ==================
      checkAuth: async () => {
        try {
          const token = get().token;

          // ถ้าไม่มี token ให้ logout
          if (!token) {
            get().logout();
            return;
          }

          // เรียก API เพื่อตรวจสอบ token
          const response = await api.get('/api/auth/me');
          const user = response.data;

          // อัพเดท user ข้อมูลล่าสุด
          set({
            user,
            isAuthenticated: true,
          });
        } catch (error) {
          // ถ้า token หมดอายุหรือไม่ถูกต้อง ให้ logout
          get().logout();
        }
      },

      // ==================
      // Set User
      // ==================
      setUser: (user: User) => {
        set({ user });
      },
    }),
    {
      // ชื่อ key ใน localStorage
      name: 'auth-storage',
      
      // เก็บเฉพาะ state ที่ต้องการ persist
      partialize: (state) => ({
        user: state.user,
        token: state.token,
        isAuthenticated: state.isAuthenticated,
      }),
    }
  )
);

/**
 * ตัวอย่างการใช้งาน:
 * 
 * const { user, login, logout, isAuthenticated } = useAuthStore();
 * 
 * // Login
 * await login('admin', 'admin123');
 * 
 * // Logout
 * logout();
 * 
 * // ตรวจสอบ role
 * if (user?.role === 'ADMIN') {
 *   // Admin only action
 * }
 */

