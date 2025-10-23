# ========================================
# Remote Deployment Script for iBit Repair (PowerShell)
# ========================================

param(
    [string]$ServerIP = "103.234.236.108",
    [string]$ServerUser = "debian",
    [string]$SSHKey = "$env:USERPROFILE\.ssh\ibit_repair_key",
    [string]$ProjectDir = "ibit-repair"
)

# Colors for output
$Red = "Red"
$Green = "Green"
$Yellow = "Yellow"
$Blue = "Blue"

function Write-Status {
    param([string]$Message)
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] $Message" -ForegroundColor $Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor $Green
}

function Write-Error {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor $Red
    exit 1
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠️ $Message" -ForegroundColor $Yellow
}

function Invoke-RemoteCommand {
    param([string]$Command)
    $sshCommand = "ssh -i `"$SSHKey`" -o StrictHostKeyChecking=no $ServerUser@$ServerIP `"$Command`""
    Invoke-Expression $sshCommand
}

function Copy-ToRemote {
    param([string]$LocalPath, [string]$RemotePath)
    $scpCommand = "scp -i `"$SSHKey`" -o StrictHostKeyChecking=no `"$LocalPath`" $ServerUser@$ServerIP`:$RemotePath"
    Invoke-Expression $scpCommand
}

Write-Status "🚀 Starting remote deployment of iBit Repair System..."

# Check if SSH key exists
if (-not (Test-Path $SSHKey)) {
    Write-Error "SSH key not found at $SSHKey. Please generate SSH key first."
}

# Test SSH connection
Write-Status "Testing SSH connection..."
try {
    $testResult = Invoke-RemoteCommand "echo 'SSH connection successful'"
    if ($testResult -eq "SSH connection successful") {
        Write-Success "SSH connection established"
    } else {
        Write-Error "SSH connection test failed"
    }
} catch {
    Write-Error "Cannot connect to server. Please check SSH key and server accessibility."
}

# Update system
Write-Status "Updating system packages..."
Invoke-RemoteCommand "sudo apt update && sudo apt upgrade -y"

# Install Docker
Write-Status "Installing Docker..."
Invoke-RemoteCommand "curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh && sudo usermod -aG docker $ServerUser"

# Install Docker Compose
Write-Status "Installing Docker Compose..."
Invoke-RemoteCommand "sudo curl -L 'https://github.com/docker/compose/releases/latest/download/docker-compose-`$(uname -s)-`$(uname -m)' -o /usr/local/bin/docker-compose && sudo chmod +x /usr/local/bin/docker-compose"

# Clone repository
Write-Status "Cloning iBit Repair repository..."
Invoke-RemoteCommand "if [ -d '$ProjectDir' ]; then rm -rf $ProjectDir; fi"
Invoke-RemoteCommand "git clone https://github.com/ton-apicha/ibit-repair.git $ProjectDir"

# Setup environment
Write-Status "Setting up environment configuration..."
Invoke-RemoteCommand "cd $ProjectDir && cp backend/env.production.template .env"

# Update environment variables
Write-Status "Configuring environment variables..."
Invoke-RemoteCommand "cd $ProjectDir && sed -i 's/SERVER_IP=`\"YOUR_SERVER_IP`\"/SERVER_IP=`\"$ServerIP`\"/g' .env"
Invoke-RemoteCommand "cd $ProjectDir && sed -i 's/DB_PASSWORD=`\"CHANGE_THIS_SECURE_PASSWORD`\"/DB_PASSWORD=`\"ibit_secure_password_2025`\"/g' .env"
Invoke-RemoteCommand "cd $ProjectDir && sed -i 's/JWT_SECRET=`\"CHANGE_THIS_TO_A_SECURE_RANDOM_STRING_AT_LEAST_64_CHARACTERS_LONG`\"/JWT_SECRET=`\"ibit_jwt_secret_key_64_characters_minimum_for_production_security_2025`\"/g' .env"
Invoke-RemoteCommand "cd $ProjectDir && sed -i 's/SESSION_SECRET=`\"CHANGE_THIS_TO_A_SECURE_SESSION_SECRET_AT_LEAST_64_CHARACTERS_LONG`\"/SESSION_SECRET=`\"ibit_session_secret_key_64_characters_minimum_for_production_security_2025`\"/g' .env"

# Create necessary directories
Write-Status "Creating necessary directories..."
Invoke-RemoteCommand "cd $ProjectDir && mkdir -p uploads backups logs ssl"

# Make scripts executable
Write-Status "Making scripts executable..."
Invoke-RemoteCommand "cd $ProjectDir && chmod +x scripts/*.sh deploy.sh"

# Deploy application
Write-Status "Deploying application..."
Invoke-RemoteCommand "cd $ProjectDir && ./deploy.sh"

# Wait for services to start
Write-Status "Waiting for services to start..."
Start-Sleep -Seconds 30

# Test deployment
Write-Status "Testing deployment..."
try {
    $healthResult = Invoke-RemoteCommand "curl -f -s http://localhost:4000/health"
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Backend health check passed"
    } else {
        Write-Warning "Backend health check failed - checking logs..."
        Invoke-RemoteCommand "cd $ProjectDir && docker-compose -f docker-compose.production.yml logs backend"
    }
} catch {
    Write-Warning "Health check failed - checking logs..."
    Invoke-RemoteCommand "cd $ProjectDir && docker-compose -f docker-compose.production.yml logs backend"
}

# Show deployment info
Write-Host ""
Write-Host "==========================================" -ForegroundColor $Green
Write-Host "🎉 Deployment completed!" -ForegroundColor $Green
Write-Host "==========================================" -ForegroundColor $Green
Write-Host "🌐 Access your application at: http://$ServerIP" -ForegroundColor $Blue
Write-Host "👤 Login credentials:" -ForegroundColor $Blue
Write-Host "   Username: admin" -ForegroundColor $Yellow
Write-Host "   Password: admin123" -ForegroundColor $Yellow
Write-Host ""
Write-Host "📋 Useful commands:" -ForegroundColor $Blue
Write-Host "   View logs: ssh -i `"$SSHKey`" $ServerUser@$ServerIP 'cd $ProjectDir && docker-compose -f docker-compose.production.yml logs'" -ForegroundColor $Yellow
Write-Host "   Restart: ssh -i `"$SSHKey`" $ServerUser@$ServerIP 'cd $ProjectDir && docker-compose -f docker-compose.production.yml restart'" -ForegroundColor $Yellow
Write-Host "   Backup: ssh -i `"$SSHKey`" $ServerUser@$ServerIP 'cd $ProjectDir && ./scripts/manual-backup.sh'" -ForegroundColor $Yellow
Write-Host ""

Write-Success "iBit Repair System deployed successfully!"
