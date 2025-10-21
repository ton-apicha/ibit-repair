/**
 * Dashboard Layout
 * Layout สำหรับหน้าที่ต้อง Login (Protected Routes)
 */

'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useAuthStore } from '@/store/useAuthStore';
import Link from 'next/link';

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const router = useRouter();
  const { isAuthenticated, user, logout, checkAuth } = useAuthStore();

  // ตรวจสอบ authentication เมื่อ component mount
  useEffect(() => {
    checkAuth();
    
    // ถ้าไม่ได้ login ให้ redirect ไป login page
    if (!isAuthenticated) {
      router.push('/login');
    }
  }, [isAuthenticated, router, checkAuth]);

  // ถ้ายังไม่ได้ login แสดง loading
  if (!isAuthenticated || !user) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <div className="text-4xl mb-4">⚙️</div>
          <p className="text-gray-600">กำลังโหลด...</p>
        </div>
      </div>
    );
  }

  /**
   * Handle Logout
   */
  const handleLogout = () => {
    logout();
    router.push('/login');
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Top Navigation Bar */}
      <nav className="bg-white border-b border-gray-200 sticky top-0 z-10">
        <div className="px-4 py-3">
          <div className="flex items-center justify-between">
            {/* Logo */}
            <Link href="/dashboard" className="flex items-center space-x-2">
              <span className="text-2xl">⚙️</span>
              <span className="font-bold text-lg hidden md:inline">
                IBIT Repair
              </span>
            </Link>

            {/* User Menu */}
            <div className="flex items-center space-x-4">
              <div className="hidden md:block text-right">
                <p className="text-sm font-medium text-gray-900">
                  {user.fullName}
                </p>
                <p className="text-xs text-gray-500">{user.role}</p>
              </div>

              <button
                onClick={handleLogout}
                className="btn-secondary text-sm"
              >
                ออกจากระบบ
              </button>
            </div>
          </div>
        </div>
      </nav>

      {/* Bottom Navigation (Mobile) */}
      <nav className="md:hidden fixed bottom-0 left-0 right-0 bg-white border-t border-gray-200 z-10">
        <div className="grid grid-cols-5 gap-1 p-2">
          <Link
            href="/dashboard"
            className="flex flex-col items-center py-2 text-primary-600"
          >
            <span className="text-xl mb-1">🏠</span>
            <span className="text-xs">หน้าแรก</span>
          </Link>

          <Link
            href="/jobs"
            className="flex flex-col items-center py-2 text-gray-600"
          >
            <span className="text-xl mb-1">📋</span>
            <span className="text-xs">งานซ่อม</span>
          </Link>

          <Link
            href="/customers"
            className="flex flex-col items-center py-2 text-gray-600"
          >
            <span className="text-xl mb-1">👥</span>
            <span className="text-xs">ลูกค้า</span>
          </Link>

          <Link
            href="/parts"
            className="flex flex-col items-center py-2 text-gray-600"
          >
            <span className="text-xl mb-1">📦</span>
            <span className="text-xs">อะไหล่</span>
          </Link>

          <Link
            href="/reports"
            className="flex flex-col items-center py-2 text-gray-600"
          >
            <span className="text-xl mb-1">📊</span>
            <span className="text-xs">รายงาน</span>
          </Link>
        </div>
      </nav>

      {/* Desktop Sidebar Navigation */}
      <div className="hidden md:flex">
        <aside className="w-64 bg-white border-r border-gray-200 min-h-[calc(100vh-57px)] fixed">
          <nav className="p-4 space-y-1">
            <Link
              href="/dashboard"
              className="flex items-center space-x-3 px-4 py-3 rounded-lg bg-primary-50 text-primary-700 font-medium"
            >
              <span className="text-xl">🏠</span>
              <span>หน้าแรก</span>
            </Link>

            <Link
              href="/jobs"
              className="flex items-center space-x-3 px-4 py-3 rounded-lg text-gray-700 hover:bg-gray-100"
            >
              <span className="text-xl">📋</span>
              <span>งานซ่อม</span>
            </Link>

            <Link
              href="/customers"
              className="flex items-center space-x-3 px-4 py-3 rounded-lg text-gray-700 hover:bg-gray-100"
            >
              <span className="text-xl">👥</span>
              <span>ลูกค้า</span>
            </Link>

            <Link
              href="/parts"
              className="flex items-center space-x-3 px-4 py-3 rounded-lg text-gray-700 hover:bg-gray-100"
            >
              <span className="text-xl">📦</span>
              <span>อะไหล่</span>
            </Link>

            <Link
              href="/reports"
              className="flex items-center space-x-3 px-4 py-3 rounded-lg text-gray-700 hover:bg-gray-100"
            >
              <span className="text-xl">📊</span>
              <span>รายงาน</span>
            </Link>

            {/* Admin Only */}
            {user.role === 'ADMIN' && (
              <Link
                href="/settings"
                className="flex items-center space-x-3 px-4 py-3 rounded-lg text-gray-700 hover:bg-gray-100"
              >
                <span className="text-xl">⚙️</span>
                <span>ตั้งค่า</span>
              </Link>
            )}
          </nav>
        </aside>

        {/* Main Content */}
        <main className="ml-64 w-full">
          {children}
        </main>
      </div>

      {/* Mobile Main Content */}
      <main className="md:hidden pb-20">
        {children}
      </main>
    </div>
  );
}

