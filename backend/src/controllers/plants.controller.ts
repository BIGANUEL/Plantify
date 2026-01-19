import { Response, NextFunction } from 'express';
import { PlantsService } from '../services/plants.service';
import { AuthRequest } from '../middleware/auth.middleware';
import { CreatePlantRequest, UpdatePlantRequest } from '../types/plants.types';

const plantsService = new PlantsService();

export const getPlants = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    if (!req.user) {
      res.status(401).json({
        success: false,
        error: {
          message: 'Authentication required',
          code: 'UNAUTHORIZED',
        },
      });
      return;
    }

    const plants = await plantsService.getPlants(req.user.userId);

    res.status(200).json({
      success: true,
      data: {
        plants: plants.map((plant) => ({
          id: plant._id.toString(),
          name: plant.name,
          type: plant.type,
          careInstructions: plant.careInstructions,
          wateringFrequency: plant.wateringFrequency,
          lastWatered: plant.lastWatered,
          nextWatering: plant.nextWatering,
          imageUrl: plant.imageUrl,
          light: plant.light,
          humidity: plant.humidity,
          createdAt: plant.createdAt,
          updatedAt: plant.updatedAt,
        })),
      },
    });
  } catch (error) {
    next(error);
  }
};

export const getPlantById = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    if (!req.user) {
      res.status(401).json({
        success: false,
        error: {
          message: 'Authentication required',
          code: 'UNAUTHORIZED',
        },
      });
      return;
    }

    const { id } = req.params;
    const plant = await plantsService.getPlantById(id, req.user.userId);

    if (!plant) {
      res.status(404).json({
        success: false,
        error: {
          message: 'Plant not found',
          code: 'NOT_FOUND',
        },
      });
      return;
    }

    res.status(200).json({
      success: true,
      data: {
        plant: {
          id: plant._id.toString(),
          name: plant.name,
          type: plant.type,
          careInstructions: plant.careInstructions,
          wateringFrequency: plant.wateringFrequency,
          lastWatered: plant.lastWatered,
          nextWatering: plant.nextWatering,
          imageUrl: plant.imageUrl,
          light: plant.light,
          humidity: plant.humidity,
          createdAt: plant.createdAt,
          updatedAt: plant.updatedAt,
        },
      },
    });
  } catch (error) {
    next(error);
  }
};

export const createPlant = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    if (!req.user) {
      res.status(401).json({
        success: false,
        error: {
          message: 'Authentication required',
          code: 'UNAUTHORIZED',
        },
      });
      return;
    }

    const plantData: CreatePlantRequest = req.body;
    const plant = await plantsService.createPlant(req.user.userId, plantData);

    res.status(201).json({
      success: true,
      data: {
        plant: {
          id: plant._id.toString(),
          name: plant.name,
          type: plant.type,
          careInstructions: plant.careInstructions,
          wateringFrequency: plant.wateringFrequency,
          lastWatered: plant.lastWatered,
          nextWatering: plant.nextWatering,
          imageUrl: plant.imageUrl,
          light: plant.light,
          humidity: plant.humidity,
          createdAt: plant.createdAt,
          updatedAt: plant.updatedAt,
        },
      },
    });
  } catch (error) {
    next(error);
  }
};

export const updatePlant = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    if (!req.user) {
      res.status(401).json({
        success: false,
        error: {
          message: 'Authentication required',
          code: 'UNAUTHORIZED',
        },
      });
      return;
    }

    const { id } = req.params;
    const plantData: UpdatePlantRequest = req.body;

    const plant = await plantsService.updatePlant(id, req.user.userId, plantData);

    if (!plant) {
      res.status(404).json({
        success: false,
        error: {
          message: 'Plant not found',
          code: 'NOT_FOUND',
        },
      });
      return;
    }

    res.status(200).json({
      success: true,
      data: {
        plant: {
          id: plant._id.toString(),
          name: plant.name,
          type: plant.type,
          careInstructions: plant.careInstructions,
          wateringFrequency: plant.wateringFrequency,
          lastWatered: plant.lastWatered,
          nextWatering: plant.nextWatering,
          imageUrl: plant.imageUrl,
          light: plant.light,
          humidity: plant.humidity,
          createdAt: plant.createdAt,
          updatedAt: plant.updatedAt,
        },
      },
    });
  } catch (error) {
    next(error);
  }
};

export const deletePlant = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    if (!req.user) {
      res.status(401).json({
        success: false,
        error: {
          message: 'Authentication required',
          code: 'UNAUTHORIZED',
        },
      });
      return;
    }

    const { id } = req.params;
    const deleted = await plantsService.deletePlant(id, req.user.userId);

    if (!deleted) {
      res.status(404).json({
        success: false,
        error: {
          message: 'Plant not found',
          code: 'NOT_FOUND',
        },
      });
      return;
    }

    res.status(200).json({
      success: true,
      message: 'Plant deleted successfully',
    });
  } catch (error) {
    next(error);
  }
};

export const waterPlant = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    if (!req.user) {
      res.status(401).json({
        success: false,
        error: {
          message: 'Authentication required',
          code: 'UNAUTHORIZED',
        },
      });
      return;
    }

    const { id } = req.params;
    // Extract lastWatered timestamp from request body if provided
    let lastWatered: Date | undefined;
    if (req.body?.lastWatered) {
      lastWatered = new Date(req.body.lastWatered);
      // Validate that the date is valid
      if (isNaN(lastWatered.getTime())) {
        res.status(400).json({
          success: false,
          error: {
            message: 'Invalid lastWatered timestamp format',
            code: 'BAD_REQUEST',
          },
        });
        return;
      }
    }
    
    const plant = await plantsService.waterPlant(id, req.user.userId, lastWatered);

    if (!plant) {
      res.status(404).json({
        success: false,
        error: {
          message: 'Plant not found',
          code: 'NOT_FOUND',
        },
      });
      return;
    }

    res.status(200).json({
      success: true,
      data: {
        plant: {
          id: plant._id.toString(),
          name: plant.name,
          type: plant.type,
          careInstructions: plant.careInstructions,
          wateringFrequency: plant.wateringFrequency,
          lastWatered: plant.lastWatered,
          nextWatering: plant.nextWatering,
          imageUrl: plant.imageUrl,
          light: plant.light,
          humidity: plant.humidity,
          createdAt: plant.createdAt,
          updatedAt: plant.updatedAt,
        },
      },
    });
  } catch (error) {
    next(error);
  }
};

