# 🚀 Deployment Guide - iBit Repair System

## 📋 ภาพรวม

คู่มือการ deploy ระบบ iBit Repair ทั้งใน Local Development และ Production (Railway)

## 💻 Local Development

### Prerequisites
- Node.js 20+
- PostgreSQL 18
- Git

### ขั้นตอนการ Setup

1. **Clone Repository**
```bash
git clone https://github.com/ton-apicha/ibit-repair.git
cd ibit-repair
```

2. **Setup Backend**
```bash
cd backend
npm install
cp .env.example .env
# แก้ไข .env file ตามต้องการ
npm run dev
```

3. **Setup Frontend**
```bash
cd frontend
npm install
cp .env.example .env.local
# แก้ไข .env.local file ตามต้องการ
npm run dev
```

4. **Setup Database**
```bash
cd backend
npx prisma migrate dev
npx prisma db seed
```

## ☁️ Railway Production Deployment

### Automated Deployment

ใช้ automated deployment script:

```bash
.\railway-deploy-auto.ps1
```

### Manual Deployment

#### 1. เข้า Railway Dashboard
- **Project**: https://railway.com/project/3b086c2b-00bf-4c87-9dba-810509613cca
- **Repository**: https://github.com/ton-apicha/ibit-repair

#### 2. สร้าง PostgreSQL Database
1. คลิก "New" → "Database" → "PostgreSQL"
2. ตั้งชื่อ: `ibit-repair-db`
3. บันทึก `DATABASE_URL`

#### 3. สร้าง Backend Service
1. คลิก "New" → "GitHub Repo"
2. เลือก repository: `ton-apicha/ibit-repair`
3. เลือก Root Directory: `backend`
4. ตั้งชื่อ service: `ibit-repair-backend`

#### 4. ตั้งค่า Backend Environment Variables
```env
NODE_ENV=production
DATABASE_URL=${{Postgres.DATABASE_URL}}
JWT_SECRET=ibit_repair_jwt_secret_2025_secure_key_apicha_ton
JWT_REFRESH_SECRET=ibit_repair_refresh_secret_2025_secure_key_apicha_ton
JWT_EXPIRES_IN=86400
JWT_REFRESH_EXPIRES_IN=604800
SESSION_SECRET=ibit_repair_session_secret_2025_secure_key_apicha_ton
CORS_ORIGINS=https://ibit-repair-frontend.railway.app
PORT=4000
```

#### 5. สร้าง Frontend Service (ถ้าต้องการ)
1. คลิก "New" → "GitHub Repo"
2. เลือก repository: `ton-apicha/ibit-repair`
3. เลือก Root Directory: `frontend`
4. ตั้งชื่อ service: `ibit-repair-frontend`

#### 6. ตั้งค่า Frontend Environment Variables
```env
NEXT_PUBLIC_API_URL=https://ibit-repair-backend.railway.app
NODE_ENV=production
```

## 📊 Build/Deploy Time Estimates

### Backend
- **npm install**: ~1-2 นาที
- **Prisma generate**: ~30 วินาที
- **TypeScript compile**: ~30 วินาที
- **Total**: ~3-5 นาที

### Frontend
- **npm install**: ~1-2 นาที
- **Next.js build**: ~2-4 นาที
- **Total**: ~4-7 นาที

### Overall
- **Total Deployment**: ~7-12 นาที
- **Database Migration**: ~1-2 นาที

## 🔧 Troubleshooting

### Build Failed
1. ตรวจสอบ logs ใน Railway Dashboard
2. ตรวจสอบ `package.json` และ dependencies
3. ตรวจสอบ TypeScript errors

### Database Connection Error
1. ตรวจสอบ `DATABASE_URL` environment variable
2. ตรวจสอบ PostgreSQL service status
3. ตรวจสอบ network connectivity

### CORS Error
1. ตรวจสอบ `CORS_ORIGINS` environment variable
2. ตรวจสอบ frontend domain ใน CORS settings

## 📈 Monitoring

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

## 🔗 Important Links

- **Railway Project**: https://railway.com/project/3b086c2b-00bf-4c87-9dba-810509613cca
- **GitHub Repository**: https://github.com/ton-apicha/ibit-repair
- **Railway Documentation**: https://docs.railway.app/

---

**Made with ❤️ for ASIC Miner Repair Shops**
