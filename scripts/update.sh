#!/bin/bash

# ========================================
# Update Script for iBit Repair System
# อัพเดตระบบอย่างปลอดภัย
# ========================================

set -e

echo "🔄 กำลังอัพเดต iBit Repair System..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local status=$1
    local message=$2
    
    case $status in
        "OK")
            echo -e "${GREEN}✅ $message${NC}"
            ;;
        "WARN")
            echo -e "${YELLOW}⚠️  $message${NC}"
            ;;
        "ERROR")
            echo -e "${RED}❌ $message${NC}"
            ;;
        "INFO")
            echo -e "${BLUE}ℹ️  $message${NC}"
            ;;
    esac
}

# Check if running in correct directory
if [ ! -f "docker-compose.production.yml" ]; then
    print_status "ERROR" "ไม่พบ docker-compose.production.yml - รันจาก root directory ของโปรเจค"
    exit 1
fi

# Check if .env file exists
if [ ! -f ".env" ]; then
    print_status "ERROR" "ไม่พบไฟล์ .env"
    exit 1
fi

# Create backup before update
print_status "INFO" "สร้าง backup ก่อนอัพเดต..."
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="backups/update_${TIMESTAMP}"
mkdir -p "$BACKUP_DIR"

# Backup database
print_status "INFO" "Backup database..."
docker-compose -f docker-compose.production.yml exec -T postgres pg_dump -U ibit_user ibit_repair > "$BACKUP_DIR/database_backup.sql"

# Backup uploads
if [ -d "uploads" ]; then
    print_status "INFO" "Backup uploads..."
    cp -r uploads "$BACKUP_DIR/"
fi

# Backup configuration
print_status "INFO" "Backup configuration..."
cp .env "$BACKUP_DIR/"
cp docker-compose.production.yml "$BACKUP_DIR/"

print_status "OK" "Backup เสร็จสิ้น: $BACKUP_DIR"

# Stop services gracefully
print_status "INFO" "หยุด services..."
docker-compose -f docker-compose.production.yml down

# Pull latest images
print_status "INFO" "ดึง Docker images ล่าสุด..."
docker-compose -f docker-compose.production.yml pull

# Rebuild containers
print_status "INFO" "สร้าง containers ใหม่..."
docker-compose -f docker-compose.production.yml build --no-cache

# Start services
print_status "INFO" "เริ่ม services..."
docker-compose -f docker-compose.production.yml up -d

# Wait for services to be ready
print_status "INFO" "รอ services เริ่มทำงาน..."
sleep 30

# Health check
print_status "INFO" "ตรวจสอบสุขภาพของระบบ..."
./scripts/health-check.sh

# Run database migrations if needed
print_status "INFO" "ตรวจสอบ database migrations..."
docker-compose -f docker-compose.production.yml exec backend npx prisma migrate deploy

# Clean up old images
print_status "INFO" "ทำความสะอาด Docker images เก่า..."
docker image prune -f

# Final status
echo ""
echo "=========================================="
echo "🎉 อัพเดตเสร็จสิ้น!"
echo "=========================================="
print_status "OK" "ระบบได้รับการอัพเดตเรียบร้อยแล้ว"
print_status "INFO" "Backup เก็บไว้ที่: $BACKUP_DIR"
print_status "INFO" "ตรวจสอบ logs: docker-compose -f docker-compose.production.yml logs"

echo ""
echo "📋 ขั้นตอนถัดไป:"
echo "1. ตรวจสอบการทำงานของระบบ"
echo "2. ทดสอบฟีเจอร์ต่างๆ"
echo "3. ตรวจสอบ logs หากมีปัญหา"
echo "4. ลบ backup เก่า (ถ้าไม่ต้องการ)"
