# Railway Deployment Script
Write-Host "Railway Deployment Script for iBit Repair" -ForegroundColor Green

# ตรวจสอบ Railway CLI
Write-Host "Checking Railway CLI..." -ForegroundColor Yellow
railway --version

# เชื่อมต่อกับ Railway Project
Write-Host "Connecting to Railway Project..." -ForegroundColor Yellow
railway link

# ตรวจสอบ Services
Write-Host "Checking Services..." -ForegroundColor Yellow
railway status

# ตั้งค่า Environment Variables
Write-Host "Setting Environment Variables..." -ForegroundColor Yellow
railway variables set NODE_ENV=production
railway variables set JWT_SECRET=ibit_repair_jwt_secret_2025_secure_key_apicha_ton
railway variables set JWT_REFRESH_SECRET=ibit_repair_refresh_secret_2025_secure_key_apicha_ton
railway variables set SESSION_SECRET=ibit_repair_session_secret_2025_secure_key_apicha_ton

# Deploy Backend
Write-Host "Deploying Backend..." -ForegroundColor Yellow
cd backend
railway up
cd ..

Write-Host "Deployment completed!" -ForegroundColor Green
Write-Host "Railway Project: https://railway.com/project/3b086c2b-00bf-4c87-9dba-810509613cca" -ForegroundColor Cyan