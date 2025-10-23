# 🚀 Railway Deployment Guide

## 📋 ภาพรวม

คู่มือนี้จะช่วยคุณ deploy ระบบ iBit Repair ไปยัง Railway platform

### 🔗 Links ที่เกี่ยวข้อง
- **GitHub Repository**: https://github.com/ton-apicha/ibit-repair
- **Railway Project**: https://railway.com/project/3b086c2b-00bf-4c87-9dba-810509613cca?environmentId=a9727738-82d6-40bc-a7bb-1860d8242429
- **Railway Invite**: https://railway.com/invite/kiACOKAWC66

## 🛠️ ขั้นตอนการ Deploy

### 1. ตั้งค่า Railway Project

#### A. สร้าง PostgreSQL Database
1. เข้า Railway Dashboard
2. คลิก "New" → "Database" → "PostgreSQL"
3. ตั้งชื่อ: `ibit-repair-db`
4. บันทึก `DATABASE_URL` ที่ได้

#### B. สร้าง Backend Service
1. คลิก "New" → "GitHub Repo"
2. เลือก repository: `ton-apicha/ibit-repair`
3. เลือก Root Directory: `backend`
4. ตั้งชื่อ: `ibit-repair-backend`

### 2. ตั้งค่า Environment Variables

#### A. Backend Environment Variables
```env
NODE_ENV=production
DATABASE_URL=<DATABASE_URL_FROM_POSTGRES_SERVICE>
JWT_SECRET=your_super_secure_jwt_secret_key_here_2025
JWT_REFRESH_SECRET=your_super_secure_refresh_secret_key_here_2025
JWT_EXPIRES_IN=86400
JWT_REFRESH_EXPIRES_IN=604800
SESSION_SECRET=your_super_secure_session_secret_key_here_2025
CORS_ORIGINS=https://your-frontend-domain.vercel.app
PORT=4000
```

#### B. Frontend Environment Variables (สำหรับ Vercel)
```env
NEXT_PUBLIC_API_URL=https://your-backend-domain.railway.app
NODE_ENV=production
```

### 3. Deploy Backend

#### A. ตั้งค่า Build Command
- **Build Command**: `npm run railway:deploy`
- **Start Command**: `npm start`
- **Health Check Path**: `/health`

#### B. Deploy
1. คลิก "Deploy" ใน Railway Dashboard
2. รอให้ build เสร็จ
3. ตรวจสอบ logs

### 4. Deploy Frontend (Vercel)

#### A. สร้าง Vercel Project
1. เข้า [Vercel Dashboard](https://vercel.com)
2. Import project จาก GitHub
3. เลือก `frontend` folder
4. ตั้งค่า Environment Variables

#### B. ตั้งค่า Environment Variables
```env
NEXT_PUBLIC_API_URL=https://your-backend-domain.railway.app
```

### 5. ตั้งค่า Database

#### A. รัน Prisma Migrations
```bash
# ใน Railway backend service
npx prisma migrate deploy
npx prisma db seed
```

#### B. ตรวจสอบ Database
```bash
npx prisma studio
```

## 🔧 การแก้ไขปัญหา

### ปัญหา: Build Failed
- ตรวจสอบ logs ใน Railway Dashboard
- ตรวจสอบ `package.json` และ dependencies
- ตรวจสอบ TypeScript errors

### ปัญหา: Database Connection
- ตรวจสอบ `DATABASE_URL` environment variable
- ตรวจสอบ PostgreSQL service status
- ตรวจสอบ network connectivity

### ปัญหา: CORS Error
- ตรวจสอบ `CORS_ORIGINS` environment variable
- ตรวจสอบ frontend domain ใน CORS settings

## 📊 Monitoring และ Logs

### Railway Dashboard
- **Logs**: ดู real-time logs
- **Metrics**: CPU, Memory, Network usage
- **Health Checks**: ตรวจสอบ service health

### Database Monitoring
- **pgAdmin**: สำหรับ database management
- **Railway Database**: ดู database metrics

## 🔐 Security

### Environment Variables
- ใช้ strong passwords สำหรับ JWT secrets
- อย่า expose sensitive data ใน logs
- ใช้ HTTPS สำหรับ production

### Database Security
- ตั้งค่า strong database password
- ใช้ connection pooling
- ตั้งค่า proper access controls

## 🚀 Production Checklist

- [ ] Backend deployed และ running
- [ ] Database connected และ migrated
- [ ] Frontend deployed และ connected to backend
- [ ] Environment variables ตั้งค่าถูกต้อง
- [ ] Health checks ผ่าน
- [ ] SSL certificates ทำงาน
- [ ] Monitoring ตั้งค่าแล้ว
- [ ] Backup strategy วางแผนแล้ว

## 📞 Support

หากมีปัญหา:
1. ตรวจสอบ logs ใน Railway Dashboard
2. ตรวจสอบ GitHub repository
3. ติดต่อทีมพัฒนา

---

**Made with ❤️ for ASIC Miner Repair Shops**
