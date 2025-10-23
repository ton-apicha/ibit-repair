#!/bin/bash

# ========================================
# iBit Repair Database Restore Script
# ========================================
# 
# กู้คืนฐานข้อมูลจาก backup file
# 
# ตัวอย่างการใช้งาน:
#   chmod +x scripts/restore-db.sh
#   ./scripts/restore-db.sh /path/to/backup.sql.gz

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
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

# Show usage
usage() {
    echo "Usage: $0 BACKUP_FILE [OPTIONS]"
    echo ""
    echo "Arguments:"
    echo "  BACKUP_FILE    Path to backup file (.sql.gz or .tar.gz)"
    echo ""
    echo "Options:"
    echo "  --force        Force restore without confirmation"
    echo "  --dry-run      Show what would be restored without actually doing it"
    echo "  --help         Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 /opt/ibit-repair/backups/ibit_repair_20241225_120000.sql.gz"
    echo "  $0 /opt/ibit-repair/backups/ibit_repair_binary_20241225_120000.tar.gz --force"
    echo "  $0 /path/to/backup.sql.gz --dry-run"
}

# Check if backup file exists and is valid
validate_backup_file() {
    local backup_file="$1"
    
    if [ ! -f "$backup_file" ]; then
        error "Backup file not found: $backup_file"
    fi
    
    log "Validating backup file: $backup_file"
    
    if [[ "$backup_file" == *.gz ]]; then
        if gunzip -t "$backup_file"; then
            success "SQL backup file is valid"
        else
            error "Backup file is corrupted"
        fi
    elif [[ "$backup_file" == *.tar.gz ]]; then
        if tar -tzf "$backup_file" > /dev/null; then
            success "Binary backup file is valid"
        else
            error "Backup file is corrupted"
        fi
    else
        error "Unsupported backup file format. Supported: .sql.gz, .tar.gz"
    fi
}

# Get backup file info
get_backup_info() {
    local backup_file="$1"
    
    log "Backup file information:"
    echo "  File: $(basename "$backup_file")"
    echo "  Size: $(du -h "$backup_file" | cut -f1)"
    echo "  Modified: $(stat -c %y "$backup_file")"
    
    if [[ "$backup_file" == *.gz ]]; then
        echo "  Type: SQL backup"
        echo "  Compressed size: $(du -h "$backup_file" | cut -f1)"
    elif [[ "$backup_file" == *.tar.gz ]]; then
        echo "  Type: Binary backup"
        echo "  Archive size: $(du -h "$backup_file" | cut -f1)"
    fi
}

# Create database backup before restore
create_pre_restore_backup() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local pre_backup_file="/tmp/ibit_repair_pre_restore_$timestamp.sql.gz"
    
    log "Creating pre-restore backup..."
    
    if docker-compose exec -T postgres pg_dump -U "$DATABASE_USER" -d "$DATABASE_NAME" --verbose --clean --no-owner --no-privileges | gzip > "$pre_backup_file"; then
        success "Pre-restore backup created: $pre_backup_file"
        echo "$pre_backup_file"
    else
        error "Failed to create pre-restore backup"
    fi
}

# Restore from SQL backup
restore_sql_backup() {
    local backup_file="$1"
    local dry_run="$2"
    
    log "Restoring from SQL backup..."
    
    if [ "$dry_run" = "true" ]; then
        log "DRY RUN: Would restore from $backup_file"
        return 0
    fi
    
    # Drop and recreate database
    log "Dropping existing database..."
    docker-compose exec -T postgres psql -U "$DATABASE_USER" -c "DROP DATABASE IF EXISTS $DATABASE_NAME;" postgres
    
    log "Creating new database..."
    docker-compose exec -T postgres psql -U "$DATABASE_USER" -c "CREATE DATABASE $DATABASE_NAME;" postgres
    
    # Restore from backup
    log "Restoring database from backup..."
    if gunzip -c "$backup_file" | docker-compose exec -T postgres psql -U "$DATABASE_USER" -d "$DATABASE_NAME"; then
        success "Database restored successfully from SQL backup"
    else
        error "Failed to restore database from SQL backup"
    fi
}

# Restore from binary backup
restore_binary_backup() {
    local backup_file="$1"
    local dry_run="$2"
    local temp_dir="/tmp/ibit_restore_$$"
    
    log "Restoring from binary backup..."
    
    if [ "$dry_run" = "true" ]; then
        log "DRY RUN: Would restore from $backup_file"
        return 0
    fi
    
    # Create temporary directory
    mkdir -p "$temp_dir"
    
    # Extract backup
    log "Extracting binary backup..."
    if tar -xzf "$backup_file" -C "$temp_dir"; then
        success "Binary backup extracted"
    else
        error "Failed to extract binary backup"
    fi
    
    # Drop and recreate database
    log "Dropping existing database..."
    docker-compose exec -T postgres psql -U "$DATABASE_USER" -c "DROP DATABASE IF EXISTS $DATABASE_NAME;" postgres
    
    log "Creating new database..."
    docker-compose exec -T postgres psql -U "$DATABASE_USER" -c "CREATE DATABASE $DATABASE_NAME;" postgres
    
    # Restore from binary dump
    log "Restoring database from binary dump..."
    if docker-compose exec -T postgres pg_restore -U "$DATABASE_USER" -d "$DATABASE_NAME" --verbose --clean --no-owner --no-privileges "$temp_dir/dump.sql"; then
        success "Database restored successfully from binary backup"
    else
        error "Failed to restore database from binary backup"
    fi
    
    # Cleanup
    rm -rf "$temp_dir"
}

# Verify restore
verify_restore() {
    local dry_run="$1"
    
    if [ "$dry_run" = "true" ]; then
        log "DRY RUN: Would verify database restore"
        return 0
    fi
    
    log "Verifying database restore..."
    
    # Check if database exists and has tables
    local table_count=$(docker-compose exec -T postgres psql -U "$DATABASE_USER" -d "$DATABASE_NAME" -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" | tr -d ' ')
    
    if [ "$table_count" -gt 0 ]; then
        success "Database restore verified ($table_count tables found)"
    else
        error "Database restore verification failed (no tables found)"
    fi
    
    # Check user count
    local user_count=$(docker-compose exec -T postgres psql -U "$DATABASE_USER" -d "$DATABASE_NAME" -t -c "SELECT COUNT(*) FROM users;" | tr -d ' ')
    echo "  Users in database: $user_count"
    
    # Check customer count
    local customer_count=$(docker-compose exec -T postgres psql -U "$DATABASE_USER" -d "$DATABASE_NAME" -t -c "SELECT COUNT(*) FROM customers;" | tr -d ' ')
    echo "  Customers in database: $customer_count"
}

# Main restore function
main() {
    local backup_file="$1"
    local force="$2"
    local dry_run="$3"
    
    # Check if backup file is provided
    if [ -z "$backup_file" ]; then
        error "Backup file is required"
    fi
    
    log "Starting database restore process..."
    
    # Validate backup file
    validate_backup_file "$backup_file"
    
    # Get backup info
    get_backup_info "$backup_file"
    
    # Check if Docker is running
    if ! docker-compose ps | grep -q "Up"; then
        error "Docker containers are not running"
    fi
    
    # Confirm restore (unless --force or --dry-run)
    if [ "$force" != "--force" ] && [ "$dry_run" != "--dry-run" ]; then
        warning "This will DROP and recreate the database!"
        warning "All current data will be lost!"
        echo ""
        read -p "Are you sure you want to continue? (yes/no): " confirm
        
        if [ "$confirm" != "yes" ]; then
            log "Restore cancelled by user"
            exit 0
        fi
    fi
    
    # Create pre-restore backup (unless dry run)
    local pre_backup_file=""
    if [ "$dry_run" != "--dry-run" ]; then
        pre_backup_file=$(create_pre_restore_backup)
    fi
    
    # Restore based on file type
    if [[ "$backup_file" == *.gz ]]; then
        restore_sql_backup "$backup_file" "$dry_run"
    elif [[ "$backup_file" == *.tar.gz ]]; then
        restore_binary_backup "$backup_file" "$dry_run"
    fi
    
    # Verify restore
    verify_restore "$dry_run"
    
    if [ "$dry_run" = "--dry-run" ]; then
        success "Dry run completed successfully!"
    else
        success "Database restore completed successfully!"
        if [ -n "$pre_backup_file" ]; then
            log "Pre-restore backup saved at: $pre_backup_file"
        fi
    fi
}

# Parse arguments
case "$1" in
    --help)
        usage
        exit 0
        ;;
    *)
        main "$1" "$2" "$3"
        ;;
esac
