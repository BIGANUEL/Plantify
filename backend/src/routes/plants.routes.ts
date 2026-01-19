import { Router } from 'express';
import { body } from 'express-validator';
import { validateRequest } from '../utils/validation.util';
import {
  getPlants,
  getPlantById,
  createPlant,
  updatePlant,
  deletePlant,
  waterPlant,
} from '../controllers/plants.controller';
import { authenticate } from '../middleware/auth.middleware';

const router = Router();

// All routes require authentication
router.use(authenticate);

/**
 * @swagger
 * /api/plants:
 *   get:
 *     summary: Get all plants for the authenticated user
 *     tags: [Plants]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of plants retrieved successfully
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
 *                         $ref: '#/components/schemas/Plant'
 *       401:
 *         description: Unauthorized
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.get('/', getPlants as any);

/**
 * @swagger
 * /api/plants/{id}:
 *   get:
 *     summary: Get a specific plant by ID
 *     tags: [Plants]
 *     security:
 *       - bearerAuth: []
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
 *                     plant:
 *                       $ref: '#/components/schemas/Plant'
 *       404:
 *         description: Plant not found
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       401:
 *         description: Unauthorized
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.get('/:id', getPlantById as any);

/**
 * @swagger
 * /api/plants:
 *   post:
 *     summary: Create a new plant
 *     tags: [Plants]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - name
 *               - type
 *             properties:
 *               name:
 *                 type: string
 *                 example: Monstera Deliciosa
 *               type:
 *                 type: string
 *                 example: Indoor
 *               careInstructions:
 *                 type: string
 *                 example: Water weekly, indirect sunlight
 *               wateringFrequency:
 *                 type: number
 *                 minimum: 1
 *                 example: 7
 *               imageUrl:
 *                 type: string
 *                 format: uri
 *                 example: https://example.com/image.jpg
 *     responses:
 *       201:
 *         description: Plant created successfully
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
 *                     plant:
 *                       $ref: '#/components/schemas/Plant'
 *       400:
 *         description: Validation error
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       401:
 *         description: Unauthorized
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.post(
  '/',
  [
    body('name').trim().notEmpty().withMessage('Plant name is required'),
    body('type').trim().notEmpty().withMessage('Plant type is required'),
    body('careInstructions').optional().trim(),
    body('wateringFrequency').optional().isInt({ min: 1 }).withMessage('Watering frequency must be a positive number'),
    body('imageUrl').optional().isURL().withMessage('Image URL must be a valid URL'),
    body('nextWatering').optional().isISO8601().withMessage('Next watering date must be a valid ISO 8601 date'),
  ],
  validateRequest,
  createPlant as any
);

/**
 * @swagger
 * /api/plants/{id}:
 *   put:
 *     summary: Update a plant
 *     tags: [Plants]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Plant ID
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *                 example: Updated Plant Name
 *               type:
 *                 type: string
 *                 example: Outdoor
 *               careInstructions:
 *                 type: string
 *                 example: Updated care instructions
 *               wateringFrequency:
 *                 type: number
 *                 minimum: 1
 *                 example: 5
 *               imageUrl:
 *                 type: string
 *                 format: uri
 *                 example: https://example.com/new-image.jpg
 *     responses:
 *       200:
 *         description: Plant updated successfully
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
 *                     plant:
 *                       $ref: '#/components/schemas/Plant'
 *       404:
 *         description: Plant not found
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       401:
 *         description: Unauthorized
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.put(
  '/:id',
  [
    body('name').optional().trim().notEmpty().withMessage('Plant name cannot be empty'),
    body('type').optional().trim().notEmpty().withMessage('Plant type cannot be empty'),
    body('careInstructions').optional().trim(),
    body('wateringFrequency').optional().isInt({ min: 1 }).withMessage('Watering frequency must be a positive number'),
    body('imageUrl').optional().isURL().withMessage('Image URL must be a valid URL'),
  ],
  validateRequest,
  updatePlant as any
);

/**
 * @swagger
 * /api/plants/{id}:
 *   delete:
 *     summary: Delete a plant
 *     tags: [Plants]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Plant ID
 *     responses:
 *       200:
 *         description: Plant deleted successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 message:
 *                   type: string
 *       404:
 *         description: Plant not found
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       401:
 *         description: Unauthorized
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.delete('/:id', deletePlant as any);

/**
 * @swagger
 * /api/plants/{id}/water:
 *   post:
 *     summary: Mark a plant as watered
 *     tags: [Plants]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Plant ID
 *     responses:
 *       200:
 *         description: Plant marked as watered successfully
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
 *                     plant:
 *                       type: object
 *                       properties:
 *                         id:
 *                           type: string
 *                         name:
 *                           type: string
 *                         lastWatered:
 *                           type: string
 *                           format: date-time
 *                         nextWatering:
 *                           type: string
 *                           format: date-time
 *       404:
 *         description: Plant not found
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       401:
 *         description: Unauthorized
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.post('/:id/water', waterPlant as any);

export default router;

