#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Seed Database Script - สร้างข้อมูลจำลองสำหรับทดสอบระบบ

.DESCRIPTION
    Script นี้จะ:
    1. ตรวจสอบ PostgreSQL
    2. Generate Prisma Client
    3. รัน Database Migration
    4. Seed ข้อมูลจำลอง
    
    ⚠️ คำเตือน: จะลบข้อมูลเดิมทั้งหมด!

.EXAMPLE
    .\seed-database.ps1
    
.NOTES
    ใช้เฉพาะในโหมด Development เท่านั้น!
#>

# Colors
$ColorInfo = "Cyan"
$ColorSuccess = "Green"
$ColorWarning = "Yellow"
$ColorError = "Red"

# ฟังก์ชั่นแสดงข้อความ
function Write-Step {
    param([string]$Message)
    Write-Host "`n$Message" -ForegroundColor $ColorInfo
}

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor $ColorSuccess
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor $ColorWarning
}

function Write-Error-Message {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor $ColorError
}

# Header
Write-Host "`n═══════════════════════════════════════" -ForegroundColor $ColorInfo
Write-Host "  🌱 DATABASE SEED SCRIPT" -ForegroundColor $ColorInfo
Write-Host "═══════════════════════════════════════`n" -ForegroundColor $ColorInfo

# ตรวจสอบว่าอยู่ใน project root
if (-not (Test-Path "backend\package.json")) {
    Write-Error-Message "กรุณารัน script จาก project root!"
    exit 1
}

# คำเตือน
Write-Warning "คำเตือน: Script นี้จะลบข้อมูลเดิมทั้งหมด!"
Write-Host "ใช้เฉพาะใน Development Environment เท่านั้น`n" -ForegroundColor $ColorWarning

$confirmation = Read-Host "ต้องการดำเนินการต่อหรือไม่? (y/N)"
if ($confirmation -ne 'y' -and $confirmation -ne 'Y') {
    Write-Host "`nยกเลิกการ seed" -ForegroundColor $ColorWarning
    exit 0
}

# เปลี่ยน directory
Set-Location backend

# 1. ตรวจสอบ .env
Write-Step "1️⃣  ตรวจสอบ .env file..."
if (-not (Test-Path ".env")) {
    Write-Error-Message "ไม่พบไฟล์ .env!"
    Write-Host "กรุณา copy จาก .env.example และตั้งค่า DATABASE_URL"
    Set-Location ..
    exit 1
}
Write-Success "พบไฟล์ .env"

# 2. ตรวจสอบ node_modules
Write-Step "2️⃣  ตรวจสอบ dependencies..."
if (-not (Test-Path "node_modules")) {
    Write-Warning "ไม่พบ node_modules, กำลัง install..."
    npm install
    if ($LASTEXITCODE -ne 0) {
        Write-Error-Message "npm install ล้มเหลว!"
        Set-Location ..
        exit 1
    }
}
Write-Success "Dependencies พร้อม"

# 3. Generate Prisma Client
Write-Step "3️⃣  Generate Prisma Client..."
npm run prisma:generate
if ($LASTEXITCODE -ne 0) {
    Write-Error-Message "Prisma generate ล้มเหลว!"
    Set-Location ..
    exit 1
}
Write-Success "Prisma Client สร้างเรียบร้อย"

# 4. Run Migrations
Write-Step "4️⃣  Run Database Migrations..."
Write-Warning "กำลังตรวจสอบ schema..."
npx prisma migrate deploy
if ($LASTEXITCODE -ne 0) {
    Write-Warning "Migration ล้มเหลว, ลอง migrate dev..."
    npm run prisma:migrate
}
Write-Success "Migrations เสร็จสิ้น"

# 5. Seed Database
Write-Step "5️⃣  Seed Database..."
Write-Host "กำลังสร้างข้อมูลจำลอง...`n" -ForegroundColor $ColorWarning

npm run seed

if ($LASTEXITCODE -ne 0) {
    Write-Error-Message "Seed ล้มเหลว!"
    Set-Location ..
    exit 1
}

# กลับไป root
Set-Location ..

# สรุป
Write-Host "`n═══════════════════════════════════════" -ForegroundColor $ColorSuccess
Write-Host "  🎉 SEED เสร็จสมบูรณ์!" -ForegroundColor $ColorSuccess
Write-Host "═══════════════════════════════════════`n" -ForegroundColor $ColorSuccess

Write-Host "📊 ข้อมูลที่สร้าง:" -ForegroundColor $ColorInfo
Write-Host "   • Users: 5 คน (admin, manager, 2 techs, receptionist)"
Write-Host "   • Brands: 3 แบรนด์ (Bitmain, MicroBT, Canaan)"
Write-Host "   • Models: 6 รุ่น"
Write-Host "   • Warranties: 3 แบบ (30, 90, 180 วัน)"
Write-Host "   • Parts: 7 รายการ (มี 2 รายการสต็อกต่ำ)"
Write-Host "   • Customers: 5 ราย"
Write-Host "   • Jobs: 5 งาน (สถานะต่างๆ)"
Write-Host "   • Repair Records: 5 รายการ"
Write-Host "   • Job Parts: 4 รายการ"
Write-Host "   • Activity Logs: 7 รายการ"

Write-Host "`n🔑 ข้อมูล Login:" -ForegroundColor $ColorInfo
Write-Host "   Username: admin / manager / tech1 / tech2 / receptionist"
Write-Host "   Password: 123456 (ทุก account)"

Write-Host "`n💡 Next Steps:" -ForegroundColor $ColorInfo
Write-Host "   1. เปิด http://localhost:3000"
Write-Host "   2. Login ด้วย username: admin, password: 123456"
Write-Host "   3. ดู Dashboard → มีข้อมูลสถิติ"
Write-Host "   4. ดู Jobs → มี 5 งานสถานะต่างๆ"
Write-Host "   5. ดู Parts → มี 2 รายการแจ้งเตือนสต็อกต่ำ"

Write-Host "`n📖 เอกสารเพิ่มเติม:" -ForegroundColor $ColorInfo
Write-Host "   อ่าน SEED-DATA-GUIDE.md สำหรับรายละเอียดเพิ่มเติม"

Write-Host "`n" -NoNewline

