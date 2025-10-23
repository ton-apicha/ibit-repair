#!/bin/bash

# ========================================
# Remote Deployment Script for iBit Repair
# ========================================

set -e

# Configuration
SERVER_IP="103.234.236.108"
SERVER_USER="debian"
SSH_KEY="$HOME/.ssh/ibit_repair_key"
PROJECT_DIR="ibit-repair"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
    exit 1
}

warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

# Function to run commands on remote server
run_remote() {
    ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "$SERVER_USER@$SERVER_IP" "$@"
}

# Function to copy files to remote server
copy_to_remote() {
    scp -i "$SSH_KEY" -o StrictHostKeyChecking=no "$1" "$SERVER_USER@$SERVER_IP:$2"
}

print_status "🚀 Starting remote deployment of iBit Repair System..."

# Check if SSH key exists
if [ ! -f "$SSH_KEY" ]; then
    error "SSH key not found at $SSH_KEY. Please generate SSH key first."
fi

# Test SSH connection
print_status "Testing SSH connection..."
if ! ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no -o ConnectTimeout=10 "$SERVER_USER@$SERVER_IP" "echo 'SSH connection successful'"; then
    error "Cannot connect to server. Please check SSH key and server accessibility."
fi

success "SSH connection established"

# Update system
print_status "Updating system packages..."
run_remote "sudo apt update && sudo apt upgrade -y"

# Install Docker
print_status "Installing Docker..."
run_remote "curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh && sudo usermod -aG docker $SERVER_USER"

# Install Docker Compose
print_status "Installing Docker Compose..."
run_remote "sudo curl -L 'https://github.com/docker/compose/releases/latest/download/docker-compose-\$(uname -s)-\$(uname -m)' -o /usr/local/bin/docker-compose && sudo chmod +x /usr/local/bin/docker-compose"

# Clone repository
print_status "Cloning iBit Repair repository..."
run_remote "if [ -d '$PROJECT_DIR' ]; then rm -rf $PROJECT_DIR; fi"
run_remote "git clone https://github.com/ton-apicha/ibit-repair.git $PROJECT_DIR"

# Setup environment
print_status "Setting up environment configuration..."
run_remote "cd $PROJECT_DIR && cp backend/env.production.template .env"

# Update environment variables
print_status "Configuring environment variables..."
run_remote "cd $PROJECT_DIR && sed -i 's/SERVER_IP=\"YOUR_SERVER_IP\"/SERVER_IP=\"$SERVER_IP\"/g' .env"
run_remote "cd $PROJECT_DIR && sed -i 's/DB_PASSWORD=\"CHANGE_THIS_SECURE_PASSWORD\"/DB_PASSWORD=\"ibit_secure_password_2025\"/g' .env"
run_remote "cd $PROJECT_DIR && sed -i 's/JWT_SECRET=\"CHANGE_THIS_TO_A_SECURE_RANDOM_STRING_AT_LEAST_64_CHARACTERS_LONG\"/JWT_SECRET=\"ibit_jwt_secret_key_64_characters_minimum_for_production_security_2025\"/g' .env"
run_remote "cd $PROJECT_DIR && sed -i 's/SESSION_SECRET=\"CHANGE_THIS_TO_A_SECURE_SESSION_SECRET_AT_LEAST_64_CHARACTERS_LONG\"/SESSION_SECRET=\"ibit_session_secret_key_64_characters_minimum_for_production_security_2025\"/g' .env"

# Create necessary directories
print_status "Creating necessary directories..."
run_remote "cd $PROJECT_DIR && mkdir -p uploads backups logs ssl"

# Make scripts executable
print_status "Making scripts executable..."
run_remote "cd $PROJECT_DIR && chmod +x scripts/*.sh deploy.sh"

# Deploy application
print_status "Deploying application..."
run_remote "cd $PROJECT_DIR && ./deploy.sh"

# Wait for services to start
print_status "Waiting for services to start..."
sleep 30

# Test deployment
print_status "Testing deployment..."
if run_remote "curl -f -s http://localhost:4000/health > /dev/null"; then
    success "Backend health check passed"
else
    warning "Backend health check failed - checking logs..."
    run_remote "cd $PROJECT_DIR && docker-compose -f docker-compose.production.yml logs backend"
fi

# Show deployment info
echo ""
echo "=========================================="
echo "🎉 Deployment completed!"
echo "=========================================="
echo "🌐 Access your application at: http://$SERVER_IP"
echo "👤 Login credentials:"
echo "   Username: admin"
echo "   Password: admin123"
echo ""
echo "📋 Useful commands:"
echo "   View logs: ssh -i $SSH_KEY $SERVER_USER@$SERVER_IP 'cd $PROJECT_DIR && docker-compose -f docker-compose.production.yml logs'"
echo "   Restart: ssh -i $SSH_KEY $SERVER_USER@$SERVER_IP 'cd $PROJECT_DIR && docker-compose -f docker-compose.production.yml restart'"
echo "   Backup: ssh -i $SSH_KEY $SERVER_USER@$SERVER_IP 'cd $PROJECT_DIR && ./scripts/manual-backup.sh'"
echo ""

success "iBit Repair System deployed successfully!"