# Development Mode Start Script for iBit Repair

Write-Host "🚀 Starting iBit Repair System in Development Mode..." -ForegroundColor Blue

# Stop any existing containers
Write-Host "🛑 Stopping existing containers..." -ForegroundColor Yellow
docker-compose -f docker-compose.dev.yml down

# Start the system in development mode
Write-Host "🐳 Starting Docker containers in development mode..." -ForegroundColor Yellow
docker-compose -f docker-compose.dev.yml up -d

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ System started successfully in development mode!" -ForegroundColor Green
    Write-Host ""
    Write-Host "🌐 Frontend: http://localhost:3000" -ForegroundColor Cyan
    Write-Host "🔧 Backend API: http://localhost:4000" -ForegroundColor Cyan
    Write-Host "📊 Database: localhost:5432" -ForegroundColor Cyan
    Write-Host "🔑 Login: admin / admin123" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "📝 Development mode features:" -ForegroundColor Yellow
    Write-Host "  - Hot reload enabled" -ForegroundColor Gray
    Write-Host "  - Source code mounted as volumes" -ForegroundColor Gray
    Write-Host "  - Faster startup (no build required)" -ForegroundColor Gray
} else {
    Write-Host "❌ Failed to start system" -ForegroundColor Red
}

Write-Host ""
Write-Host "📋 Useful commands:" -ForegroundColor Blue
Write-Host "  docker-compose -f docker-compose.dev.yml logs -f" -ForegroundColor Gray
Write-Host "  docker-compose -f docker-compose.dev.yml down" -ForegroundColor Gray
Write-Host "  docker-compose -f docker-compose.dev.yml restart" -ForegroundColor Gray
