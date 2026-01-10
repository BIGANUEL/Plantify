export interface CreatePlantRequest {
  name: string;
  type: string;
  careInstructions?: string;
  wateringFrequency?: number;
  imageUrl?: string;
}

export interface UpdatePlantRequest {
  name?: string;
  type?: string;
  careInstructions?: string;
  wateringFrequency?: number;
  imageUrl?: string;
}

export interface PlantResponse {
  id: string;
  name: string;
  type: string;
  careInstructions?: string;
  wateringFrequency: number;
  lastWatered?: Date;
  nextWatering?: Date;
  imageUrl?: string;
  createdAt: Date;
  updatedAt: Date;
}

