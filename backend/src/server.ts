import app from './app';
import { connectDatabase } from './config/database';
import { env } from './config/env';

const startServer = async (): Promise<void> => {
  try {
    // Connect to database
    await connectDatabase();

    // Auto-seed explore data if database is empty
    const { ExploreService } = await import('./services/explore.service');
    const exploreService = new ExploreService();
    try {
      await exploreService.seedExplorePlants();
      await exploreService.seedProblems();
      console.log('([LOG explore_seed] Explore data seeded successfully)');
    } catch (error) {
      console.error('([LOG explore_seed_error] Failed to seed explore data:', error);
      // Don't fail server startup if seeding fails - it might already be seeded
    }

    // Start server
    const port = env.port;
    // Bind to 0.0.0.0 to allow connections from all network interfaces
    app.listen(port, '0.0.0.0', () => {
      console.log(`([LOG server_start] ========= Server running on port ${port} in ${env.nodeEnv} mode)`);
    });
  } catch (error) {
    console.error('([LOG server_error] ========= Failed to start server:', error);
    process.exit(1);
  }
};

startServer();

