# ========================================
# iBit Repair Docker Management Script
# ========================================
# PowerShell Script สำหรับจัดการ Docker containers

param(
    [Parameter(Position=0)]
    [ValidateSet("start", "stop", "restart", "build", "logs", "status", "clean")]
    [string]$Action = "start"
)

$ComposeFile = "docker-compose.windows.yml"
$EnvFile = "env.docker.template"

# Colors for output
function Write-Info {
    param([string]$Message)
    Write-Host "ℹ️ $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Error {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠️ $Message" -ForegroundColor Yellow
}

# Copy environment template if .env doesn't exist
if (-not (Test-Path ".env") -and (Test-Path $EnvFile)) {
    Write-Info "Copying environment template..."
    Copy-Item $EnvFile ".env"
    Write-Success "Environment file created from template"
}

switch ($Action) {
    "start" {
        Write-Info "Starting iBit Repair System..."
        docker-compose -f $ComposeFile up -d
        if ($LASTEXITCODE -eq 0) {
            Write-Success "System started successfully!"
            Write-Info "Waiting for services to be ready..."
            Start-Sleep -Seconds 10
            Write-Info "🌐 Frontend: http://localhost:3000"
            Write-Info "🔧 Backend API: http://localhost:4000"
            Write-Info "📊 Database: localhost:5432"
            Write-Info "🔑 Login: admin / admin123"
        } else {
            Write-Error "Failed to start system"
        }
    }
    
    "stop" {
        Write-Info "Stopping iBit Repair System..."
        docker-compose -f $ComposeFile down
        if ($LASTEXITCODE -eq 0) {
            Write-Success "System stopped successfully!"
        } else {
            Write-Error "Failed to stop system"
        }
    }
    
    "restart" {
        Write-Info "Restarting iBit Repair System..."
        docker-compose -f $ComposeFile restart
        if ($LASTEXITCODE -eq 0) {
            Write-Success "System restarted successfully!"
        } else {
            Write-Error "Failed to restart system"
        }
    }
    
    "build" {
        Write-Info "Building Docker images..."
        docker-compose -f $ComposeFile build --no-cache
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Images built successfully!"
        } else {
            Write-Error "Failed to build images"
        }
    }
    
    "logs" {
        Write-Info "Showing system logs..."
        docker-compose -f $ComposeFile logs -f
    }
    
    "status" {
        Write-Info "System Status:"
        docker-compose -f $ComposeFile ps
        Write-Info "Docker Volumes:"
        docker volume ls | Select-String "ibit-repair"
        Write-Info "Docker Images:"
        docker images | Select-String "ibit-repair"
    }
    
    "clean" {
        Write-Warning "This will remove all containers, volumes, and images!"
        $confirmation = Read-Host "Are you sure? (y/N)"
        if ($confirmation -eq "y" -or $confirmation -eq "Y") {
            Write-Info "Cleaning up..."
            docker-compose -f $ComposeFile down -v --rmi all
            docker system prune -f
            Write-Success "Cleanup completed!"
        } else {
            Write-Info "Cleanup cancelled"
        }
    }
}

Write-Info "Available commands:"
Write-Host "  .\start-docker.ps1 start    - Start the system"
Write-Host "  .\start-docker.ps1 stop     - Stop the system"
Write-Host "  .\start-docker.ps1 restart  - Restart the system"
Write-Host "  .\start-docker.ps1 build    - Build Docker images"
Write-Host "  .\start-docker.ps1 logs     - Show logs"
Write-Host "  .\start-docker.ps1 status   - Show status"
Write-Host "  .\start-docker.ps1 clean    - Clean up everything"
