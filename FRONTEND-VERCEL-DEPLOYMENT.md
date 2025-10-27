# 🚀 Frontend Deployment to Vercel Guide

## 📋 ขั้นตอนการ Deploy Frontend ไป Vercel

### 1. เข้า Vercel Dashboard
1. เข้าไปที่: https://vercel.com
2. Login ด้วย GitHub account
3. คลิก "New Project"

### 2. Import Project
1. เลือก "Import Git Repository"
2. เลือก repository: `ton-apicha/ibit-repair`
3. คลิก "Import"

### 3. ตั้งค่า Project
1. **Project Name**: `ibit-repair-frontend`
2. **Framework Preset**: Next.js
3. **Root Directory**: `frontend`
4. **Build Command**: `npm run build`
5. **Output Directory**: `.next`

### 4. ตั้งค่า Environment Variables
```env
NEXT_PUBLIC_API_URL=https://your-backend-domain.railway.app
NODE_ENV=production
```

### 5. Deploy
1. คลิก "Deploy"
2. รอให้ build เสร็จ (ประมาณ 2-3 นาที)
3. ได้ URL สำหรับเข้าถึง frontend

## 🔗 Links สำคัญ

- **Vercel Dashboard**: https://vercel.com
- **GitHub Repository**: https://github.com/ton-apicha/ibit-repair
- **Railway Backend**: https://railway.com/project/3b086c2b-00bf-4c87-9dba-810509613cca

## 📊 Expected Build Time

- **Vercel Build**: 2-3 นาที
- **Total Deployment**: 3-5 นาที

## 🧪 การทดสอบ Frontend

### หลัง Deploy เสร็จ
1. เปิด browser ไปที่ Vercel URL
2. ทดสอบ login
3. ทดสอบฟีเจอร์ต่างๆ
4. ทดสอบบนมือถือ

### Checklist การทดสอบ
- [ ] หน้าแรกโหลดได้
- [ ] Login ทำงานได้
- [ ] Navigation ทำงานได้
- [ ] CRUD operations ทำงานได้
- [ ] Mobile responsive ทำงานได้

---

**Made with ❤️ for ASIC Miner Repair Shops**
