# 🚀 Quick Start Guide

เริ่มต้นใช้งานระบบภายใน 5 นาที!

---

## 📋 ความต้องการ

- ✅ Node.js 18+ และ npm
- ✅ PostgreSQL 18
- ✅ Git
- ✅ Windows PowerShell (สำหรับ Windows)

---

## ⚡ เริ่มต้นแบบรวดเร็ว (1 คำสั่ง)

### Windows:

```powershell
.\quick-start.ps1
```

### หรือใช้ Manual:

```bash
# 1. Clone project
git clone [repository-url]
cd ibit-repair

# 2. Setup Backend
cd backend
npm install
npm run prisma:generate
npm run prisma:migrate
npm run seed              # สร้างข้อมูลจำลอง (optional)
npm run dev              # Start backend

# 3. Setup Frontend (terminal ใหม่)
cd frontend
npm install
npm run dev              # Start frontend

# 4. เปิด browser
# http://localhost:3000
```

---

## 🎯 หลังรัน Quick Start

### 1. รอ Servers เริ่มต้น (~15 วินาที)

คุณจะเห็นหน้าต่าง PowerShell 2 หน้าต่าง:
- **Backend**: Port 4000
- **Frontend**: Port 3000

### 2. เปิด Browser

Browser จะเปิดอัตโนมัติที่: **http://localhost:3000**

หรือเปิดเอง:
```
http://localhost:3000
```

### 3. Login (ถ้าเลือก Seed ข้อมูล)

| Username | Password | Role |
|----------|----------|------|
| admin | 123456 | ผู้ดูแลระบบ |
| manager | 123456 | ผู้จัดการ |
| tech1 | 123456 | ช่าง |
| tech2 | 123456 | ช่าง |
| receptionist | 123456 | พนักงานต้อนรับ |

---

## 📊 ข้อมูลจำลอง (ถ้าเลือก Seed)

ระบบจะมีข้อมูลต่อไปนี้:

### 👥 Users (5 คน)
- Admin, Manager, 2 Technicians, Receptionist
- รหัสผ่านทั้งหมด: `123456`

### 📋 Jobs (5 งาน)
- **RJ2025-0001**: COMPLETED (เสร็จแล้ว)
- **RJ2025-0002**: IN_REPAIR (กำลังซ่อม - ด่วน)
- **RJ2025-0003**: WAITING_APPROVAL (รออนุมัติ)
- **RJ2025-0004**: RECEIVED (เพิ่งรับมา - ด่วนมาก)
- **RJ2025-0005**: READY_FOR_PICKUP (พร้อมส่งมอบ)

### 👤 Customers (5 ราย)
- ลูกค้าบุคคลธรรมดา 4 ราย
- ลูกค้าองค์กร 1 ราย

### 🔧 Parts (7 รายการ)
- Hash Board, Control Board, PSU, Fans, ฯลฯ
- **2 รายการมีสต๊อกต่ำ** (เพื่อทดสอบ Alert)

### 🏷️ Master Data
- 3 Brands (Bitmain, MicroBT, Canaan)
- 6 Models (S19 Pro, M30S++, ฯลฯ)
- 3 Warranty Profiles (30, 90, 180 วัน)

---

## 🧪 ทดสอบระบบ

### 1. Dashboard
- ดูสถิติงานซ่อม
- ดูงานล่าสุด
- ดูแจ้งเตือนสต๊อกต่ำ

### 2. Jobs
- ดูรายการงาน 5 งาน
- กรองตามสถานะ
- คลิกดูรายละเอียดงาน
- ทดสอบเปลี่ยนสถานะ
- ทดสอบมอบหมายช่าง
- ทดสอบเพิ่มบันทึกการซ่อม
- ทดสอบเบิกอะไหล่

### 3. Parts
- ดูรายการอะไหล่
- เห็นแจ้งเตือน 2 รายการสต๊อกต่ำ

### 4. Customers
- ดูรายการลูกค้า 5 ราย
- ทดสอบสร้างลูกค้าใหม่
- ทดสอบแก้ไขข้อมูล

---

## 🛑 หยุด Servers

### วิธีที่ 1: ใน Terminal
กด `Ctrl+C` ในแต่ละหน้าต่าง PowerShell

### วิธีที่ 2: ใช้ PowerShell Command
```powershell
Stop-Process -Name node -Force
```

---

## 🔄 รีเซ็ตข้อมูล

ต้องการเริ่มใหม่ทั้งหมด:

```powershell
cd backend
npm run seed
```

หรือใช้ script:

```powershell
.\seed-database.ps1
```

---

## ❓ Troubleshooting

### ปัญหา: Backend ไม่ start

**แก้**: ตรวจสอบ PostgreSQL running และ `.env` ถูกต้อง

```powershell
# ตรวจสอบ PostgreSQL
Get-Service -Name postgresql*

# ตรวจสอบ .env
cat backend\.env
```

### ปัญหา: Frontend ไม่ start

**แก้**: ลบ node_modules แล้ว install ใหม่

```bash
cd frontend
rm -rf node_modules
rm package-lock.json
npm install
```

### ปัญหา: Port ถูกใช้งาน

**แก้**: หยุด process ที่ใช้ port นั้น

```powershell
# หา process ที่ใช้ port 3000 หรือ 4000
netstat -ano | findstr :3000
netstat -ano | findstr :4000

# Kill process
Stop-Process -Id <PID> -Force
```

### ปัญหา: Seed ล้มเหลว

**แก้**: ตรวจสอบ database connection และ migrate

```bash
cd backend
npm run prisma:migrate
npm run seed
```

---

## 📖 เอกสารเพิ่มเติม

| เอกสาร | คำอธิบาย |
|--------|----------|
| [README.md](./README.md) | คู่มือใช้งานหลัก |
| [SEED-DATA-GUIDE.md](./SEED-DATA-GUIDE.md) | รายละเอียดข้อมูลจำลอง |
| [DEVELOPMENT-GUIDE.md](./DEVELOPMENT-GUIDE.md) | คู่มือสำหรับนักพัฒนา |
| [DATABASE-SETUP-SUMMARY.md](./DATABASE-SETUP-SUMMARY.md) | Setup database |
| [PGADMIN-GUIDE.md](./PGADMIN-GUIDE.md) | ใช้งาน pgAdmin 4 |

---

## 🎯 ขั้นตอนถัดไป

1. ✅ ทดสอบระบบตาม Use Cases ใน [SEED-DATA-GUIDE.md](./SEED-DATA-GUIDE.md)
2. ✅ อ่านเอกสาร API ใน [API-DOCUMENTATION.md](./API-DOCUMENTATION.md)
3. ✅ ศึกษา Database Schema ใน [DATABASE-SCHEMA.md](./DATABASE-SCHEMA.md)
4. ✅ ดู Progress ใน [PROGRESS.md](./PROGRESS.md)

---

**สนุกกับการทดสอบ! 🎉**

