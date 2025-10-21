# ระบบซ่อมเครื่องขุดบิทคอยน์ ASIC (ASIC Miner Repair Management System)

## ภาพรวมของระบบ

ระบบจัดการซ่อมเครื่องขุดบิทคอยน์ ASIC แบบครบวงจร ครอบคลุมตั้งแต่การรับเครื่องจากลูกค้า การติดตามสถานะการซ่อม การจัดการอะไหล่ ไปจนถึงการปิดงานและส่งคืนลูกค้า

## เทคโนโลยีที่ใช้

### Frontend
- **Next.js 14+** - React framework with App Router
- **Tailwind CSS + shadcn/ui** - UI styling and components
- **React Hook Form + Zod** - Form validation
- **Zustand** - State management

### Backend
- **Node.js + Express** - REST API server
- **TypeScript** - Type-safe development
- **Prisma** - Database ORM
- **JWT** - Authentication

### Database
- **PostgreSQL 16** - Primary database

### Others
- **Puppeteer** - PDF generation
- **Docker** - Containerization

## การติดตั้งและรันโปรเจค

### ข้อกำหนดเบื้องต้น (Prerequisites)

ติดตั้งโปรแกรมต่อไปนี้บนเครื่อง Windows 11:

1. **Node.js 20 LTS** - [ดาวน์โหลด](https://nodejs.org/)
2. **Docker Desktop** - [ดาวน์โหลด](https://www.docker.com/products/docker-desktop/)
3. **Git** - [ดาวน์โหลด](https://git-scm.com/)
4. **VS Code** - [ดาวน์โหลด](https://code.visualstudio.com/) (แนะนำ)

### ขั้นตอนการติดตั้ง

#### 1. Clone โปรเจค

```bash
git clone <repository-url>
cd ibit-repair
```

#### 2. รัน PostgreSQL ด้วย Docker

```bash
# เปิด PostgreSQL container
docker-compose -f docker-compose.dev.yml up -d

# ตรวจสอบว่า container รันอยู่
docker ps
```

#### 3. Setup Backend

```bash
cd backend
npm install
cp .env.example .env

# แก้ไขไฟล์ .env ตามต้องการ
# DATABASE_URL="postgresql://ibit_user:password123@localhost:5432/ibit_repair"
# JWT_SECRET="your-secret-key-here"

# สร้าง database schema และ migrate
npx prisma migrate dev --name init

# Seed ข้อมูลเริ่มต้น (ยี่ห้อและรุ่นเครื่องขุด)
npx prisma db seed

# รัน development server
npm run dev
```

Backend จะรันที่: `http://localhost:4000`

#### 4. Setup Frontend (เปิด terminal ใหม่)

```bash
cd frontend
npm install
cp .env.example .env.local

# แก้ไขไฟล์ .env.local
# NEXT_PUBLIC_API_URL=http://localhost:4000

# รัน development server
npm run dev
```

Frontend จะรันที่: `http://localhost:3000`

## โครงสร้างโปรเจค

```
ibit-repair/
├── backend/              # Express API + Prisma
├── frontend/             # Next.js Application
├── docker-compose.dev.yml   # Docker สำหรับ PostgreSQL (development)
├── docker-compose.yml       # Docker สำหรับ production
└── README.md
```

## ฟีเจอร์หลัก

### Phase 1: MVP (Core Features)
- ✅ ระบบ Login และจัดการสิทธิ์ (Admin, Manager, Technician, Receptionist)
- ✅ จัดการข้อมูลลูกค้า
- ✅ จัดการรุ่นเครื่องขุด (Brands & Models)
- ✅ จัดการอะไหล่ (Stock Management)
- ✅ ระบบงานซ่อม (Job/Ticket) แบบครบวงจร
- ✅ โปรไฟล์การรับประกัน
- ✅ ระบบการเงิน (Quotation, Invoice, Payment)
- ✅ รายงานและสถิติ
- ✅ สร้าง PDF เอกสาร

### Phase 2: Future Enhancements
- 🔄 ระบบแจ้งเตือนอัตโนมัติ (SMS/Email/LINE)
- 🔄 QR Code & Barcode
- 🔄 Multi-Branch Support
- 🔄 Customer Portal
- 🔄 PWA (Progressive Web App)
- 🔄 Knowledge Base

## Workflow การซ่อม

1. **รับเครื่อง** - บันทึกข้อมูลลูกค้า, เครื่อง, อาการ → สร้าง Job
2. **ตรวจสอบ** - ช่างตรวจสอบและประเมินราคา → สร้างใบเสนอราคา
3. **ซ่อม** - เมื่อลูกค้าอนุมัติ → เบิกอะไหล่และดำเนินการซ่อม
4. **ทดสอบ** - ทดสอบหลังซ่อม
5. **พร้อมส่งมอบ** - สร้าง Invoice และแจ้งลูกค้า
6. **ส่งคืน** - รับเงินและปิดงาน

## การ Deploy

### Development (Windows 11)
- รัน Backend และ Frontend แบบ native บน Windows
- รัน PostgreSQL บน Docker Desktop

### Production (NAS Synology)
- Deploy ทั้งระบบด้วย Docker Compose
- ดูรายละเอียดใน `docker-compose.yml`

## คำแนะนำสำหรับผู้พัฒนา

- 📝 **Code มี comment ภาษาไทย** - เพื่อความเข้าใจง่าย
- 🎯 **ตั้งชื่อตัวแปรให้ชัดเจน** - ใช้ชื่อที่บอกจุดประสงค์
- 🧩 **แบ่ง function ย่อยๆ** - แยก logic ให้อ่านง่าย
- ⚠️ **Error handling** - แสดงข้อความที่เข้าใจได้

## License

MIT License

## ผู้พัฒนา

ระบบพัฒนาโดย [ชื่อทีมหรือองค์กร]

