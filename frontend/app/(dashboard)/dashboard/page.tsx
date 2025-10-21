/**
 * Dashboard Page
 * หน้า Dashboard หลักหลัง Login
 */

'use client';

import { useAuthStore } from '@/store/useAuthStore';
import { getRoleLabel } from '@/lib/utils';

export default function DashboardPage() {
  const user = useAuthStore((state) => state.user);

  return (
    <div className="min-h-screen bg-gray-50 p-4 md:p-8">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900">Dashboard</h1>
          <p className="text-gray-600 mt-2">
            ยินดีต้อนรับเข้าสู่ระบบซ่อมเครื่องขุด ASIC
          </p>
        </div>

        {/* User Info Card */}
        <div className="card mb-8">
          <h2 className="text-xl font-semibold mb-4">ข้อมูลผู้ใช้</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <p className="text-sm text-gray-600">ชื่อผู้ใช้</p>
              <p className="font-medium">{user?.username}</p>
            </div>
            <div>
              <p className="text-sm text-gray-600">ชื่อ-นามสกุล</p>
              <p className="font-medium">{user?.fullName}</p>
            </div>
            <div>
              <p className="text-sm text-gray-600">อีเมล</p>
              <p className="font-medium">{user?.email}</p>
            </div>
            <div>
              <p className="text-sm text-gray-600">บทบาท</p>
              <p className="font-medium">
                {user?.role && getRoleLabel(user.role)}
              </p>
            </div>
          </div>
        </div>

        {/* Quick Stats (Placeholder) */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <div className="card bg-blue-50">
            <div className="text-3xl mb-2">📋</div>
            <h3 className="text-sm text-gray-600 mb-1">งานซ่อมทั้งหมด</h3>
            <p className="text-2xl font-bold text-blue-700">-</p>
          </div>

          <div className="card bg-orange-50">
            <div className="text-3xl mb-2">🔧</div>
            <h3 className="text-sm text-gray-600 mb-1">กำลังซ่อม</h3>
            <p className="text-2xl font-bold text-orange-700">-</p>
          </div>

          <div className="card bg-green-50">
            <div className="text-3xl mb-2">✅</div>
            <h3 className="text-sm text-gray-600 mb-1">เสร็จสิ้น</h3>
            <p className="text-2xl font-bold text-green-700">-</p>
          </div>

          <div className="card bg-purple-50">
            <div className="text-3xl mb-2">📦</div>
            <h3 className="text-sm text-gray-600 mb-1">อะไหล่คงเหลือ</h3>
            <p className="text-2xl font-bold text-purple-700">-</p>
          </div>
        </div>

        {/* Coming Soon */}
        <div className="card text-center py-12">
          <div className="text-6xl mb-4">🚧</div>
          <h2 className="text-2xl font-bold text-gray-900 mb-2">
            กำลังพัฒนา...
          </h2>
          <p className="text-gray-600">
            Dashboard จะแสดงสถิติและกราฟต่างๆ ในขั้นตอนถัดไป
          </p>
        </div>
      </div>
    </div>
  );
}

