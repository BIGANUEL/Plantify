import mongoose from 'mongoose';
import { env } from './env';

export const connectDatabase = async (): Promise<void> => {
  try {
    await mongoose.connect(env.mongodbUri);
    console.log('([LOG db_connection] ========= Connected to MongoDB)');
  } catch (error: any) {
    console.error('([LOG db_error] ========= MongoDB connection error:', error.message);
    console.error('([LOG db_info] ========= Make sure MongoDB is running or update MONGODB_URI in .env file)');
    process.exit(1);
  }
};

// Handle connection events
mongoose.connection.on('disconnected', () => {
  console.log('([LOG db_disconnected] ========= MongoDB disconnected)');
});

mongoose.connection.on('error', (error) => {
  console.error('([LOG db_error] ========= MongoDB error:', error);
});

