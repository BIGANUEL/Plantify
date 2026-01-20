import { Router } from 'express';
import {
  getExplorePlants,
  getExplorePlantById,
  getProblems,
  getProblemById,
  seedExploreData,
} from '../controllers/explore.controller';

const router = Router();

/**
 * @swagger
 * /api/explore/plants:
 *   get:
 *     summary: Get all explore plants (public catalog)
 *     tags: [Explore]
 *     parameters:
 *       - in: query
 *         name: category
 *         schema:
 *           type: string
 *           enum: [All, Indoor, Outdoor, Low Maintenance, Pet Safe, Flowering]
 *         description: Filter by category
 *       - in: query
 *         name: search
 *         schema:
 *           type: string
 *         description: Search query
 *     responses:
 *       200:
 *         description: List of explore plants
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   type: object
 *                   properties:
 *                     plants:
 *                       type: array
 *                       items:
 *                         type: object
 */
router.get('/plants', getExplorePlants as any);

/**
 * @swagger
 * /api/explore/plants/{id}:
 *   get:
 *     summary: Get a specific explore plant by ID
 *     tags: [Explore]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Plant ID
 *     responses:
 *       200:
 *         description: Plant retrieved successfully
 *       404:
 *         description: Plant not found
 */
router.get('/plants/:id', getExplorePlantById as any);

/**
 * @swagger
 * /api/explore/problems:
 *   get:
 *     summary: Get all plant problems
 *     tags: [Explore]
 *     parameters:
 *       - in: query
 *         name: category
 *         schema:
 *           type: string
 *           enum: [All, Pests, Diseases, Environmental, Nutrition, Watering]
 *         description: Filter by category
 *       - in: query
 *         name: search
 *         schema:
 *           type: string
 *         description: Search query
 *     responses:
 *       200:
 *         description: List of problems
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   type: object
 *                   properties:
 *                     problems:
 *                       type: array
 *                       items:
 *                         type: object
 */
router.get('/problems', getProblems as any);

/**
 * @swagger
 * /api/explore/problems/{id}:
 *   get:
 *     summary: Get a specific problem by ID
 *     tags: [Explore]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Problem ID
 *     responses:
 *       200:
 *         description: Problem retrieved successfully
 *       404:
 *         description: Problem not found
 */
router.get('/problems/:id', getProblemById as any);

/**
 * Admin endpoint to seed explore data
 */
router.post('/seed', seedExploreData as any);

export default router;
