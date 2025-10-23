# Railway Deployment Script
# สำหรับ deploy ระบบ iBit Repair ไปยัง Railway

Write-Host "🚀 Railway Deployment Script for iBit Repair" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green

# ตรวจสอบ Railway CLI
Write-Host "📋 Checking Railway CLI installation..." -ForegroundColor Yellow
try {
    $railwayVersion = railway --version
    Write-Host "✅ Railway CLI installed: $railwayVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Railway CLI not found. Installing..." -ForegroundColor Red
    Write-Host "Please install Railway CLI from: https://docs.railway.app/develop/cli" -ForegroundColor Yellow
    Write-Host "Or run: npm install -g @railway/cli" -ForegroundColor Yellow
    exit 1
}

# ตรวจสอบ Git status
Write-Host "📋 Checking Git status..." -ForegroundColor Yellow
$gitStatus = git status --porcelain
if ($gitStatus) {
    Write-Host "⚠️  Uncommitted changes detected:" -ForegroundColor Yellow
    Write-Host $gitStatus -ForegroundColor Gray
    $commit = Read-Host "Do you want to commit and push changes? (y/n)"
    if ($commit -eq "y" -or $commit -eq "Y") {
        git add .
        git commit -m "🚀 Update for Railway deployment"
        git push origin master
        Write-Host "✅ Changes committed and pushed" -ForegroundColor Green
    }
}

# ตรวจสอบ Environment Variables
Write-Host "📋 Checking environment variables..." -ForegroundColor Yellow
Write-Host "Please ensure the following environment variables are set in Railway:" -ForegroundColor Cyan
Write-Host "- DATABASE_URL" -ForegroundColor Gray
Write-Host "- JWT_SECRET" -ForegroundColor Gray
Write-Host "- JWT_REFRESH_SECRET" -ForegroundColor Gray
Write-Host "- SESSION_SECRET" -ForegroundColor Gray
Write-Host "- CORS_ORIGINS" -ForegroundColor Gray
Write-Host "- NODE_ENV=production" -ForegroundColor Gray

# Deploy to Railway
Write-Host "🚀 Deploying to Railway..." -ForegroundColor Green
Write-Host "Project URL: https://railway.com/project/3b086c2b-00bf-4c87-9dba-810509613cca" -ForegroundColor Cyan

# ตรวจสอบ Railway login
$loginStatus = railway whoami 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "🔐 Please login to Railway first:" -ForegroundColor Yellow
    railway login
}

# Deploy backend
Write-Host "📦 Deploying backend..." -ForegroundColor Yellow
railway up --service backend

# ตรวจสอบ deployment status
Write-Host "📊 Checking deployment status..." -ForegroundColor Yellow
railway status

Write-Host "✅ Deployment completed!" -ForegroundColor Green
Write-Host "🌐 Check your Railway dashboard for deployment status" -ForegroundColor Cyan
Write-Host "📱 Frontend should be deployed to Vercel separately" -ForegroundColor Yellow

# แสดง links ที่สำคัญ
Write-Host "🔗 Important Links:" -ForegroundColor Green
Write-Host "- Railway Project: https://railway.com/project/3b086c2b-00bf-4c87-9dba-810509613cca" -ForegroundColor Cyan
Write-Host "- GitHub Repository: https://github.com/ton-apicha/ibit-repair" -ForegroundColor Cyan
Write-Host "- Railway Documentation: https://docs.railway.app/" -ForegroundColor Cyan

Write-Host "🎯 Next Steps:" -ForegroundColor Green
Write-Host "1. Set up PostgreSQL database in Railway" -ForegroundColor White
Write-Host "2. Configure environment variables" -ForegroundColor White
Write-Host "3. Deploy frontend to Vercel" -ForegroundColor White
Write-Host "4. Test the deployment" -ForegroundColor White

Write-Host "🚀 Railway deployment script completed!" -ForegroundColor Green
