import { Request, Response, NextFunction } from 'express';
import { ExploreService } from '../services/explore.service';

const exploreService = new ExploreService();

/**
 * Get all explore plants (public endpoint - no auth required)
 */
export const getExplorePlants = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const category = req.query.category as string | undefined;
    const search = req.query.search as string | undefined;

    const plants = await exploreService.getExplorePlants(category, search);

    res.status(200).json({
      success: true,
      data: {
        plants: plants.map((plant) => ({
          id: plant._id.toString(),
          name: plant.name,
          scientificName: plant.scientificName,
          category: plant.category,
          difficulty: plant.difficulty,
          light: plant.light,
          water: plant.water,
          description: plant.description,
          tags: plant.tags,
          icon: plant.icon,
          imageUrl: plant.imageUrl,
        })),
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Get a specific explore plant by ID
 */
export const getExplorePlantById = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;

    const plant = await exploreService.getExplorePlantById(id);

    if (!plant) {
      res.status(404).json({
        success: false,
        error: {
          message: 'Plant not found',
          code: 'PLANT_NOT_FOUND',
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
          scientificName: plant.scientificName,
          category: plant.category,
          difficulty: plant.difficulty,
          light: plant.light,
          water: plant.water,
          description: plant.description,
          tags: plant.tags,
          icon: plant.icon,
          imageUrl: plant.imageUrl,
        },
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Get all problems (public endpoint - no auth required)
 */
export const getProblems = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const category = req.query.category as string | undefined;
    const search = req.query.search as string | undefined;

    const problems = await exploreService.getProblems(category, search);

    res.status(200).json({
      success: true,
      data: {
        problems: problems.map((problem) => ({
          id: problem._id.toString(),
          name: problem.name,
          category: problem.category,
          description: problem.description,
          severity: problem.severity,
          treatmentDifficulty: problem.treatmentDifficulty,
          commonCauses: problem.commonCauses,
          solutions: problem.solutions,
          prevention: problem.prevention,
          affectedPlants: problem.affectedPlants,
          icon: problem.icon,
          color: problem.color,
        })),
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Get a specific problem by ID
 */
export const getProblemById = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;

    const problem = await exploreService.getProblemById(id);

    if (!problem) {
      res.status(404).json({
        success: false,
        error: {
          message: 'Problem not found',
          code: 'PROBLEM_NOT_FOUND',
        },
      });
      return;
    }

    res.status(200).json({
      success: true,
      data: {
        problem: {
          id: problem._id.toString(),
          name: problem.name,
          category: problem.category,
          description: problem.description,
          severity: problem.severity,
          treatmentDifficulty: problem.treatmentDifficulty,
          commonCauses: problem.commonCauses,
          solutions: problem.solutions,
          prevention: problem.prevention,
          affectedPlants: problem.affectedPlants,
          icon: problem.icon,
          color: problem.color,
        },
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Seed explore data (admin endpoint - can be called once to populate database)
 */
export const seedExploreData = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    await exploreService.seedExplorePlants();
    await exploreService.seedProblems();

    res.status(200).json({
      success: true,
      message: 'Explore data seeded successfully',
    });
  } catch (error) {
    next(error);
  }
};
