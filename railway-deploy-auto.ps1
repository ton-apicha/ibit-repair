# Railway Automated Deployment Script for iBit Repair
# สคริปต์สำหรับ deploy ระบบ iBit Repair ไปยัง Railway โดยอัตโนมัติ

Write-Host "🚀 Railway Automated Deployment Script for iBit Repair" -ForegroundColor Green
Write-Host "=============================================================" -ForegroundColor Green

# ฟังก์ชันสำหรับแสดงข้อความ
function Write-Step {
    param([string]$Message)
    Write-Host "`n📋 $Message" -ForegroundColor Yellow
}

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Error {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

# ตรวจสอบ Railway CLI
Write-Step "ตรวจสอบ Railway CLI installation..."
try {
    $railwayVersion = railway --version
    Write-Success "Railway CLI installed: $railwayVersion"
} catch {
    Write-Error "Railway CLI not found. Please install from: https://docs.railway.app/develop/cli"
    Write-Host "Or run: npm install -g @railway/cli" -ForegroundColor Yellow
    exit 1
}

# ตรวจสอบ Git status
Write-Step "ตรวจสอบ Git status..."
$gitStatus = git status --porcelain
if ($gitStatus) {
    Write-Host "⚠️  มีการเปลี่ยนแปลงที่ยังไม่ได้ commit:" -ForegroundColor Yellow
    Write-Host $gitStatus -ForegroundColor Gray
    $commit = Read-Host "ต้องการ commit และ push การเปลี่ยนแปลงหรือไม่? (y/n)"
    if ($commit -eq "y" -or $commit -eq "Y") {
        git add .
        git commit -m "🚀 Prepare for Railway deployment - Clean up and optimize"
        git push origin master
        Write-Success "การเปลี่ยนแปลงถูก commit และ push แล้ว"
    }
} else {
    Write-Success "ไม่มีไฟล์ที่เปลี่ยนแปลง"
}

# เชื่อมต่อกับ Railway Project
Write-Step "เชื่อมต่อกับ Railway Project..."
try {
    railway link
    Write-Success "เชื่อมต่อกับ Railway Project สำเร็จ"
} catch {
    Write-Error "ไม่สามารถเชื่อมต่อกับ Railway Project ได้"
    exit 1
}

# ตรวจสอบ Services ที่มีอยู่
Write-Step "ตรวจสอบ Services ที่มีอยู่..."
$services = railway status
Write-Host $services -ForegroundColor Gray

# สร้าง Backend Service (ถ้ายังไม่มี)
Write-Step "สร้าง Backend Service..."
try {
    # ลองสร้าง Backend Service
    railway add --service backend --repo ton-apicha/ibit-repair
    Write-Success "Backend Service ถูกสร้างแล้ว"
} catch {
    Write-Host "⚠️  Backend Service อาจมีอยู่แล้ว หรือมีปัญหาในการสร้าง" -ForegroundColor Yellow
}

# ตั้งค่า Environment Variables สำหรับ Backend
Write-Step "ตั้งค่า Environment Variables สำหรับ Backend..."
railway variables set NODE_ENV=production
railway variables set JWT_SECRET=ibit_repair_jwt_secret_2025_secure_key_apicha_ton
railway variables set JWT_REFRESH_SECRET=ibit_repair_refresh_secret_2025_secure_key_apicha_ton
railway variables set JWT_EXPIRES_IN=86400
railway variables set JWT_REFRESH_EXPIRES_IN=604800
railway variables set SESSION_SECRET=ibit_repair_session_secret_2025_secure_key_apicha_ton
railway variables set CORS_ORIGINS=https://ibit-repair-frontend.railway.app
railway variables set PORT=4000

# Deploy Backend
Write-Step "Deploy Backend Service..."
try {
    cd backend
    railway up
    Write-Success "Backend Service ถูก deploy แล้ว"
    cd ..
} catch {
    Write-Error "ไม่สามารถ deploy Backend Service ได้"
    exit 1
}

# แสดง deployment status
Write-Step "ตรวจสอบ deployment status..."
railway status

# แสดง URLs ที่สำคัญ
Write-Host "`n🔗 Links ที่สำคัญ:" -ForegroundColor Green
Write-Host "- Railway Project: https://railway.com/project/3b086c2b-00bf-4c87-9dba-810509613cca" -ForegroundColor Cyan
Write-Host "- GitHub Repository: https://github.com/ton-apicha/ibit-repair" -ForegroundColor Cyan
Write-Host "- Railway Documentation: https://docs.railway.app/" -ForegroundColor Cyan

Write-Host "`n🎯 ขั้นตอนถัดไป:" -ForegroundColor Green
Write-Host "1. ตรวจสอบ deployment logs ใน Railway Dashboard" -ForegroundColor White
Write-Host "2. ตั้งค่า PostgreSQL database" -ForegroundColor White
Write-Host "3. รัน database migrations" -ForegroundColor White
Write-Host "4. ทดสอบ API endpoints" -ForegroundColor White
Write-Host "5. Deploy Frontend service (ถ้าต้องการ)" -ForegroundColor White

Write-Host "`n🚀 Railway deployment script เสร็จสิ้น!" -ForegroundColor Green
Write-Host "ตรวจสอบ Railway Dashboard สำหรับ deployment status" -ForegroundColor Cyan
