# 🚀 Railway Setup Instructions

## 📋 ขั้นตอนการตั้งค่า Railway

### 1. เข้า Railway Dashboard
- **Project URL**: https://railway.com/project/3b086c2b-00bf-4c87-9dba-810509613cca?environmentId=a9727738-82d6-40bc-a7bb-1860d8242429
- **Railway Invite**: https://railway.com/invite/kiACOKAWC66

### 2. สร้าง PostgreSQL Database
1. คลิก "New" → "Database" → "PostgreSQL"
2. ตั้งชื่อ: `ibit-repair-db`
3. บันทึก `DATABASE_URL` ที่ได้

### 3. สร้าง Backend Service
1. คลิก "New" → "GitHub Repo"
2. เลือก repository: `ton-apicha/ibit-repair`
3. เลือก Root Directory: `backend`
4. ตั้งชื่อ: `ibit-repair-backend`

### 4. ตั้งค่า Environment Variables

#### Backend Environment Variables:
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

### 5. Deploy Backend
1. คลิก "Deploy" ใน Railway Dashboard
2. รอให้ build เสร็จ
3. ตรวจสอบ logs

### 6. ตั้งค่า Database
1. เข้า Railway backend service
2. เปิด Terminal
3. รันคำสั่ง:
```bash
npx prisma migrate deploy
npx prisma db seed
```

### 7. Deploy Frontend (Vercel)
1. เข้า [Vercel Dashboard](https://vercel.com)
2. Import project จาก GitHub
3. เลือก `frontend` folder
4. ตั้งค่า Environment Variables:
```env
NEXT_PUBLIC_API_URL=https://your-backend-domain.railway.app
```

## 🔧 การแก้ไขปัญหา

### Build Failed
- ตรวจสอบ logs ใน Railway Dashboard
- ตรวจสอบ `package.json` และ dependencies
- ตรวจสอบ TypeScript errors

### Database Connection
- ตรวจสอบ `DATABASE_URL` environment variable
- ตรวจสอบ PostgreSQL service status

### CORS Error
- ตรวจสอบ `CORS_ORIGINS` environment variable
- ตรวจสอบ frontend domain ใน CORS settings

## 📊 Monitoring

### Railway Dashboard
- **Logs**: ดู real-time logs
- **Metrics**: CPU, Memory, Network usage
- **Health Checks**: ตรวจสอบ service health

## 🔐 Security

### Environment Variables
- ใช้ strong passwords สำหรับ JWT secrets
- อย่า expose sensitive data ใน logs
- ใช้ HTTPS สำหรับ production

## 🚀 Production Checklist

- [ ] Backend deployed และ running
- [ ] Database connected และ migrated
- [ ] Frontend deployed และ connected to backend
- [ ] Environment variables ตั้งค่าถูกต้อง
- [ ] Health checks ผ่าน
- [ ] SSL certificates ทำงาน
- [ ] Monitoring ตั้งค่าแล้ว
- [ ] Backup strategy วางแผนแล้ว

---

**Made with ❤️ for ASIC Miner Repair Shops**
