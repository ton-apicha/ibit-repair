# Dockerfile สำหรับ Backend (Production)
# ไฟล์นี้ใช้สำหรับสร้าง Docker image ของ Backend API

# ========================================
# Stage 1: Build
# ========================================
FROM node:20-alpine AS builder

# ตั้งค่า working directory
WORKDIR /app

# Copy package files
COPY package*.json ./
COPY prisma ./prisma/

# ติดตั้ง dependencies
RUN npm ci

# Copy source code
COPY . .

# Generate Prisma Client
RUN npx prisma generate

# Build TypeScript เป็น JavaScript
RUN npm run build

# ========================================
# Stage 2: Production
# ========================================
FROM node:20-alpine

# ติดตั้ง dependencies ที่จำเป็น
RUN apk add --no-cache curl dumb-init

# สร้าง user ที่ไม่ใช่ root เพื่อความปลอดภัย
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 ibit

# ตั้งค่า working directory
WORKDIR /app

# Copy package files
COPY package*.json ./
COPY prisma ./prisma/

# ติดตั้งเฉพาะ production dependencies
RUN npm ci --only=production && npm cache clean --force

# Copy built files และ Prisma client จาก builder stage
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules/.prisma ./node_modules/.prisma

# สร้างโฟลเดอร์สำหรับ uploads และ backups
RUN mkdir -p uploads backups logs && \
    chown -R ibit:nodejs /app

# Set environment
ENV NODE_ENV=production

# Change to non-root user
USER ibit

# Expose port
EXPOSE 4000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:4000/health || exit 1

# Start server with dumb-init to handle signals properly
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "dist/server.js"]

