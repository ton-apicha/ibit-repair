#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Quick Start Script - เริ่มต้นใช้งานระบบแบบครบจบในคำสั่งเดียว

.DESCRIPTION
    Script นี้จะ:
    1. Setup Backend (install, generate, migrate)
    2. Setup Frontend (install)
    3. Seed ข้อมูลจำลอง
    4. Start ทั้ง Backend และ Frontend
    
.EXAMPLE
    .\quick-start.ps1
    
.NOTES
    ใช้สำหรับ Development เท่านั้น!
#>

# Colors
$ColorInfo = "Cyan"
$ColorSuccess = "Green"
$ColorWarning = "Yellow"
$ColorError = "Red"

function Write-Step {
    param([string]$Message)
    Write-Host "`n═══════════════════════════════════════" -ForegroundColor $ColorInfo
    Write-Host "  $Message" -ForegroundColor $ColorInfo
    Write-Host "═══════════════════════════════════════`n" -ForegroundColor $ColorInfo
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
Clear-Host
Write-Host "`n" -NoNewline
Write-Host "╔═══════════════════════════════════════════════╗" -ForegroundColor $ColorInfo
Write-Host "║                                                ║" -ForegroundColor $ColorInfo
Write-Host "║       🚀 iBit Repair System Quick Start       ║" -ForegroundColor $ColorInfo
Write-Host "║                                                ║" -ForegroundColor $ColorInfo
Write-Host "╚═══════════════════════════════════════════════╝" -ForegroundColor $ColorInfo
Write-Host "`n"

# ตรวจสอบ project root
if (-not (Test-Path "backend\package.json") -or -not (Test-Path "frontend\package.json")) {
    Write-Error-Message "กรุณารัน script จาก project root!"
    exit 1
}

# ==========================================
# STEP 1: Backend Setup
# ==========================================
Write-Step "📦 STEP 1: Backend Setup"

Set-Location backend

# Check .env
Write-Host "Checking .env file..." -ForegroundColor $ColorWarning
if (-not (Test-Path ".env")) {
    Write-Error-Message "ไม่พบไฟล์ .env!"
    Write-Host "กรุณา copy จาก .env.example และตั้งค่า DATABASE_URL" -ForegroundColor $ColorWarning
    Set-Location ..
    exit 1
}
Write-Success ".env file found"

# Install dependencies
Write-Host "`nInstalling backend dependencies..." -ForegroundColor $ColorWarning
npm install --silent
if ($LASTEXITCODE -ne 0) {
    Write-Error-Message "npm install failed!"
    Set-Location ..
    exit 1
}
Write-Success "Backend dependencies installed"

# Generate Prisma Client
Write-Host "`nGenerating Prisma Client..." -ForegroundColor $ColorWarning
npm run prisma:generate --silent
if ($LASTEXITCODE -ne 0) {
    Write-Error-Message "Prisma generate failed!"
    Set-Location ..
    exit 1
}
Write-Success "Prisma Client generated"

# Run migrations
Write-Host "`nRunning database migrations..." -ForegroundColor $ColorWarning
npx prisma migrate deploy --silent 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Warning "Migration failed, trying migrate dev..."
    npm run prisma:migrate
}
Write-Success "Database migrations completed"

Set-Location ..

# ==========================================
# STEP 2: Frontend Setup
# ==========================================
Write-Step "📦 STEP 2: Frontend Setup"

Set-Location frontend

Write-Host "Installing frontend dependencies..." -ForegroundColor $ColorWarning
npm install --silent
if ($LASTEXITCODE -ne 0) {
    Write-Error-Message "npm install failed!"
    Set-Location ..
    exit 1
}
Write-Success "Frontend dependencies installed"

Set-Location ..

# ==========================================
# STEP 3: Seed Database (Optional)
# ==========================================
Write-Step "🌱 STEP 3: Seed Sample Data"

$seedConfirm = Read-Host "ต้องการสร้างข้อมูลจำลองสำหรับทดสอบหรือไม่? (Y/n)"
if ($seedConfirm -ne 'n' -and $seedConfirm -ne 'N') {
    Write-Host "`nSeeding database..." -ForegroundColor $ColorWarning
    Set-Location backend
    npm run seed
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Seed failed, but continuing..."
    } else {
        Write-Success "Sample data created successfully"
    }
    Set-Location ..
} else {
    Write-Warning "Skipped seeding (เริ่มต้นด้วยฐานข้อมูลว่าง)"
}

# ==========================================
# STEP 4: Start Services
# ==========================================
Write-Step "🚀 STEP 4: Starting Services"

Write-Host "Starting Backend server..." -ForegroundColor $ColorWarning
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD\backend'; Write-Host '🔧 Backend Server' -ForegroundColor Cyan; npm run dev"
Start-Sleep -Seconds 3
Write-Success "Backend started on http://localhost:4000"

Write-Host "`nStarting Frontend server..." -ForegroundColor $ColorWarning
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD\frontend'; Write-Host '🎨 Frontend Server' -ForegroundColor Cyan; npm run dev"
Start-Sleep -Seconds 5
Write-Success "Frontend started on http://localhost:3000"

# ==========================================
# Summary
# ==========================================
Write-Host "`n`n"
Write-Host "╔═══════════════════════════════════════════════╗" -ForegroundColor $ColorSuccess
Write-Host "║                                                ║" -ForegroundColor $ColorSuccess
Write-Host "║           🎉 Setup Complete! 🎉                ║" -ForegroundColor $ColorSuccess
Write-Host "║                                                ║" -ForegroundColor $ColorSuccess
Write-Host "╚═══════════════════════════════════════════════╝" -ForegroundColor $ColorSuccess

Write-Host "`n📋 System Information:" -ForegroundColor $ColorInfo
Write-Host "   • Backend:  http://localhost:4000" -ForegroundColor White
Write-Host "   • Frontend: http://localhost:3000" -ForegroundColor White
Write-Host "   • Database: PostgreSQL (configured in .env)" -ForegroundColor White

if ($seedConfirm -ne 'n' -and $seedConfirm -ne 'N') {
    Write-Host "`n🔑 Login Credentials (Sample Data):" -ForegroundColor $ColorInfo
    Write-Host "   • Username: admin / manager / tech1 / tech2 / receptionist" -ForegroundColor White
    Write-Host "   • Password: 123456 (all accounts)" -ForegroundColor White
    
    Write-Host "`n📊 Sample Data Created:" -ForegroundColor $ColorInfo
    Write-Host "   • 5 Users" -ForegroundColor White
    Write-Host "   • 3 Brands, 6 Models" -ForegroundColor White
    Write-Host "   • 5 Customers" -ForegroundColor White
    Write-Host "   • 5 Jobs (various statuses)" -ForegroundColor White
    Write-Host "   • 7 Parts (2 with low stock alerts)" -ForegroundColor White
}

Write-Host "`n💡 Next Steps:" -ForegroundColor $ColorInfo
Write-Host "   1. Wait 10-15 seconds for servers to fully start" -ForegroundColor White
Write-Host "   2. Open browser: http://localhost:3000" -ForegroundColor White
if ($seedConfirm -ne 'n' -and $seedConfirm -ne 'N') {
    Write-Host "   3. Login with: admin / 123456" -ForegroundColor White
    Write-Host "   4. Explore Dashboard, Jobs, Parts, Customers" -ForegroundColor White
} else {
    Write-Host "   3. Create your first user in pgAdmin 4" -ForegroundColor White
    Write-Host "   4. Login and start using the system" -ForegroundColor White
}

Write-Host "`n📖 Documentation:" -ForegroundColor $ColorInfo
if ($seedConfirm -ne 'n' -and $seedConfirm -ne 'N') {
    Write-Host "   • SEED-DATA-GUIDE.md - รายละเอียดข้อมูลจำลอง" -ForegroundColor White
}
Write-Host "   • README.md - คู่มือการใช้งาน" -ForegroundColor White
Write-Host "   • DEVELOPMENT-GUIDE.md - คู่มือสำหรับนักพัฒนา" -ForegroundColor White

Write-Host "`n🔧 Stop Servers:" -ForegroundColor $ColorInfo
Write-Host "   • Press Ctrl+C in each terminal window" -ForegroundColor White
Write-Host "   • Or run: Stop-Process -Name node -Force" -ForegroundColor White

Write-Host "`n" -NoNewline

# Auto-open browser after 12 seconds
Write-Host "🌐 Opening browser in 12 seconds..." -ForegroundColor $ColorWarning
Start-Sleep -Seconds 12
Start-Process "http://localhost:3000"

Write-Host "`n✨ Happy coding! ✨`n" -ForegroundColor $ColorSuccess

