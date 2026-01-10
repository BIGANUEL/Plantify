import app from './app';
import { connectDatabase } from './config/database';
import { env } from './config/env';

const startServer = async (): Promise<void> => {
  try {
    // Connect to database
    await connectDatabase();

    // Start server
    const port = env.port;
    app.listen(port, () => {
      console.log(`([LOG server_start] ========= Server running on port ${port} in ${env.nodeEnv} mode)`);
    });
  } catch (error) {
    console.error('([LOG server_error] ========= Failed to start server:', error);
    process.exit(1);
  }
};

startServer();

