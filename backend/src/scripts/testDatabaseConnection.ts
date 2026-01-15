import mongoose from 'mongoose';
import { connectDatabase } from '../config/database';
import { env } from '../config/env';

/**
 * Simple script to test the MongoDB connection and log:
 * - Database name
 * - Whether it's likely Local or Atlas
 * - List of collections
 *
 * Run (from backend directory, compiled or via ts-node):
 *   ts-node src/scripts/testDatabaseConnection.ts
 * or the corresponding npm script if added.
 */
const run = async () => {
  try {
    await connectDatabase();

    const connection = mongoose.connection;
    const uri = env.mongodbUri;

    const isAtlas =
      uri.includes('mongodb+srv://') || uri.includes('mongodb.net');

    console.log('([DB TEST] ========= MongoDB connection details)');
    console.log(
      `([DB TEST] Type: ${isAtlas ? 'MongoDB Atlas (cloud)' : 'Local / self-hosted MongoDB'})`,
    );
    console.log(`([DB TEST] Database name: ${connection.name})`);

    // In Mongoose 8 typings, `connection.db` can be nullable, so guard it
    const db = connection.db;
    if (!db) {
      console.error(
        '([DB TEST ERROR] ========= connection.db is not available. Is MongoDB connected?)',
      );
      return;
    }

    const collections = await db.listCollections().toArray();

    if (!collections.length) {
      console.log('([DB TEST] No collections found in this database)');
    } else {
      console.log('([DB TEST] Collections:)');
      collections.forEach((c) =>
        console.log(`([DB TEST]  - ${c.name})`),
      );
    }
  } catch (error) {
    console.error(
      '([DB TEST ERROR] ========= Failed to test MongoDB connection)',
      error,
    );
  } finally {
    await mongoose.disconnect();
    process.exit(0);
  }
};

run();


