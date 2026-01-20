import { Router } from 'express';
import authRoutes from './auth.routes';
import plantsRoutes from './plants.routes';
import exploreRoutes from './explore.routes';

const router = Router();

router.use('/auth', authRoutes);
router.use('/plants', plantsRoutes);
router.use('/explore', exploreRoutes);

export default router;

