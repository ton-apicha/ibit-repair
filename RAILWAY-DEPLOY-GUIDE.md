# 🚂 Railway Deployment Guide - iBit Repair

## 📋 ภาพรวม

คู่มือการ Deploy โปรเจค iBit Repair ขึ้น Railway แบบอัตโนมัติ

## 🔗 Links สำคัญ

- **Railway Project**: https://railway.com/project/3b086c2b-00bf-4c87-9dba-810509613cca
- **GitHub Repository**: https://github.com/ton-apicha/ibit-repair

## 🚀 ขั้นตอนการ Deploy อัตโนมัติ

### 1. เชื่อมต่อ Railway กับ GitHub

1. เข้าไปที่: https://railway.com/project/3b086c2b-00bf-4c87-9dba-810509613cca
2. คลิก "Settings" → "Connect GitHub"
3. เลือก repository: `ton-apicha/ibit-repair`
4. Railway จะดึง code จาก GitHub อัตโนมัติ

### 2. สร้าง PostgreSQL Database

1. คลิก "New" → "Database" → "Add PostgreSQL"
2. Railway จะสร้าง PostgreSQL database ให้อัตโนมัติ
3. เก็บ `DATABASE_URL` ไว้สำหรับตั้งค่าตัวแปรสภาพแวดล้อม

### 3. ตั้งค่า Environment Variables

#### Backend Environment Variables

```env
# Database
DATABASE_URL=${{Postgres.DATABASE_URL}}

# Server
PORT=4000
NODE_ENV=production

# JWT
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
JWT_EXPIRES_IN=24h
JWT_REFRESH_SECRET=your-super-secret-refresh-key-change-this-in-production
JWT_REFRESH_EXPIRES_IN=7d

# CORS
CORS_ORIGIN=https://your-frontend-domain.vercel.app
CORS_CREDENTIALS=true

# Logging
LOG_LEVEL=info
LOG_FORMAT=json

# Security
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
MAX_REQUEST_SIZE=10mb
```

#### วิธีตั้งค่าใน Railway Dashboard

1. เข้าไปที่ Service (Backend)
2. คลิก "Variables" tab
3. เพิ่มตัวแปรตามรายการด้านบน
4. คลิก "Save" - Railway จะ Redeploy อัตโนมัติ

### 4. ตั้งค่า Root Directory

1. เข้าไปที่ Service → "Settings"
2. หา "Root Directory"
3. ตั้งค่าเป็น: `backend`
4. คลิก "Save"

### 5. ตั้งค่า Build และ Start Commands

1. เข้าไปที่ Service → "Settings"
2. หา "Build Command"
3. ตั้งค่าเป็น: `npm install && npm run build && npx prisma generate`
4. หา "Start Command"
5. ตั้งค่าเป็น: `npm start`
6. คลิก "Save"

### 6. รอให้ Deployment เสร็จ

1. Railway จะ build และ deploy อัตโนมัติ
2. รอให้ Build เสร็จ (ประมาณ 3-5 นาที)
3. ตรวจสอบ Logs เพื่อดูว่ามี error หรือไม่

### 7. ตั้งค่า Domain (Optional)

1. คลิก "Settings" → "Domains"
2. คลิก "Generate Domain"
3. Railway จะสร้าง Public URL ให้
4. เก็บ URL นี้ไว้สำหรับเข้าถึง Backend

### 8. ทดสอบ Backend

```bash
# Health Check
curl https://your-railway-domain.railway.app/health

# Login Test
curl -X POST https://your-railway-domain.railway.app/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```

## 🔧 Troubleshooting

### Build Failed

**ปัญหา**: Build ล้มเหลว

**แก้ไข**:
1. ตรวจสอบ Logs ใน Railway Dashboard
2. ตรวจสอบว่า Root Directory ถูกต้อง
3. ตรวจสอบ package.json และ dependencies

### Database Connection Error

**ปัญหา**: ไม่สามารถเชื่อมต่อ Database ได้

**แก้ไข**:
1. ตรวจสอบว่า `DATABASE_URL` ถูกต้อง
2. ตรวจสอบว่า PostgreSQL service ทำงานอยู่
3. ตรวจสอบ Network settings

### Port Already in Use

**ปัญหา**: Port ถูกใช้งานแล้ว

**แก้ไข**:
1. Railway จะ set PORT ให้อัตโนมัติ
2. ตรวจสอบว่าใช้ `process.env.PORT` ใน code

### Prisma Generate Failed

**ปัญหา**: Prisma generate ล้มเหลว

**แก้ไข**:
1. ตรวจสอบ Prisma schema
2. ตรวจสอบ Binary Targets
3. ตรวจสอบ DATABASE_URL

## 📊 Monitoring

### 1. ตรวจสอบ Logs

1. เข้าไปที่ Railway Dashboard
2. คลิก "Logs" tab
3. ดู real-time logs

### 2. ตรวจสอบ Metrics

1. เข้าไปที่ Railway Dashboard
2. คลิก "Metrics" tab
3. ดู CPU, Memory, Network usage

### 3. ตรวจสอบ Health Check

```bash
curl https://your-railway-domain.railway.app/health
```

**Expected Response**:
```json
{
  "status": "ok",
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

## 🔄 Auto Deploy

### การทำงานของ Auto Deploy

1. Push code ไป GitHub
2. Railway ตรวจจับการเปลี่ยนแปลง
3. Railway build ใหม่อัตโนมัติ
4. Railway deploy ใหม่
5. Zero downtime deployment

### Disable Auto Deploy

1. เข้าไปที่ Settings
2. หา "Auto Deploy"
3. ปิด Auto Deploy

## 💰 Pricing

### Hobby Plan (Free)

- $5 credit per month
- 512 MB RAM
- 1 GB Storage
- 100 GB Bandwidth

### Pro Plan ($20/month)

- $20 credit per month
- 8 GB RAM
- 100 GB Storage
- 1 TB Bandwidth

## 🆘 Support

### Railway Support

- **Documentation**: https://docs.railway.app
- **Discord**: https://discord.gg/railway
- **Email**: support@railway.app

### Project Support

- **GitHub Issues**: https://github.com/ton-apicha/ibit-repair/issues
- **Email**: [your-email@example.com]

---

**Made with ❤️ for ASIC Miner Repair Shops**

**Last Updated**: 2024-01-01
**Version**: 1.0.0
