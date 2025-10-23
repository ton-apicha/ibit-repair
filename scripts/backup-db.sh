#!/bin/bash

# ========================================
# iBit Repair Database Backup Script
# ========================================
# 
# สร้าง backup ของฐานข้อมูล PostgreSQL
# 
# ตัวอย่างการใช้งาน:
#   chmod +x scripts/backup-db.sh
#   ./scripts/backup-db.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
BACKUP_DIR="/opt/ibit-repair/backups"
RETENTION_DAYS=30
DATABASE_NAME="ibit_repair"
DATABASE_USER="ibit_user"
CONTAINER_NAME="ibit-repair-db"

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

# Create backup directory if it doesn't exist
create_backup_dir() {
    if [ ! -d "$BACKUP_DIR" ]; then
        log "Creating backup directory: $BACKUP_DIR"
        sudo mkdir -p "$BACKUP_DIR"
        sudo chown $(whoami):$(whoami) "$BACKUP_DIR"
    fi
}

# Create database backup
create_backup() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="$BACKUP_DIR/ibit_repair_$timestamp.sql"
    local backup_file_gz="$backup_file.gz"
    
    log "Creating database backup..."
    
    # Create SQL dump
    if docker-compose exec -T postgres pg_dump -U "$DATABASE_USER" -d "$DATABASE_NAME" --verbose --clean --no-owner --no-privileges > "$backup_file"; then
        success "Database dump created: $backup_file"
    else
        error "Failed to create database dump"
    fi
    
    # Compress backup
    log "Compressing backup..."
    if gzip "$backup_file"; then
        success "Backup compressed: $backup_file_gz"
        echo "$backup_file_gz"
    else
        error "Failed to compress backup"
    fi
}

# Create binary backup (alternative method)
create_binary_backup() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_dir="$BACKUP_DIR/binary_$timestamp"
    local backup_file="$BACKUP_DIR/ibit_repair_binary_$timestamp.tar.gz"
    
    log "Creating binary backup..."
    
    # Create directory for binary backup
    mkdir -p "$backup_dir"
    
    # Create binary dump
    if docker-compose exec -T postgres pg_dump -U "$DATABASE_USER" -d "$DATABASE_NAME" --verbose --format=custom --compress=9 > "$backup_dir/dump.sql"; then
        success "Binary dump created"
    else
        error "Failed to create binary dump"
    fi
    
    # Create tar archive
    if tar -czf "$backup_file" -C "$backup_dir" .; then
        success "Binary backup created: $backup_file"
        rm -rf "$backup_dir"
        echo "$backup_file"
    else
        error "Failed to create binary backup archive"
    fi
}

# Clean old backups
cleanup_old_backups() {
    log "Cleaning up old backups (older than $RETENTION_DAYS days)..."
    
    local deleted_count=0
    
    # Find and delete old SQL backups
    while IFS= read -r -d '' file; do
        rm "$file"
        ((deleted_count++))
        log "Deleted old backup: $(basename "$file")"
    done < <(find "$BACKUP_DIR" -name "ibit_repair_*.sql.gz" -type f -mtime +$RETENTION_DAYS -print0)
    
    # Find and delete old binary backups
    while IFS= read -r -d '' file; do
        rm "$file"
        ((deleted_count++))
        log "Deleted old backup: $(basename "$file")"
    done < <(find "$BACKUP_DIR" -name "ibit_repair_binary_*.tar.gz" -type f -mtime +$RETENTION_DAYS -print0)
    
    if [ $deleted_count -gt 0 ]; then
        success "Cleaned up $deleted_count old backups"
    else
        log "No old backups to clean up"
    fi
}

# Verify backup integrity
verify_backup() {
    local backup_file="$1"
    
    log "Verifying backup integrity..."
    
    if [[ "$backup_file" == *.gz ]]; then
        # Verify compressed backup
        if gunzip -t "$backup_file"; then
            success "Backup file is valid"
        else
            error "Backup file is corrupted"
        fi
    elif [[ "$backup_file" == *.tar.gz ]]; then
        # Verify tar archive
        if tar -tzf "$backup_file" > /dev/null; then
            success "Backup archive is valid"
        else
            error "Backup archive is corrupted"
        fi
    fi
}

# Get backup statistics
get_backup_stats() {
    log "Backup statistics:"
    
    local total_backups=$(find "$BACKUP_DIR" -name "ibit_repair_*" -type f | wc -l)
    local total_size=$(find "$BACKUP_DIR" -name "ibit_repair_*" -type f -exec du -ch {} + | tail -1 | cut -f1)
    
    echo "  Total backups: $total_backups"
    echo "  Total size: $total_size"
    echo "  Backup directory: $BACKUP_DIR"
}

# Main backup function
main() {
    log "Starting database backup process..."
    
    # Check if Docker is running
    if ! docker-compose ps | grep -q "Up"; then
        error "Docker containers are not running"
    fi
    
    # Create backup directory
    create_backup_dir
    
    # Create backup based on type
    if [ "$1" = "--binary" ]; then
        backup_file=$(create_binary_backup)
    else
        backup_file=$(create_backup)
    fi
    
    # Verify backup
    verify_backup "$backup_file"
    
    # Cleanup old backups
    cleanup_old_backups
    
    # Show statistics
    get_backup_stats
    
    success "Backup completed successfully!"
    log "Backup file: $backup_file"
}

# Show usage
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --binary    Create binary backup (smaller, faster restore)"
    echo "  --help      Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                    # Create SQL backup"
    echo "  $0 --binary          # Create binary backup"
}

# Parse arguments
case "$1" in
    --help)
        usage
        exit 0
        ;;
    *)
        main "$@"
        ;;
esac
