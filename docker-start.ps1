# Simple Docker Start Script for iBit Repair

Write-Host "🚀 Starting iBit Repair System..." -ForegroundColor Blue

# Copy environment template if .env doesn't exist
if (-not (Test-Path ".env") -and (Test-Path "env.docker.template")) {
    Write-Host "📝 Creating environment file..." -ForegroundColor Yellow
    Copy-Item "env.docker.template" ".env"
}

# Start the system
Write-Host "🐳 Starting Docker containers..." -ForegroundColor Yellow
docker-compose -f docker-compose.windows.yml up -d

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ System started successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "🌐 Frontend: http://localhost:3000" -ForegroundColor Cyan
    Write-Host "🔧 Backend API: http://localhost:4000" -ForegroundColor Cyan
    Write-Host "📊 Database: localhost:5432" -ForegroundColor Cyan
    Write-Host "🔑 Login: admin / admin123" -ForegroundColor Cyan
} else {
    Write-Host "❌ Failed to start system" -ForegroundColor Red
}
