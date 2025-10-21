/**
 * Edit Customer Page
 * หน้าแก้ไขข้อมูลลูกค้า
 */

'use client';

import { useState, useEffect, FormEvent } from 'react';
import { useParams, useRouter } from 'next/navigation';
import Link from 'next/link';
import api from '@/lib/api';

// Interface
interface Customer {
  id: string;
  name: string;
  phone: string;
  email: string | null;
  address: string | null;
  notes: string | null;
}

export default function EditCustomerPage() {
  const params = useParams();
  const router = useRouter();

  // State
  const [customer, setCustomer] = useState<Customer | null>(null);
  const [name, setName] = useState('');
  const [phone, setPhone] = useState('');
  const [email, setEmail] = useState('');
  const [address, setAddress] = useState('');
  const [notes, setNotes] = useState('');
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');

  /**
   * ดึงข้อมูลลูกค้า
   */
  const fetchCustomer = async () => {
    try {
      setLoading(true);
      const response = await api.get(`/api/customers/${params.id}`);
      const data = response.data;

      setCustomer(data);
      setName(data.name);
      setPhone(data.phone);
      setEmail(data.email || '');
      setAddress(data.address || '');
      setNotes(data.notes || '');
    } catch (error: any) {
      console.error('Error fetching customer:', error);
      if (error.response?.status === 404) {
        router.push('/customers');
      }
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchCustomer();
  }, [params.id]);

  /**
   * Handle Submit
   */
  const handleSubmit = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setError('');

    // ตรวจสอบข้อมูล
    if (!name.trim() || !phone.trim()) {
      setError('กรุณากรอกชื่อและเบอร์โทรศัพท์');
      return;
    }

    try {
      setSaving(true);

      // เรียก API อัพเดท
      await api.put(`/api/customers/${params.id}`, {
        name: name.trim(),
        phone: phone.trim(),
        email: email.trim() || null,
        address: address.trim() || null,
        notes: notes.trim() || null,
      });

      // Redirect กลับไปหน้า detail
      router.push(`/customers/${params.id}`);
    } catch (err: any) {
      setError(
        err.response?.data?.message || 'เกิดข้อผิดพลาดในการบันทึกข้อมูล'
      );
      setSaving(false);
    }
  };

  // Loading state
  if (loading) {
    return (
      <div className="p-4 md:p-8">
        <div className="text-center py-12">
          <div className="text-4xl mb-4">⏳</div>
          <p className="text-gray-600">กำลังโหลด...</p>
        </div>
      </div>
    );
  }

  // Not found
  if (!customer) {
    return (
      <div className="p-4 md:p-8">
        <div className="text-center py-12">
          <div className="text-6xl mb-4">😕</div>
          <h3 className="text-xl font-semibold mb-2">ไม่พบข้อมูลลูกค้า</h3>
          <Link href="/customers" className="btn-primary mt-4 inline-block">
            กลับหน้ารายการ
          </Link>
        </div>
      </div>
    );
  }

  return (
    <div className="p-4 md:p-8">
      <div className="max-w-2xl mx-auto">
        {/* Header */}
        <div className="mb-6">
          <Link
            href={`/customers/${params.id}`}
            className="text-primary-600 hover:text-primary-700 text-sm mb-2 inline-block"
          >
            ← กลับ
          </Link>
          <h1 className="text-2xl md:text-3xl font-bold text-gray-900">
            แก้ไขข้อมูลลูกค้า
          </h1>
        </div>

        {/* Form */}
        <form onSubmit={handleSubmit} className="card">
          {/* Error Message */}
          {error && (
            <div className="mb-6 bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg text-sm">
              {error}
            </div>
          )}

          {/* ชื่อ-นามสกุล */}
          <div className="mb-4">
            <label className="block text-sm font-medium text-gray-700 mb-2">
              ชื่อ-นามสกุล <span className="text-red-500">*</span>
            </label>
            <input
              type="text"
              value={name}
              onChange={(e) => setName(e.target.value)}
              className="input-field"
              placeholder="นาย สมชาย ใจดี"
              required
              disabled={saving}
            />
          </div>

          {/* เบอร์โทรศัพท์ */}
          <div className="mb-4">
            <label className="block text-sm font-medium text-gray-700 mb-2">
              เบอร์โทรศัพท์ <span className="text-red-500">*</span>
            </label>
            <input
              type="tel"
              value={phone}
              onChange={(e) => setPhone(e.target.value)}
              className="input-field"
              placeholder="08x-xxx-xxxx"
              required
              disabled={saving}
            />
          </div>

          {/* อีเมล */}
          <div className="mb-4">
            <label className="block text-sm font-medium text-gray-700 mb-2">
              อีเมล
            </label>
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="input-field"
              placeholder="example@email.com"
              disabled={saving}
            />
          </div>

          {/* ที่อยู่ */}
          <div className="mb-4">
            <label className="block text-sm font-medium text-gray-700 mb-2">
              ที่อยู่
            </label>
            <textarea
              value={address}
              onChange={(e) => setAddress(e.target.value)}
              className="input-field"
              rows={3}
              placeholder="123 ถนน... ตำบล... อำเภอ... จังหวัด..."
              disabled={saving}
            />
          </div>

          {/* หมายเหตุ */}
          <div className="mb-6">
            <label className="block text-sm font-medium text-gray-700 mb-2">
              หมายเหตุ
            </label>
            <textarea
              value={notes}
              onChange={(e) => setNotes(e.target.value)}
              className="input-field"
              rows={2}
              placeholder="บันทึกเพิ่มเติม..."
              disabled={saving}
            />
          </div>

          {/* Buttons */}
          <div className="flex flex-col-reverse md:flex-row gap-3">
            <Link
              href={`/customers/${params.id}`}
              className="btn-secondary text-center"
            >
              ยกเลิก
            </Link>
            <button
              type="submit"
              className="btn-primary"
              disabled={saving}
            >
              {saving ? 'กำลังบันทึก...' : 'บันทึกการแก้ไข'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

