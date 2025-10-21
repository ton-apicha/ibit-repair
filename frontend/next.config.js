/** @type {import('next').NextConfig} */

/**
 * Next.js Configuration
 * ไฟล์นี้ใช้สำหรับตั้งค่า Next.js application
 */

const nextConfig = {
  // เปิดใช้งาน Standalone output สำหรับ Docker deployment
  output: 'standalone',

  // การตั้งค่ารูปภาพ
  images: {
    // อนุญาตให้โหลดรูปจาก domains เหล่านี้
    domains: ['localhost'],
    // รูปแบบรูปภาพที่รองรับ
    formats: ['image/webp', 'image/avif'],
  },

  // Experimental features
  experimental: {
    // เปิดใช้งาน Server Actions (ถ้าต้องการใช้)
    serverActions: true,
  },

  // Environment variables ที่จะส่งไปให้ client-side
  env: {
    NEXT_PUBLIC_API_URL: process.env.NEXT_PUBLIC_API_URL || 'http://localhost:4000',
  },

  // Webpack configuration (ถ้าต้องการปรับแต่ง)
  webpack: (config, { isServer }) => {
    // ปรับแต่ง webpack config ได้ที่นี่
    return config;
  },
};

module.exports = nextConfig;

