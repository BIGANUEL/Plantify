export interface CreatePlantRequest {
  name: string;
  type: string;
  careInstructions?: string;
  wateringFrequency?: number;
  light?: string;
  humidity?: string;
  nextWatering?: string; // ISO 8601 date string
}

export interface UpdatePlantRequest {
  name?: string;
  type?: string;
  careInstructions?: string;
  wateringFrequency?: number;
  light?: string;
  humidity?: string;
}

export interface PlantResponse {
  id: string;
  name: string;
  type: string;
  careInstructions?: string;
  wateringFrequency: number;
  lastWatered?: Date;
  nextWatering?: Date;
  light?: string;
  humidity?: string;
  createdAt: Date;
  updatedAt: Date;
}

