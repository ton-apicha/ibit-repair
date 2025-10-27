# 🔧 ระบบซ่อมเครื่องขุดบิทคอยน์ ASIC (ASIC Miner Repair Management System)

[![Next.js](https://img.shields.io/badge/Next.js-14-black)](https://nextjs.org/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.3-blue)](https://www.typescriptlang.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-18-blue)](https://www.postgresql.org/)
[![Prisma](https://img.shields.io/badge/Prisma-5.7-2D3748)](https://www.prisma.io/)
[![Status](https://img.shields.io/badge/Status-Development-green)](https://github.com)

## 📋 ภาพรวมของระบบ

ระบบจัดการซ่อมเครื่องขุดบิทคอยน์ ASIC แบบครบวงจร ครอบคลุมตั้งแต่การรับเครื่องจากลูกค้า การติดตามสถานะการซ่อม การจัดการอะไหล่ ไปจนถึงการปิดงานและส่งคืนลูกค้า พร้อม UI/UX ที่ออกแบบมาเพื่อ Mobile-First

> **📊 สถานะปัจจุบัน**: ระบบ MVP พร้อมใช้งาน ครอบคลุมฟีเจอร์หลักทั้งหมด ✅  
> **🎯 เป้าหมาย**: พัฒนาเพื่อใช้งานจริงในร้านซ่อมเครื่องขุด ASIC ทุกขนาด  
> **📱 Mobile-First**: ออกแบบมาสำหรับใช้งานบนมือถือเป็นหลัก

### ✨ จุดเด่น
- 📱 **Mobile-First Design** - ใช้งานบนมือถือได้คล่องแคล่ว
- 🎯 **ครบวงจร** - ครอบคลุมทุกขั้นตอนการซ่อม
- 📊 **รายงานละเอียด** - ติดตามการใช้อะไหล่และสถิติต่างๆ
- 🔒 **ระบบสิทธิ์** - แยกสิทธิ์ตามบทบาท (Admin, Manager, Technician, Receptionist)
- 💬 **คอมเมนต์ภาษาไทย** - เข้าใจง่าย แก้ไขง่าย สำหรับนักพัฒนาทุกระดับ

---

## 🏗️ สถาปัตยกรรม (Architecture)

```
┌──────────────────────────────────────────────────────────┐
│                     Client (Browser)                     │
│                 Next.js 14 + React + Tailwind            │
│                    http://localhost:3000                 │
└─────────────────────┬────────────────────────────────────┘
                      │ REST API
┌─────────────────────▼────────────────────────────────────┐
│              Backend API Server                          │
│          Express + TypeScript + Prisma                   │
│                http://localhost:4000                     │
└─────────────────────┬────────────────────────────────────┘
                      │ SQL
┌─────────────────────▼────────────────────────────────────┐
│                PostgreSQL 18 Database                    │
│             Native on Windows 11 / Docker                │
│                    localhost:5432                        │
└──────────────────────────────────────────────────────────┘
```

---

## 🛠️ เทคโนโลยีที่ใช้

### Frontend
| เทคโนโลยี | รายละเอียด |
|-----------|-----------|
| **Next.js 14+** | React framework with App Router, Server Components |
| **TypeScript** | Type-safe development |
| **Tailwind CSS** | Utility-first CSS framework |
| **shadcn/ui** | Re-usable components built on Radix UI |
| **React Hook Form + Zod** | Form validation with TypeScript support |
| **Zustand** | Lightweight state management |
| **Axios** | HTTP client for API calls |

### Backend
| เทคโนโลยี | รายละเอียด |
|-----------|-----------|
| **Node.js 20+** | JavaScript runtime |
| **Express** | Fast, minimal web framework |
| **TypeScript** | Type-safe development |
| **Prisma ORM** | Next-generation ORM for database |
| **JWT** | JSON Web Token authentication |
| **bcrypt** | Password hashing |

### Database
| เทคโนโลยี | รายละเอียด |
|-----------|-----------|
| **PostgreSQL 18** | Powerful, open-source relational database |

### Others
| เทคโนโลยี | รายละเอียด |
|-----------|-----------|
| **Puppeteer** | PDF generation และ automated testing |
| **Docker** | Containerization (สำหรับ production) |

---

## 📦 การติดตั้งและรันโปรเจค

### ข้อกำหนดเบื้องต้น (Prerequisites)

สำหรับการพัฒนาบน **Windows 11** ติดตั้งโปรแกรมต่อไปนี้:

1. ✅ **Node.js 20 LTS** - [ดาวน์โหลด](https://nodejs.org/)
2. ✅ **PostgreSQL 18** - [ดาวน์โหลด](https://www.enterprisedb.com/downloads/postgres-postgresql-downloads)
3. ✅ **pgAdmin 4** - [ดาวน์โหลด](https://www.pgadmin.org/download/) **(เครื่องมือหลักสำหรับจัดการ Database)**
4. ✅ **Git** - [ดาวน์โหลด](https://git-scm.com/)
5. 💡 **VS Code** - [ดาวน์โหลด](https://code.visualstudio.com/) (แนะนำ)

> **⚠️ สำคัญ**: ระบบใช้ **PostgreSQL 18 + pgAdmin 4** ทั้ง Development และ Production  
> - ❌ **ไม่ใช้ SQLite**  
> - ❌ **ไม่ใช้ Prisma Studio** (ใช้ pgAdmin 4 แทน)

---

### 🚀 ขั้นตอนการติดตั้ง

#### 1️⃣ Clone โปรเจค

```bash
git clone <repository-url>
cd ibit-repair
```

---

#### 2️⃣ Setup PostgreSQL Database

**A. หลังติดตั้ง PostgreSQL แล้ว ตรวจสอบว่า Service ทำงานอยู่:**

```powershell
# PowerShell
Get-Service | Where-Object { $_.Name -like "*postgres*" }
```

**B. สร้าง Database:**

```powershell
# เชื่อมต่อ PostgreSQL (ใช้ password ที่ตั้งตอนติดตั้ง)
psql -U postgres

# สร้าง database
CREATE DATABASE ibit_repair;

# ออกจาก psql
\q
```

**หรือใช้ pgAdmin 4** (GUI) สร้าง database ชื่อ `ibit_repair`

---

#### 3️⃣ Setup Backend

```powershell
# เข้าไปในโฟลเดอร์ backend
cd backend

# ติดตั้ง dependencies
npm install

# สร้างไฟล์ .env
copy .env.example .env
```

**แก้ไขไฟล์ `backend/.env`:**

```env
# Database Connection (เปลี่ยน password เป็นของคุณ)
DATABASE_URL="postgresql://postgres:admin123@localhost:5432/ibit_repair?schema=public"

# JWT Configuration
JWT_SECRET="ibit-repair-secret-key-2025-change-in-production"
JWT_EXPIRES_IN=86400

# Server Configuration
PORT=4000
NODE_ENV="development"
```

**สร้าง Database Schema และ Seed ข้อมูล:**

```powershell
# Generate Prisma Client
npx prisma generate

# Push schema ไปที่ database
npx prisma db push

# Seed ข้อมูลเริ่มต้น (Users, Brands, Models, Parts, Warranties)
npm run seed

# รัน Development Server
npm run dev
```

✅ **Backend พร้อมใช้งาน:** `http://localhost:4000`

---

#### 4️⃣ Setup Frontend (เปิด Terminal ใหม่)

```powershell
# เข้าไปในโฟลเดอร์ frontend
cd frontend

# ติดตั้ง dependencies
npm install

# สร้างไฟล์ .env.local
copy .env.example .env.local
```

**ตรวจสอบไฟล์ `frontend/.env.local`:**

```env
NEXT_PUBLIC_API_URL=http://localhost:4000
```

**รัน Development Server:**

```powershell
npm run dev
```

✅ **Frontend พร้อมใช้งาน:** `http://localhost:3000`

---

### 🎯 เข้าใช้งานระบบ

1. เปิด Browser ไปที่: **http://localhost:3000**
2. Login ด้วยบัญชีทดสอบ:

| บทบาท | Username | Password | คำอธิบาย |
|--------|----------|----------|----------|
| 👨‍💼 **Admin** | `admin` | `admin123` | เข้าถึงทุกอย่าง |
| 🔧 **Technician** | `technician1` | `tech123` | ช่างซ่อม |

---

## 📁 โครงสร้างโปรเจค

```
ibit-repair/
├── backend/                    # Express API + Prisma
│   ├── prisma/
│   │   ├── schema.prisma      # Database schema
│   │   └── seed.ts            # ข้อมูลเริ่มต้น
│   ├── src/
│   │   ├── controllers/       # Business logic
│   │   ├── routes/            # API routes
│   │   ├── middleware/        # Authentication, etc.
│   │   ├── utils/             # Helper functions
│   │   └── server.ts          # Express server
│   ├── .env                   # Environment variables (สร้างเอง)
│   ├── package.json
│   └── tsconfig.json
│
├── frontend/                   # Next.js Application
│   ├── app/
│   │   ├── (auth)/            # Auth pages (login)
│   │   ├── (dashboard)/       # Dashboard pages
│   │   ├── globals.css        # Global styles
│   │   └── layout.tsx         # Root layout
│   ├── components/            # Reusable components (future)
│   ├── store/                 # Zustand stores
│   ├── lib/                   # Utilities
│   ├── .env.local             # Environment variables (สร้างเอง)
│   ├── package.json
│   └── next.config.js
│
├── docker-compose.yml         # Docker config สำหรับ production
├── README.md                  # เอกสารนี้
└── .gitignore
```

---

## 🎯 ฟีเจอร์หลัก

### ✅ Phase 1: MVP (Core Features) - พัฒนาเสร็จแล้ว

| ฟีเจอร์ | สถานะ | รายละเอียด | API Endpoints |
|---------|-------|-----------|---------------|
| 🔐 **Authentication** | ✅ | Login, JWT, Role-based access control | `/api/auth/*` |
| 👥 **Customer Management** | ✅ | CRUD ข้อมูลลูกค้า, ค้นหา, ประวัติงานซ่อม | `/api/customers/*` |
| ⚙️ **Miner Models Database** | ✅ | จัดการยี่ห้อและรุ่นเครื่องขุด (29 รุ่นในระบบ) | `/api/brands/*`, `/api/models/*` |
| 👨‍🔧 **Technician Management** | ✅ | จัดการช่างและมอบหมายงาน | `/api/users/*` |
| 🔧 **Spare Parts Inventory** | ✅ | จัดการสต๊อกอะไหล่, แจ้งเตือนสต๊อกต่ำ | `/api/parts/*` |
| 🛡️ **Warranty Profiles** | ✅ | โปรไฟล์การรับประกัน (7, 30, 90 วัน) | `/api/warranties/*` |
| 📋 **Job/Ticket System** | ✅ | สร้างงาน, ติดตามสถานะ, Workflow ครบวงจร | `/api/jobs/*` |
| 💰 **Finance & Billing** | ✅ | ใบเสนอราคา, Invoice, ชำระเงิน | `/api/quotations/*`, `/api/transactions/*` |
| 📊 **Reports & Analytics** | ✅ | รายงานการใช้อะไหล่, สถิติงานซ่อม | `/api/reports/*` |
| 📄 **PDF Generation** | ✅ | สร้าง PDF ใบเสนอราคา/ใบเสร็จ | `/api/pdf/*` |

### 🔄 Phase 2: Future Enhancements

- [ ] ระบบแจ้งเตือนอัตโนมัติ (SMS/Email/LINE)
- [ ] QR Code & Barcode สำหรับ tracking
- [ ] Multi-Branch Support (หลายสาขา)
- [ ] Customer Portal (ลูกค้าเช็คสถานะเอง)
- [ ] PWA (Progressive Web App) - ใช้งานแบบ App
- [ ] Knowledge Base - คู่มือซ่อมและ troubleshooting
- [ ] Advanced Analytics & Dashboard

---

## 🔄 Workflow การซ่อม

```mermaid
graph TD
    A[1. รับเครื่อง] --> B[2. ตรวจสอบ/วินิจฉัย]
    B --> C[3. สร้างใบเสนอราคา]
    C --> D{ลูกค้าอนุมัติ?}
    D -->|ใช่| E[4. เบิกอะไหล่และซ่อม]
    D -->|ไม่| F[ยกเลิกงาน]
    E --> G[5. ทดสอบเครื่อง]
    G --> H{ผ่านการทดสอบ?}
    H -->|ใช่| I[6. พร้อมส่งมอบ]
    H -->|ไม่| E
    I --> J[7. แจ้งลูกค้า]
    J --> K[8. รับเงิน + ส่งคืน]
    K --> L[9. ปิดงาน]
```

---

## 🗄️ Database Schema (สรุป)

```
Users (Admin, Manager, Technician, Receptionist)
  ├── Roles & Permissions
  └── JWT Authentication

Customers (ข้อมูลลูกค้า)
  └── Jobs (งานซ่อม)

Brands (ยี่ห้อเครื่องขุด)
  └── MinerModels (รุ่นเครื่อง)
        └── Jobs

Parts (อะไหล่)
  ├── Stock Management
  └── JobParts (อะไหล่ที่ใช้ในงาน)

Jobs (งานซ่อม)
  ├── RepairRecords (บันทึกการซ่อม)
  ├── JobImages (รูปภาพ)
  ├── Quotations (ใบเสนอราคา)
  ├── Transactions (ชำระเงิน)
  └── WarrantyProfile

ActivityLogs (บันทึกการทำงาน)
```

---

## 🛠️ เครื่องมือจัดการ Database

### 🎨 pgAdmin 4 (GUI - เครื่องมือหลัก)

pgAdmin 4 เป็นเครื่องมือ GUI สำหรับจัดการ PostgreSQL ที่เราใช้ทั้ง Development และ Production

#### การเชื่อมต่อ:
1. เปิด pgAdmin 4
2. **Add New Server:**
   - **General Tab:**
     - **Name**: iBit Repair (Development)
   - **Connection Tab:**
     - **Host**: localhost
     - **Port**: 5432
     - **Maintenance Database**: postgres
     - **Username**: postgres
     - **Password**: admin123 (หรือรหัสผ่านที่คุณตั้งไว้)
   - **Advanced Tab:**
     - **DB restriction**: ibit_repair

#### การใช้งาน:
- **ดูข้อมูล**: เลือก Database → Schemas → Tables → คลิกขวาที่ Table → View/Edit Data
- **รัน SQL Query**: Tools → Query Tool หรือกด F5
- **สร้าง Backup**: คลิกขวาที่ Database → Backup
- **Import/Export**: คลิกขวาที่ Table → Import/Export Data

#### ตัวอย่าง SQL Queries:
```sql
-- ดูข้อมูล Users ทั้งหมด
SELECT * FROM "Users";

-- ดูจำนวน Customer
SELECT COUNT(*) FROM "Customers";

-- ดู Parts ที่สต๊อกต่ำ
SELECT * FROM "Parts" WHERE "stockQty" < "minStockQty";

-- ดู Jobs ที่กำลังซ่อม
SELECT * FROM "Jobs" WHERE status = 'IN_REPAIR';
```

---

## 🚀 การ Deploy

### 💻 Development (Local)
```bash
# Backend
cd backend
npm run dev

# Frontend
cd frontend
npm run dev
```

### ☁️ Production (Railway) - Auto Deploy

#### วิธี Deploy อัตโนมัติ

1. **เชื่อมต่อ Railway กับ GitHub**
   - เข้าไปที่: https://railway.com/project/3b086c2b-00bf-4c87-9dba-810509613cca
   - คลิก "Settings" → "Connect GitHub"

2. **ตั้งค่า Environment Variables**
   - Backend Service → "Variables"
   - เพิ่ม: `DATABASE_URL`, `JWT_SECRET`, etc.
   - ดูรายละเอียด: [RAILWAY-DEPLOY-GUIDE.md](./RAILWAY-DEPLOY-GUIDE.md)

3. **ตั้งค่า Root Directory**
   - Backend Service → "Settings" → Root Directory: `backend`

4. **Push to GitHub**
   ```bash
   git push origin master
   ```
   - Railway จะ auto deploy

**Railway Deployment:**
- **Project**: https://railway.com/project/3b086c2b-00bf-4c87-9dba-810509613cca
- **Repository**: https://github.com/ton-apicha/ibit-repair
- **Build Time**: Backend ~3-5 นาที
- **Guide**: [RAILWAY-DEPLOY-GUIDE.md](./RAILWAY-DEPLOY-GUIDE.md)

---

## 📚 คำแนะนำสำหรับผู้พัฒนา

### 📝 การเขียนโค้ด
- ✅ **Comment ภาษาไทย** - เพื่อความเข้าใจง่าย
- ✅ **ตั้งชื่อตัวแปรให้ชัดเจน** - ใช้ชื่อที่บอกจุดประสงค์
- ✅ **แบ่ง Function ย่อยๆ** - แยก logic ให้อ่านง่าย
- ✅ **Error Handling** - แสดงข้อความที่เข้าใจได้

### 🔧 การแก้ไขโค้ด
1. **Backend API** - แก้ไขใน `backend/src/`
2. **Frontend UI** - แก้ไขใน `frontend/app/`
3. **Database Schema** - แก้ไขใน `backend/prisma/schema.prisma` แล้วรัน:
   ```bash
   npx prisma db push
   npx prisma generate
   ```

### 🧪 การทดสอบ

#### ทดสอบด้วย PowerShell Script
```powershell
# รัน Test Suite อัตโนมัติ
.\run-tests.ps1

# หรือทดสอบ API แบบ Manual
curl http://localhost:4000/health

# ทดสอบ Login
curl -X POST http://localhost:4000/api/auth/login ^
  -H "Content-Type: application/json" ^
  -d "{\"username\":\"admin\",\"password\":\"admin123\"}"
```

#### ทดสอบบนมือถือ
1. เชื่อมต่อมือถือกับ WiFi เดียวกันกับคอมพิวเตอร์
2. เปิด Browser ไปที่: `http://192.169.0.67:3000`
3. Login ด้วย admin/admin123
4. ทดสอบฟังก์ชั่นต่างๆ

#### เอกสารการทดสอบ
- 📋 **TEST-SUITE.md** - แผนการทดสอบครบถ้วน
- 🧪 **test-automation.js** - Automated tests with Playwright
- 📱 **MOBILE-TEST.md** - คู่มือทดสอบบนมือถือ
- 🐛 **DEBUG-GUIDE.md** - คู่มือ Debug และแก้ไขปัญหา

---

## ❓ Troubleshooting

### ปัญหา: Backend ไม่ start
```powershell
# ตรวจสอบว่าพอร์ต 4000 ถูกใช้หรือไม่
netstat -ano | findstr :4000

# Stop process ที่ใช้พอร์ต
Stop-Process -Id <PID> -Force
```

### ปัญหา: Database connection error
1. ตรวจสอบ PostgreSQL service ทำงานอยู่หรือไม่
2. ตรวจสอบ `DATABASE_URL` ใน `.env` ว่าถูกต้อง
3. ตรวจสอบ password และ port

### ปัญหา: Frontend ไม่เชื่อมต่อ Backend
- ตรวจสอบ `NEXT_PUBLIC_API_URL` ใน `frontend/.env.local`
- ตรวจสอบว่า Backend รันอยู่ที่ port 4000

---

## 📄 License

MIT License - ดู LICENSE file สำหรับรายละเอียด

---

## 👥 ผู้พัฒนา

ระบบพัฒนาโดย **[ชื่อทีมหรือองค์กร]**

- 📧 Email: [your-email@example.com]
- 🌐 Website: [your-website.com]
- 📞 Tel: [your-phone-number]

---

## 🙏 Acknowledgments

- [Next.js](https://nextjs.org/) - The React Framework
- [Prisma](https://www.prisma.io/) - Next-generation ORM
- [Tailwind CSS](https://tailwindcss.com/) - Utility-first CSS
- [shadcn/ui](https://ui.shadcn.com/) - Beautiful UI Components

---

<div align="center">

**Made with ❤️ for ASIC Miner Repair Shops**

⭐ Star this repo if you find it helpful!

</div>
