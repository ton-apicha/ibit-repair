# Simple Remote Deployment Script for iBit Repair

$ServerIP = "103.234.236.108"
$ServerUser = "debian"
$SSHKey = "$env:USERPROFILE\.ssh\ibit_repair_key"
$ProjectDir = "ibit-repair"

Write-Host "🚀 Starting remote deployment..." -ForegroundColor Blue

# Test SSH connection
Write-Host "Testing SSH connection..." -ForegroundColor Yellow
ssh -i $SSHKey -o StrictHostKeyChecking=no $ServerUser@$ServerIP "echo 'SSH connection successful'"

# Update system
Write-Host "Updating system packages..." -ForegroundColor Yellow
ssh -i $SSHKey -o StrictHostKeyChecking=no $ServerUser@$ServerIP "sudo apt update && sudo apt upgrade -y"

# Install Docker
Write-Host "Installing Docker..." -ForegroundColor Yellow
ssh -i $SSHKey -o StrictHostKeyChecking=no $ServerUser@$ServerIP "curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh && sudo usermod -aG docker $ServerUser"

# Install Docker Compose
Write-Host "Installing Docker Compose..." -ForegroundColor Yellow
ssh -i $SSHKey -o StrictHostKeyChecking=no $ServerUser@$ServerIP "sudo curl -L 'https://github.com/docker/compose/releases/latest/download/docker-compose-`$(uname -s)-`$(uname -m)' -o /usr/local/bin/docker-compose && sudo chmod +x /usr/local/bin/docker-compose"

# Clone repository
Write-Host "Cloning repository..." -ForegroundColor Yellow
ssh -i $SSHKey -o StrictHostKeyChecking=no $ServerUser@$ServerIP "if [ -d '$ProjectDir' ]; then rm -rf $ProjectDir; fi"
ssh -i $SSHKey -o StrictHostKeyChecking=no $ServerUser@$ServerIP "git clone https://github.com/ton-apicha/ibit-repair.git $ProjectDir"

# Setup environment
Write-Host "Setting up environment..." -ForegroundColor Yellow
ssh -i $SSHKey -o StrictHostKeyChecking=no $ServerUser@$ServerIP "cd $ProjectDir && cp backend/env.production.template .env"

# Configure environment variables
Write-Host "Configuring environment variables..." -ForegroundColor Yellow
ssh -i $SSHKey -o StrictHostKeyChecking=no $ServerUser@$ServerIP "cd $ProjectDir && sed -i 's/SERVER_IP=`\"YOUR_SERVER_IP`\"/SERVER_IP=`\"$ServerIP`\"/g' .env"
ssh -i $SSHKey -o StrictHostKeyChecking=no $ServerUser@$ServerIP "cd $ProjectDir && sed -i 's/DB_PASSWORD=`\"CHANGE_THIS_SECURE_PASSWORD`\"/DB_PASSWORD=`\"ibit_secure_password_2025`\"/g' .env"

# Create directories
Write-Host "Creating directories..." -ForegroundColor Yellow
ssh -i $SSHKey -o StrictHostKeyChecking=no $ServerUser@$ServerIP "cd $ProjectDir && mkdir -p uploads backups logs ssl"

# Make scripts executable
Write-Host "Making scripts executable..." -ForegroundColor Yellow
ssh -i $SSHKey -o StrictHostKeyChecking=no $ServerUser@$ServerIP "cd $ProjectDir && chmod +x scripts/*.sh deploy.sh"

# Deploy application
Write-Host "Deploying application..." -ForegroundColor Yellow
ssh -i $SSHKey -o StrictHostKeyChecking=no $ServerUser@$ServerIP "cd $ProjectDir && ./deploy.sh"

Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "🎉 Deployment completed!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host "🌐 Access: http://$ServerIP" -ForegroundColor Blue
Write-Host "👤 Login: admin / admin123" -ForegroundColor Blue
Write-Host ""
