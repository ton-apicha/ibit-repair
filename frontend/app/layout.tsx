/**
 * Root Layout
 * Layout หลักของทั้งแอปพลิเคชัน - ครอบทุกหน้า
 */

import type { Metadata } from 'next';
import './globals.css';

// Metadata สำหรับ SEO
export const metadata: Metadata = {
  title: 'ระบบซ่อมเครื่องขุด ASIC | IBIT Repair',
  description: 'ระบบจัดการซ่อมเครื่องขุดบิทคอยน์ ASIC ครบวงจร',
  viewport: 'width=device-width, initial-scale=1, maximum-scale=1',
  themeColor: '#0ea5e9',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="th">
      <body>
        {/* Main content */}
        {children}
      </body>
    </html>
  );
}

