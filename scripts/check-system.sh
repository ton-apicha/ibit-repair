#!/bin/bash

# ========================================
# System Requirements Check Script
# ตรวจสอบความพร้อมของระบบสำหรับ Production Deployment
# ========================================

set -e

echo "🔍 กำลังตรวจสอบความพร้อมของระบบ..."

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

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    print_status "WARN" "กำลังรันด้วย root user - แนะนำให้สร้าง user ใหม่สำหรับ production"
fi

# Check OS
echo ""
echo "📋 ตรวจสอบระบบปฏิบัติการ..."
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    print_status "OK" "ระบบปฏิบัติการ: Linux"
    
    # Check if it's Debian/Ubuntu
    if [ -f /etc/debian_version ]; then
        DEBIAN_VERSION=$(cat /etc/debian_version)
        print_status "OK" "Debian/Ubuntu version: $DEBIAN_VERSION"
    else
        print_status "WARN" "ไม่ใช่ Debian/Ubuntu - อาจต้องปรับแต่งคำสั่งบางตัว"
    fi
else
    print_status "ERROR" "ระบบปฏิบัติการไม่รองรับ - ต้องการ Linux"
    exit 1
fi

# Check available disk space
echo ""
echo "💾 ตรวจสอบพื้นที่ดิสก์..."
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -lt 80 ]; then
    print_status "OK" "พื้นที่ดิสก์เหลือ: $((100-DISK_USAGE))%"
else
    print_status "WARN" "พื้นที่ดิสก์เหลือน้อย: $((100-DISK_USAGE))%"
fi

# Check available memory
echo ""
echo "🧠 ตรวจสอบหน่วยความจำ..."
TOTAL_MEM=$(free -m | awk 'NR==2{print $2}')
AVAIL_MEM=$(free -m | awk 'NR==2{print $7}')
if [ "$TOTAL_MEM" -ge 2048 ]; then
    print_status "OK" "หน่วยความจำทั้งหมด: ${TOTAL_MEM}MB, เหลือ: ${AVAIL_MEM}MB"
else
    print_status "WARN" "หน่วยความจำน้อยกว่า 2GB: ${TOTAL_MEM}MB"
fi

# Check Docker installation
echo ""
echo "🐳 ตรวจสอบ Docker..."
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version | cut -d' ' -f3 | cut -d',' -f1)
    print_status "OK" "Docker version: $DOCKER_VERSION"
    
    # Check Docker Compose
    if command -v docker-compose &> /dev/null; then
        COMPOSE_VERSION=$(docker-compose --version | cut -d' ' -f3 | cut -d',' -f1)
        print_status "OK" "Docker Compose version: $COMPOSE_VERSION"
    else
        print_status "ERROR" "Docker Compose ไม่ได้ติดตั้ง"
        exit 1
    fi
    
    # Check if Docker daemon is running
    if docker info &> /dev/null; then
        print_status "OK" "Docker daemon กำลังทำงาน"
    else
        print_status "ERROR" "Docker daemon ไม่ทำงาน"
        exit 1
    fi
else
    print_status "ERROR" "Docker ไม่ได้ติดตั้ง"
    exit 1
fi

# Check required ports
echo ""
echo "🔌 ตรวจสอบ ports ที่ต้องการ..."
REQUIRED_PORTS=(80 443 3000 4000 5432 6379)
for port in "${REQUIRED_PORTS[@]}"; do
    if netstat -tuln | grep -q ":$port "; then
        print_status "WARN" "Port $port ถูกใช้งานแล้ว"
    else
        print_status "OK" "Port $port ว่าง"
    fi
done

# Check firewall status
echo ""
echo "🔥 ตรวจสอบ Firewall..."
if command -v ufw &> /dev/null; then
    UFW_STATUS=$(ufw status | head -1)
    if [[ "$UFW_STATUS" == *"active"* ]]; then
        print_status "INFO" "UFW Firewall เปิดอยู่"
        print_status "INFO" "จะต้องเปิด ports: 80, 443, 22"
    else
        print_status "WARN" "UFW Firewall ปิดอยู่ - แนะนำให้เปิด"
    fi
else
    print_status "INFO" "UFW ไม่ได้ติดตั้ง - ตรวจสอบ iptables หรือ firewall อื่น"
fi

# Check system updates
echo ""
echo "🔄 ตรวจสอบการอัพเดตระบบ..."
if command -v apt &> /dev/null; then
    UPDATES=$(apt list --upgradable 2>/dev/null | wc -l)
    if [ "$UPDATES" -gt 1 ]; then
        print_status "WARN" "มี $((UPDATES-1)) packages ที่ต้องอัพเดต"
        print_status "INFO" "รัน: sudo apt update && sudo apt upgrade"
    else
        print_status "OK" "ระบบอัพเดตล่าสุดแล้ว"
    fi
fi

# Check required directories
echo ""
echo "📁 ตรวจสอบ directories ที่ต้องการ..."
REQUIRED_DIRS=("./uploads" "./backups" "./logs" "./ssl")
for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        print_status "OK" "Directory $dir มีอยู่แล้ว"
    else
        print_status "INFO" "จะสร้าง directory $dir"
        mkdir -p "$dir"
    fi
done

# Check .env file
echo ""
echo "⚙️  ตรวจสอบ Environment Configuration..."
if [ -f ".env" ]; then
    print_status "OK" "ไฟล์ .env มีอยู่แล้ว"
    
    # Check required environment variables
    REQUIRED_VARS=("DB_PASSWORD" "JWT_SECRET" "SESSION_SECRET" "SERVER_IP")
    for var in "${REQUIRED_VARS[@]}"; do
        if grep -q "^${var}=" .env && ! grep -q "^${var}=CHANGE_THIS" .env; then
            print_status "OK" "Environment variable $var ถูกตั้งค่าแล้ว"
        else
            print_status "ERROR" "Environment variable $var ไม่ได้ตั้งค่าหรือยังเป็นค่า default"
        fi
    done
else
    print_status "ERROR" "ไฟล์ .env ไม่มี - สร้างจาก env.production.template"
    exit 1
fi

# Final summary
echo ""
echo "=========================================="
echo "📊 สรุปผลการตรวจสอบ"
echo "=========================================="

if [ "$DISK_USAGE" -lt 80 ] && [ "$TOTAL_MEM" -ge 2048 ] && [ -f ".env" ]; then
    print_status "OK" "ระบบพร้อมสำหรับ Production Deployment!"
    echo ""
    echo "🚀 ขั้นตอนถัดไป:"
    echo "1. ปรับแต่งไฟล์ .env ให้เหมาะสม"
    echo "2. รัน: ./deploy.sh"
    echo "3. ตรวจสอบการทำงาน: ./scripts/health-check.sh"
else
    print_status "ERROR" "ระบบยังไม่พร้อม - กรุณาแก้ไขปัญหาข้างต้น"
    exit 1
fi
