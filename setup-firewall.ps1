# Setup Windows Firewall สำหรับ iBit Repair System
# รันด้วย PowerShell (Run as Administrator)

Write-Host "=== ตั้งค่า Windows Firewall ===" -ForegroundColor Green
Write-Host ""

# เปิดพอร์ต 3000 สำหรับ Frontend (Next.js)
Write-Host "1. กำลังเปิดพอร์ต 3000 (Frontend)..." -ForegroundColor Yellow
try {
    New-NetFirewallRule `
        -DisplayName "iBit Repair - Next.js Frontend" `
        -Direction Inbound `
        -LocalPort 3000 `
        -Protocol TCP `
        -Action Allow `
        -Profile Private,Domain `
        -Description "อนุญาตให้เข้าถึง Next.js frontend จากอุปกรณ์อื่นในเครือข่าย" `
        -ErrorAction Stop
    Write-Host "   ✅ เปิดพอร์ต 3000 สำเร็จ" -ForegroundColor Green
} catch {
    Write-Host "   ℹ️ พอร์ต 3000 อาจเปิดอยู่แล้ว" -ForegroundColor Cyan
}

Write-Host ""

# เปิดพอร์ต 4000 สำหรับ Backend (Express API)
Write-Host "2. กำลังเปิดพอร์ต 4000 (Backend API)..." -ForegroundColor Yellow
try {
    New-NetFirewallRule `
        -DisplayName "iBit Repair - Express Backend API" `
        -Direction Inbound `
        -LocalPort 4000 `
        -Protocol TCP `
        -Action Allow `
        -Profile Private,Domain `
        -Description "อนุญาตให้เข้าถึง Express API จากอุปกรณ์อื่นในเครือข่าย" `
        -ErrorAction Stop
    Write-Host "   ✅ เปิดพอร์ต 4000 สำเร็จ" -ForegroundColor Green
} catch {
    Write-Host "   ℹ️ พอร์ต 4000 อาจเปิดอยู่แล้ว" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "=== ตั้งค่าเสร็จสมบูรณ์ ===" -ForegroundColor Green
Write-Host ""
Write-Host "ตอนนี้สามารถเข้าถึงจากมือถือได้แล้ว:" -ForegroundColor Cyan
Write-Host "  Frontend: http://192.169.0.67:3000" -ForegroundColor White
Write-Host "  Backend:  http://192.169.0.67:4000" -ForegroundColor White
Write-Host ""
Write-Host "Login:" -ForegroundColor Cyan
Write-Host "  Admin: admin / admin123" -ForegroundColor White
Write-Host "  Technician: technician1 / tech123" -ForegroundColor White
Write-Host ""

