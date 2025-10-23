/**
 * Database Configuration
 * จัดการการตั้งค่าการเชื่อมต่อฐานข้อมูล
 */

import { config } from './index';
import { PrismaClient } from '@prisma/client';

/**
 * Database connection configuration
 */
export const databaseConfig = {
  url: config.database.url,
  poolMin: config.database.poolMin,
  poolMax: config.database.poolMax,
  poolIdle: config.database.poolIdle,
};

/**
 * Prisma Client configuration
 */
export const prismaConfig = {
  datasources: {
    db: {
      url: config.database.url,
    },
  },
  log: config.development.debug ? ['query', 'info', 'warn', 'error'] : ['error'],
  errorFormat: 'pretty' as const,
};

/**
 * Database health check
 */
export const checkDatabaseConnection = async (): Promise<boolean> => {
  try {
    const prisma = new PrismaClient();
    await prisma.$connect();
    await prisma.$disconnect();
    return true;
  } catch (error) {
    console.error('❌ Database connection failed:', error);
    return false;
  }
};

/**
 * Database connection pool monitoring
 */
export const getDatabaseStats = async () => {
  try {
    const prisma = new PrismaClient();
    
    // Get basic database info
    const result = await prisma.$queryRaw`
      SELECT 
        current_database() as database_name,
        version() as version,
        current_user as current_user,
        inet_server_addr() as server_address,
        inet_server_port() as server_port
    `;
    
    await prisma.$disconnect();
    return result;
  } catch (error) {
    console.error('❌ Failed to get database stats:', error);
    return null;
  }
};

export default databaseConfig;
