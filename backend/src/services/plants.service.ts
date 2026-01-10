import { Plant, IPlant } from '../models/Plant.model';
import { CreatePlantRequest, UpdatePlantRequest } from '../types/plants.types';
import mongoose from 'mongoose';

export class PlantsService {
  async getPlants(userId: string): Promise<IPlant[]> {
    return Plant.find({ userId: new mongoose.Types.ObjectId(userId) })
      .sort({ createdAt: -1 })
      .exec();
  }

  async getPlantById(plantId: string, userId: string): Promise<IPlant | null> {
    const plant = await Plant.findOne({
      _id: new mongoose.Types.ObjectId(plantId),
      userId: new mongoose.Types.ObjectId(userId),
    }).exec();

    return plant;
  }

  async createPlant(userId: string, plantData: CreatePlantRequest): Promise<IPlant> {
    const plant = new Plant({
      userId: new mongoose.Types.ObjectId(userId),
      name: plantData.name,
      type: plantData.type,
      careInstructions: plantData.careInstructions,
      wateringFrequency: plantData.wateringFrequency || 7,
      imageUrl: plantData.imageUrl,
    });

    await plant.save();
    return plant;
  }

  async updatePlant(
    plantId: string,
    userId: string,
    plantData: UpdatePlantRequest
  ): Promise<IPlant | null> {
    const plant = await Plant.findOne({
      _id: new mongoose.Types.ObjectId(plantId),
      userId: new mongoose.Types.ObjectId(userId),
    });

    if (!plant) {
      return null;
    }

    if (plantData.name !== undefined) plant.name = plantData.name;
    if (plantData.type !== undefined) plant.type = plantData.type;
    if (plantData.careInstructions !== undefined) {
      plant.careInstructions = plantData.careInstructions;
    }
    if (plantData.wateringFrequency !== undefined) {
      plant.wateringFrequency = plantData.wateringFrequency;
    }
    if (plantData.imageUrl !== undefined) plant.imageUrl = plantData.imageUrl;

    await plant.save();
    return plant;
  }

  async deletePlant(plantId: string, userId: string): Promise<boolean> {
    const result = await Plant.deleteOne({
      _id: new mongoose.Types.ObjectId(plantId),
      userId: new mongoose.Types.ObjectId(userId),
    });

    return result.deletedCount > 0;
  }

  async waterPlant(plantId: string, userId: string): Promise<IPlant | null> {
    const plant = await Plant.findOne({
      _id: new mongoose.Types.ObjectId(plantId),
      userId: new mongoose.Types.ObjectId(userId),
    });

    if (!plant) {
      return null;
    }

    plant.lastWatered = new Date();
    // nextWatering will be calculated by the pre-save hook
    await plant.save();

    return plant;
  }
}

