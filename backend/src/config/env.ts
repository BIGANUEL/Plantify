import dotenv from 'dotenv';

dotenv.config();

export const env = {
  port: process.env.PORT ? parseInt(process.env.PORT, 10) : 5001,
  nodeEnv: process.env.NODE_ENV || 'development',
  mongodbUri: process.env.MONGODB_URI || 'mongodb://localhost:27017/plantify',
  jwtSecret: process.env.JWT_SECRET || 'default-secret-change-in-production',
  jwtAccessExpiry: process.env.JWT_ACCESS_EXPIRY || '15m',
  jwtRefreshExpiry: process.env.JWT_REFRESH_EXPIRY || '7d',
  corsOrigin: process.env.CORS_ORIGIN || 'http://localhost:3000',
};

// Validate required environment variables
if (!env.mongodbUri) {
  console.error('([LOG env_error] ========= MONGODB_URI is required)');
  process.exit(1);
}

if (!env.jwtSecret || env.jwtSecret === 'default-secret-change-in-production') {
  console.warn('([LOG env_warning] ========= Using default JWT_SECRET. Change in production!)');
}

