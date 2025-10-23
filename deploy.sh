#!/bin/bash

# ========================================
# iBit Repair Production Deployment Script
# ========================================
# 
# Deploy ระบบ iBit Repair บน production server
# 
# ตัวอย่างการใช้งาน:
#   chmod +x deploy.sh
#   ./deploy.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="ibit-repair"
DEPLOY_DIR="$(pwd)"
BACKUP_DIR="$(pwd)/backups"
LOG_DIR="$(pwd)/logs"
UPLOAD_DIR="$(pwd)/uploads"

# Functions
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
    exit 1
}

# Check if running as root (optional for Debian VPS)
check_root() {
    if [ "$EUID" -eq 0 ]; then
        warning "Running as root - consider using a non-root user for production"
    fi
}

# Check system requirements
check_requirements() {
    log "Checking system requirements..."
    
    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        error "Docker is not installed"
    fi
    
    # Check if Docker Compose is installed
    if ! command -v docker-compose &> /dev/null; then
        error "Docker Compose is not installed"
    fi
    
    # Check available disk space (at least 5GB)
    local available_space=$(df / | awk 'NR==2 {print $4}')
    local required_space=5242880 # 5GB in KB
    
    if [ "$available_space" -lt "$required_space" ]; then
        error "Insufficient disk space. At least 5GB required"
    fi
    
    # Check available memory (at least 2GB)
    local available_memory=$(free -m | awk 'NR==2{printf "%.0f", $7}')
    local required_memory=2048 # 2GB
    
    if [ "$available_memory" -lt "$required_memory" ]; then
        warning "Low memory available. At least 2GB recommended"
    fi
    
    success "System requirements check passed"
}

# Create directories
create_directories() {
    log "Creating deployment directories..."
    
    mkdir -p "$DEPLOY_DIR"
    mkdir -p "$BACKUP_DIR"
    mkdir -p "$LOG_DIR"
    mkdir -p "$UPLOAD_DIR"
    
    # Set proper permissions
    chown -R 1001:1001 "$DEPLOY_DIR"
    chmod -R 755 "$DEPLOY_DIR"
    
    success "Directories created successfully"
}

# Install dependencies
install_dependencies() {
    log "Installing system dependencies..."
    
    # Update package list
    sudo apt-get update
    
    # Install required packages
    sudo apt-get install -y \
        curl \
        wget \
        git \
        jq \
        htop \
        nano \
        unzip \
        gzip \
        tar \
        bc
    
    success "Dependencies installed successfully"
}

# Setup firewall
setup_firewall() {
    log "Setting up firewall rules..."
    
    # Enable UFW if not already enabled
    sudo ufw --force enable
    
    # Allow SSH
    sudo ufw allow ssh
    
    # Allow HTTP and HTTPS
    sudo ufw allow 80/tcp
    sudo ufw allow 443/tcp
    
    # Allow application ports (if not behind reverse proxy)
    # ufw allow 3000/tcp
    # ufw allow 4000/tcp
    
    success "Firewall configured successfully"
}

# Create system user
create_system_user() {
    log "Creating system user for application..."
    
    # Add current user to docker group if not already added
    if ! groups $USER | grep -q docker; then
        sudo usermod -aG docker $USER
        success "Added $USER to docker group"
        warning "Please logout and login again for docker group changes to take effect"
    else
        log "User $USER already in docker group"
    fi
}

# Setup environment
setup_environment() {
    log "Setting up environment configuration..."
    
    # Copy production environment template if .env doesn't exist
    if [ ! -f "$DEPLOY_DIR/.env" ]; then
        if [ -f "$DEPLOY_DIR/backend/env.production.template" ]; then
            cp "$DEPLOY_DIR/backend/env.production.template" "$DEPLOY_DIR/.env"
        else
            # Create production environment file
            cat > "$DEPLOY_DIR/.env" << EOF
# Production Environment Configuration
NODE_ENV=production
PORT=4000
HOST=0.0.0.0

# Database Configuration
DATABASE_URL=postgresql://ibit_user:CHANGE_THIS_PASSWORD@postgres:5432/ibit_repair?schema=public

# JWT Configuration
JWT_SECRET=CHANGE_THIS_TO_A_SECURE_RANDOM_STRING_AT_LEAST_64_CHARACTERS
JWT_EXPIRES_IN=86400
JWT_REFRESH_EXPIRES_IN=604800

# Security Configuration
CORS_ORIGINS=http://YOUR_SERVER_IP:3000,http://YOUR_SERVER_IP
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100

# Logging Configuration
LOG_LEVEL=warn
LOG_DIR=/app/logs
LOG_RETENTION_DAYS=30

# File Upload Configuration
MAX_FILE_SIZE=10485760
UPLOAD_DIR=/app/uploads

# Email Configuration (Optional)
SMTP_HOST=smtp.yourdomain.com
SMTP_PORT=587
SMTP_USER=noreply@yourdomain.com
SMTP_PASS=YOUR_EMAIL_PASSWORD
EMAIL_FROM=noreply@yourdomain.com

# Feature Flags
ENABLE_REGISTRATION=false
ENABLE_EMAIL_VERIFICATION=true
ENABLE_PASSWORD_RESET=true
ENABLE_AUDIT_LOG=true

# External Services
BACKUP_ENABLED=true
BACKUP_SCHEDULE=0 2 * * *
BACKUP_RETENTION_DAYS=90
EOF
    
    # Create database password
    DB_PASSWORD=$(openssl rand -base64 32)
    sed -i "s/CHANGE_THIS_PASSWORD/$DB_PASSWORD/g" "$DEPLOY_DIR/.env"
    
    # Create JWT secret
    JWT_SECRET=$(openssl rand -base64 64)
    sed -i "s/CHANGE_THIS_TO_A_SECURE_RANDOM_STRING_AT_LEAST_64_CHARACTERS/$JWT_SECRET/g" "$DEPLOY_DIR/.env"
    
    # Set proper permissions
    chmod 600 "$DEPLOY_DIR/.env"
    chown $USER:$USER "$DEPLOY_DIR/.env"
    
    success "Environment configuration created"
    warning "Please update the .env file with your actual domain and email settings"
}

# Setup SSL certificates (Let's Encrypt)
setup_ssl() {
    log "Setting up SSL certificates..."
    
    # Install certbot
    sudo apt-get install -y certbot python3-certbot-nginx
    
    warning "SSL setup requires domain configuration"
    warning "Please run: certbot --nginx -d yourdomain.com -d www.yourdomain.com"
    warning "After the application is deployed and accessible"
}

# Create systemd service
create_systemd_service() {
    log "Creating systemd service..."
    
    sudo tee /etc/systemd/system/ibit-repair.service > /dev/null << EOF
[Unit]
Description=iBit Repair Application
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=$DEPLOY_DIR
ExecStart=/usr/local/bin/docker-compose -f $DEPLOY_DIR/docker-compose.yml up -d
ExecStop=/usr/local/bin/docker-compose -f $DEPLOY_DIR/docker-compose.yml down
TimeoutStartSec=0
User=root

[Install]
WantedBy=multi-user.target
EOF
    
    sudo systemctl daemon-reload
    sudo systemctl enable ibit-repair
    
    success "Systemd service created and enabled"
}

# Setup backup cron job
setup_backup_cron() {
    log "Setting up automated backups..."
    
    # Make backup script executable
    chmod +x "$DEPLOY_DIR/scripts/backup-db.sh"
    
    # Add cron job for daily backups
    (crontab -l 2>/dev/null; echo "0 2 * * * $DEPLOY_DIR/scripts/manual-backup.sh >> $LOG_DIR/backup.log 2>&1") | crontab -
    
    success "Automated backup cron job configured"
}

# Setup log rotation
setup_log_rotation() {
    log "Setting up log rotation..."
    
    sudo tee /etc/logrotate.d/ibit-repair > /dev/null << EOF
$LOG_DIR/*.log {
    daily
    rotate 30
    compress
    delaycompress
    missingok
    notifempty
    create 644 ibit ibit
    postrotate
        /bin/kill -USR1 \$(cat /var/run/docker-compose.pid 2>/dev/null) 2>/dev/null || true
    endscript
}
EOF
    
    success "Log rotation configured"
}

# Setup monitoring
setup_monitoring() {
    log "Setting up basic monitoring..."
    
    # Make health check script executable
    chmod +x "$DEPLOY_DIR/scripts/health-check.sh"
    
    # Add cron job for health checks
    (crontab -l 2>/dev/null; echo "*/5 * * * * $DEPLOY_DIR/scripts/health-check.sh >> $LOG_DIR/health.log 2>&1") | crontab -
    
    success "Basic monitoring configured"
}

# Deploy application
deploy_application() {
    log "Deploying application..."
    
    # Copy application files
    cp -r . "$DEPLOY_DIR/"
    
    # Set proper ownership
    chown -R $USER:$USER "$DEPLOY_DIR"
    
    # Build and start containers
    cd "$DEPLOY_DIR"
    docker-compose -f docker-compose.production.yml build --no-cache
    docker-compose -f docker-compose.production.yml up -d
    
    success "Application deployed successfully"
}

# Verify deployment
verify_deployment() {
    log "Verifying deployment..."
    
    # Wait for services to start
    sleep 30
    
    # Check if containers are running
    if docker-compose -f docker-compose.production.yml ps | grep -q "Up"; then
        success "All containers are running"
    else
        error "Some containers failed to start"
    fi
    
    # Check health endpoints
    if curl -f -s http://localhost:4000/health > /dev/null; then
        success "Backend health check passed"
    else
        error "Backend health check failed"
    fi
    
    if curl -f -s http://localhost:3000 > /dev/null; then
        success "Frontend health check passed"
    else
        error "Frontend health check failed"
    fi
    
    success "Deployment verification completed"
}

# Show deployment info
show_deployment_info() {
    log "Deployment completed successfully!"
    echo ""
    echo "=== Deployment Information ==="
    echo "Application URL: http://$(hostname -I | awk '{print $1}'):3000"
    echo "API URL: http://$(hostname -I | awk '{print $1}'):4000"
    echo "Deployment Directory: $DEPLOY_DIR"
    echo "Log Directory: $LOG_DIR"
    echo "Backup Directory: $BACKUP_DIR"
    echo ""
    echo "=== Next Steps ==="
    echo "1. Update .env file with your domain and email settings"
    echo "2. Configure SSL certificates with: certbot --nginx -d yourdomain.com"
    echo "3. Set up reverse proxy (Nginx) for production"
    echo "4. Configure firewall rules"
    echo "5. Test the application thoroughly"
    echo ""
    echo "=== Useful Commands ==="
    echo "View logs: docker-compose logs -f"
    echo "Restart: systemctl restart ibit-repair"
    echo "Health check: $DEPLOY_DIR/scripts/health-check.sh"
    echo "Backup: $DEPLOY_DIR/scripts/backup-db.sh"
    echo ""
}

# Main deployment function
main() {
    log "Starting iBit Repair production deployment..."
    
    check_root
    check_requirements
    create_directories
    install_dependencies
    setup_firewall
    create_system_user
    setup_environment
    create_systemd_service
    setup_backup_cron
    setup_log_rotation
    setup_monitoring
    deploy_application
    verify_deployment
    show_deployment_info
    
    success "Deployment completed successfully!"
}

# Run main function
main "$@"
