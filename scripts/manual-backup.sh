#!/bin/bash

# ========================================
# Manual Backup Script for iBit Repair System
# สร้าง backup ของ database และไฟล์สำคัญ
# ========================================

set -e

echo "💾 กำลังสร้าง backup ของ iBit Repair System..."

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

# Create backup directory
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="backups/manual_${TIMESTAMP}"
mkdir -p "$BACKUP_DIR"

print_status "INFO" "สร้าง backup directory: $BACKUP_DIR"

# Check if services are running
if ! docker-compose -f docker-compose.production.yml ps | grep -q "Up"; then
    print_status "WARN" "Services ไม่ทำงาน - เริ่ม services ก่อน..."
    docker-compose -f docker-compose.production.yml up -d
    sleep 10
fi

# Backup database
print_status "INFO" "Backup database..."
DB_BACKUP_FILE="$BACKUP_DIR/database_backup_${TIMESTAMP}.sql"
docker-compose -f docker-compose.production.yml exec -T postgres pg_dump -U ibit_user ibit_repair > "$DB_BACKUP_FILE"

# Compress database backup
gzip "$DB_BACKUP_FILE"
print_status "OK" "Database backup: ${DB_BACKUP_FILE}.gz"

# Backup uploads directory
if [ -d "uploads" ] && [ "$(ls -A uploads)" ]; then
    print_status "INFO" "Backup uploads..."
    tar -czf "$BACKUP_DIR/uploads_backup_${TIMESTAMP}.tar.gz" uploads/
    print_status "OK" "Uploads backup: uploads_backup_${TIMESTAMP}.tar.gz"
else
    print_status "INFO" "ไม่มี uploads ที่ต้อง backup"
fi

# Backup configuration files
print_status "INFO" "Backup configuration..."
cp .env "$BACKUP_DIR/"
cp docker-compose.production.yml "$BACKUP_DIR/"

# Backup logs (last 7 days)
if [ -d "logs" ] && [ "$(ls -A logs)" ]; then
    print_status "INFO" "Backup logs (7 วันล่าสุด)..."
    find logs -name "*.log" -mtime -7 -exec tar -czf "$BACKUP_DIR/logs_backup_${TIMESTAMP}.tar.gz" {} +
    print_status "OK" "Logs backup: logs_backup_${TIMESTAMP}.tar.gz"
fi

# Create backup info file
cat > "$BACKUP_DIR/backup_info.txt" << EOF
iBit Repair System Backup
========================
Backup Date: $(date)
Backup Type: Manual
System Version: $(git describe --tags --always 2>/dev/null || echo "Unknown")

Contents:
- Database backup (SQL dump)
- Uploads directory
- Configuration files
- Recent logs (7 days)

To restore:
1. Extract this backup
2. Restore database: gunzip -c database_backup_*.sql.gz | docker-compose exec -T postgres psql -U ibit_user -d ibit_repair
3. Restore uploads: tar -xzf uploads_backup_*.tar.gz
4. Update configuration files
EOF

print_status "OK" "Backup info: backup_info.txt"

# Calculate backup size
BACKUP_SIZE=$(du -sh "$BACKUP_DIR" | cut -f1)
print_status "OK" "ขนาด backup: $BACKUP_SIZE"

# Clean up old backups (keep last 10 manual backups)
print_status "INFO" "ทำความสะอาด backup เก่า (เก็บ 10 ล่าสุด)..."
cd backups
ls -t manual_* 2>/dev/null | tail -n +11 | xargs -r rm -rf
cd ..

# Final summary
echo ""
echo "=========================================="
echo "🎉 Backup เสร็จสิ้น!"
echo "=========================================="
print_status "OK" "Backup เก็บไว้ที่: $BACKUP_DIR"
print_status "INFO" "ขนาด: $BACKUP_SIZE"

echo ""
echo "📋 ข้อมูล backup:"
echo "- Database: ${DB_BACKUP_FILE}.gz"
if [ -f "$BACKUP_DIR/uploads_backup_${TIMESTAMP}.tar.gz" ]; then
    echo "- Uploads: uploads_backup_${TIMESTAMP}.tar.gz"
fi
if [ -f "$BACKUP_DIR/logs_backup_${TIMESTAMP}.tar.gz" ]; then
    echo "- Logs: logs_backup_${TIMESTAMP}.tar.gz"
fi
echo "- Config: .env, docker-compose.production.yml"
echo "- Info: backup_info.txt"

echo ""
echo "💡 คำแนะนำ:"
echo "1. เก็บ backup ไว้ในที่ปลอดภัย"
echo "2. ทดสอบ restore ในระบบทดสอบ"
echo "3. Backup อัตโนมัติ: ตั้ง cron job สำหรับ script นี้"
