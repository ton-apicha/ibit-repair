# 🧪 System Testing Guide - iBit Repair

## 📋 ภาพรวมการทดสอบ

คู่มือการทดสอบระบบ iBit Repair ทั้ง Backend และ Frontend

## 🔗 URLs สำหรับทดสอบ

### Backend (Railway)
- **Railway Project**: https://railway.com/project/3b086c2b-00bf-4c87-9dba-810509613cca
- **Backend API**: https://your-backend-domain.railway.app
- **Health Check**: https://your-backend-domain.railway.app/health

### Frontend (Vercel)
- **Frontend URL**: https://your-frontend-domain.vercel.app
- **Vercel Dashboard**: https://vercel.com

## 🔐 ข้อมูล Login สำหรับทดสอบ

### Admin Account
- **Username**: `admin`
- **Password**: `admin123`
- **Role**: Administrator

### Test Accounts
- **Username**: `manager`
- **Password**: `manager123`
- **Role**: Manager

- **Username**: `technician`
- **Password**: `technician123`
- **Role**: Technician

## 🧪 Backend API Testing

### 1. Health Check
```bash
curl https://your-backend-domain.railway.app/health
```
**Expected Response**: `{"status":"ok","timestamp":"..."}`

### 2. Login Test
```bash
curl -X POST https://your-backend-domain.railway.app/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```
**Expected Response**: JWT token

### 3. Protected Route Test
```bash
curl https://your-backend-domain.railway.app/api/users \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```
**Expected Response**: List of users

## 🧪 Frontend Testing

### 1. Page Loading Test
- [ ] หน้าแรกโหลดได้
- [ ] Login page โหลดได้
- [ ] Dashboard โหลดได้
- [ ] Loading time < 3 วินาที

### 2. Authentication Test
- [ ] Login ด้วย admin/admin123
- [ ] Login ด้วย test accounts
- [ ] Logout ทำงานได้
- [ ] Session timeout ทำงานได้

### 3. Navigation Test
- [ ] Sidebar navigation ทำงานได้
- [ ] Breadcrumb ทำงานได้
- [ ] Back button ทำงานได้
- [ ] URL routing ถูกต้อง

### 4. CRUD Operations Test

#### Customer Management
- [ ] เพิ่มลูกค้าใหม่
- [ ] แก้ไขข้อมูลลูกค้า
- [ ] ลบลูกค้า
- [ ] ค้นหาลูกค้า
- [ ] ดูรายละเอียดลูกค้า

#### Job Management
- [ ] สร้างงานซ่อมใหม่
- [ ] แก้ไขข้อมูลงาน
- [ ] อัพเดทสถานะงาน
- [ ] เพิ่มรูปภาพงาน
- [ ] เพิ่มบันทึกการซ่อม

#### Parts Management
- [ ] ดูรายการอะไหล่
- [ ] เพิ่มอะไหล่ใหม่
- [ ] แก้ไขข้อมูลอะไหล่
- [ ] เบิกอะไหล่
- [ ] ตรวจสอบสต๊อก

### 5. Mobile Responsiveness Test
- [ ] ทดสอบบนมือถือ (iOS/Android)
- [ ] ทดสอบบนแท็บเล็ต
- [ ] Touch interactions ทำงานได้
- [ ] Responsive layout ถูกต้อง

## 🔧 Performance Testing

### 1. Page Speed Test
- [ ] หน้าแรก < 3 วินาที
- [ ] Login < 2 วินาที
- [ ] Dashboard < 5 วินาที
- [ ] API responses < 1 วินาที

### 2. Load Testing
- [ ] หลาย users เข้าใช้พร้อมกัน
- [ ] ข้อมูลจำนวนมาก
- [ ] File upload ทำงานได้

## 🔒 Security Testing

### 1. Authentication Security
- [ ] ไม่สามารถเข้าถึงข้อมูลโดยไม่ login
- [ ] Session timeout ทำงานได้
- [ ] JWT token validation ทำงานได้
- [ ] Password hashing ทำงานได้

### 2. Input Validation
- [ ] SQL injection protection
- [ ] XSS protection
- [ ] CSRF protection
- [ ] File upload validation

## 🐛 Bug Reporting

### ข้อมูลที่ต้องระบุ
1. **ประเภทปัญหา**: Bug, UI/UX, Performance, Security
2. **ขั้นตอนการเกิดปัญหา**: อธิบายขั้นตอนที่ทำ
3. **ผลลัพธ์ที่คาดหวัง**: สิ่งที่ควรจะเกิดขึ้น
4. **ผลลัพธ์ที่เกิดขึ้นจริง**: สิ่งที่เกิดขึ้นจริง
5. **Screenshot**: ภาพหน้าจอ
6. **Browser/Device**: ระบุ browser และอุปกรณ์
7. **URL**: หน้าหรือฟีเจอร์ที่มีปัญหา

### ช่องทางรายงานปัญหา
- **Email**: [your-email@example.com]
- **Line**: [your-line-id]
- **Phone**: [your-phone-number]

## 📊 Success Metrics

### เป้าหมายการทดสอบ
- [ ] ระบบทำงานได้ 100% บน Desktop
- [ ] ระบบทำงานได้ 95% บน Mobile
- [ ] Response time < 3 วินาที
- [ ] Error rate < 1%
- [ ] User satisfaction > 4/5

## 🚨 Emergency Contacts

### Technical Issues
- **Primary**: [your-name] - [your-phone] - [your-email]
- **Secondary**: [backup-contact] - [backup-phone] - [backup-email]

### Business Issues
- **Manager**: [manager-name] - [manager-phone] - [manager-email]

---

**Made with ❤️ for ASIC Miner Repair Shops**

**Last Updated**: [Current Date]
**Version**: 1.0.0
