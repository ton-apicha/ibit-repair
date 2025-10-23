#!/bin/bash

# ========================================
# iBit Repair Health Check Script
# ========================================
# 
# ตรวจสอบสถานะของระบบ
# 
# ตัวอย่างการใช้งาน:
#   chmod +x scripts/health-check.sh
#   ./scripts/health-check.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
FRONTEND_URL="http://localhost:3000"
BACKEND_URL="http://localhost:4000"
DATABASE_HOST="localhost"
DATABASE_PORT="5432"
DATABASE_NAME="ibit_repair"
DATABASE_USER="ibit_user"

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
}

# Check Docker containers
check_containers() {
    log "Checking Docker containers..."
    
    if docker-compose ps | grep -q "Up"; then
        success "Docker containers are running"
        docker-compose ps
    else
        error "Some Docker containers are not running"
        docker-compose ps
        return 1
    fi
}

# Check frontend health
check_frontend() {
    log "Checking frontend health..."
    
    if curl -f -s "$FRONTEND_URL" > /dev/null; then
        success "Frontend is responding"
    else
        error "Frontend is not responding"
        return 1
    fi
}

# Check backend health
check_backend() {
    log "Checking backend health..."
    
    if curl -f -s "$BACKEND_URL/health" > /dev/null; then
        success "Backend is responding"
        
        # Get health details
        HEALTH_RESPONSE=$(curl -s "$BACKEND_URL/health")
        echo "Health details:"
        echo "$HEALTH_RESPONSE" | jq '.' 2>/dev/null || echo "$HEALTH_RESPONSE"
    else
        error "Backend is not responding"
        return 1
    fi
}

# Check database connection
check_database() {
    log "Checking database connection..."
    
    if docker-compose exec -T postgres pg_isready -U "$DATABASE_USER" -d "$DATABASE_NAME" > /dev/null; then
        success "Database is responding"
    else
        error "Database is not responding"
        return 1
    fi
}

# Check disk space
check_disk_space() {
    log "Checking disk space..."
    
    DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
    
    if [ "$DISK_USAGE" -lt 80 ]; then
        success "Disk usage is OK ($DISK_USAGE%)"
    elif [ "$DISK_USAGE" -lt 90 ]; then
        warning "Disk usage is high ($DISK_USAGE%)"
    else
        error "Disk usage is critical ($DISK_USAGE%)"
        return 1
    fi
}

# Check memory usage
check_memory() {
    log "Checking memory usage..."
    
    MEMORY_USAGE=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}')
    
    if [ "$MEMORY_USAGE" -lt 80 ]; then
        success "Memory usage is OK ($MEMORY_USAGE%)"
    elif [ "$MEMORY_USAGE" -lt 90 ]; then
        warning "Memory usage is high ($MEMORY_USAGE%)"
    else
        error "Memory usage is critical ($MEMORY_USAGE%)"
        return 1
    fi
}

# Check logs for errors
check_logs() {
    log "Checking recent logs for errors..."
    
    ERROR_COUNT=$(docker-compose logs --tail=100 2>&1 | grep -i "error\|exception\|fatal" | wc -l)
    
    if [ "$ERROR_COUNT" -eq 0 ]; then
        success "No recent errors found in logs"
    else
        warning "Found $ERROR_COUNT recent errors in logs"
        echo "Recent errors:"
        docker-compose logs --tail=50 2>&1 | grep -i "error\|exception\|fatal" | tail -5
    fi
}

# Check SSL certificates (if applicable)
check_ssl() {
    log "Checking SSL certificates..."
    
    if [ -f "/etc/ssl/certs/ibit-repair.crt" ]; then
        CERT_EXPIRY=$(openssl x509 -in /etc/ssl/certs/ibit-repair.crt -noout -enddate 2>/dev/null | cut -d= -f2)
        if [ -n "$CERT_EXPIRY" ]; then
            CERT_DATE=$(date -d "$CERT_EXPIRY" +%s)
            CURRENT_DATE=$(date +%s)
            DAYS_LEFT=$(( (CERT_DATE - CURRENT_DATE) / 86400 ))
            
            if [ "$DAYS_LEFT" -gt 30 ]; then
                success "SSL certificate is valid ($DAYS_LEFT days left)"
            elif [ "$DAYS_LEFT" -gt 0 ]; then
                warning "SSL certificate expires in $DAYS_LEFT days"
            else
                error "SSL certificate has expired"
                return 1
            fi
        else
            warning "Could not check SSL certificate expiry"
        fi
    else
        warning "No SSL certificate found"
    fi
}

# Check network connectivity
check_network() {
    log "Checking network connectivity..."
    
    if ping -c 1 8.8.8.8 > /dev/null 2>&1; then
        success "Internet connectivity is OK"
    else
        error "No internet connectivity"
        return 1
    fi
}

# Check backup status
check_backups() {
    log "Checking backup status..."
    
    BACKUP_DIR="/opt/ibit-repair/backups"
    if [ -d "$BACKUP_DIR" ]; then
        LATEST_BACKUP=$(find "$BACKUP_DIR" -name "*.tar.gz" -type f -printf '%T@ %p\n' | sort -n | tail -1 | cut -d' ' -f2)
        
        if [ -n "$LATEST_BACKUP" ]; then
            BACKUP_AGE=$(($(date +%s) - $(stat -c %Y "$LATEST_BACKUP")))
            BACKUP_AGE_DAYS=$((BACKUP_AGE / 86400))
            
            if [ "$BACKUP_AGE_DAYS" -lt 7 ]; then
                success "Recent backup found ($BACKUP_AGE_DAYS days old)"
            else
                warning "Backup is old ($BACKUP_AGE_DAYS days old)"
            fi
        else
            warning "No backups found"
        fi
    else
        warning "Backup directory not found"
    fi
}

# Main health check
main() {
    log "Starting health check for iBit Repair system..."
    
    local exit_code=0
    
    check_containers || exit_code=1
    check_frontend || exit_code=1
    check_backend || exit_code=1
    check_database || exit_code=1
    check_disk_space || exit_code=1
    check_memory || exit_code=1
    check_logs
    check_ssl
    check_network || exit_code=1
    check_backups
    
    if [ $exit_code -eq 0 ]; then
        success "All health checks passed!"
    else
        error "Some health checks failed!"
    fi
    
    return $exit_code
}

# Run main function
main "$@"
