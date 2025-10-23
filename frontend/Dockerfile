# Dockerfile สำหรับ Frontend (Production)
# ไฟล์นี้ใช้สำหรับสร้าง Docker image ของ Next.js

# ========================================
# Stage 1: Dependencies
# ========================================
FROM node:20-alpine AS deps

# ติดตั้ง libc6-compat สำหรับความเข้ากันได้
RUN apk add --no-cache libc6-compat

WORKDIR /app

# Copy package files
COPY package*.json ./

# ติดตั้ง dependencies
RUN npm install --no-audit --no-fund --prefer-offline

# ========================================
# Stage 2: Builder
# ========================================
FROM node:20-alpine AS builder

WORKDIR /app

# Copy dependencies จาก deps stage
COPY --from=deps /app/node_modules ./node_modules

# Copy source code
COPY . .

# Set environment สำหรับ build
ENV NEXT_TELEMETRY_DISABLED 1

# Build Next.js application
# Output จะอยู่ใน .next folder
RUN npm run build

# ========================================
# Stage 3: Production
# ========================================
FROM node:20-alpine AS runner

WORKDIR /app

# ติดตั้ง dumb-init สำหรับ signal handling
RUN apk add --no-cache dumb-init

# Set environment
ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1

# สร้าง user ที่ไม่ใช่ root เพื่อความปลอดภัย
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Copy public folder
COPY --from=builder /app/public ./public

# Copy standalone server files
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

# Switch to nextjs user
USER nextjs

# Expose port
EXPOSE 3000

# Set port ที่ Next.js จะใช้
ENV PORT 3000
ENV HOSTNAME "0.0.0.0"

# Start server with dumb-init to handle signals properly
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "server.js"]

