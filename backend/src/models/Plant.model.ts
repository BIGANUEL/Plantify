import mongoose, { Schema, Document } from 'mongoose';

export interface IPlant extends Document {
  userId: mongoose.Types.ObjectId;
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

const PlantSchema = new Schema<IPlant>(
  {
    userId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    name: {
      type: String,
      required: true,
      trim: true,
    },
    type: {
      type: String,
      required: true,
      trim: true,
    },
    careInstructions: {
      type: String,
      trim: true,
    },
    wateringFrequency: {
      type: Number,
      default: 7,
      min: 1,
    },
    lastWatered: {
      type: Date,
    },
    nextWatering: {
      type: Date,
    },
    imageUrl: {
      type: String,
      trim: true,
    },
  },
  {
    timestamps: true,
  }
);

// Index for faster queries
PlantSchema.index({ userId: 1 });
PlantSchema.index({ userId: 1, createdAt: -1 });

// Calculate nextWatering before saving
PlantSchema.pre('save', function (next) {
  if (this.lastWatered && this.wateringFrequency) {
    const nextWateringDate = new Date(this.lastWatered);
    nextWateringDate.setDate(nextWateringDate.getDate() + this.wateringFrequency);
    this.nextWatering = nextWateringDate;
  }
  next();
});

export const Plant = mongoose.model<IPlant>('Plant', PlantSchema);

