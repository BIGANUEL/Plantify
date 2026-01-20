import mongoose, { Schema, Document } from 'mongoose';

export interface IExplorePlant extends Document {
  name: string;
  scientificName: string;
  category: string;
  difficulty: 'Easy' | 'Moderate' | 'Difficult';
  light: string;
  water: string;
  description: string;
  tags: string[];
  icon?: string;
  imageUrl?: string;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

const ExplorePlantSchema = new Schema<IExplorePlant>(
  {
    name: {
      type: String,
      required: true,
      trim: true,
      unique: true,
    },
    scientificName: {
      type: String,
      required: true,
      trim: true,
    },
    category: {
      type: String,
      required: true,
      enum: ['Indoor', 'Outdoor', 'Low Maintenance', 'Pet Safe', 'Flowering'],
      trim: true,
    },
    difficulty: {
      type: String,
      required: true,
      enum: ['Easy', 'Moderate', 'Difficult'],
      default: 'Easy',
    },
    light: {
      type: String,
      required: true,
      trim: true,
    },
    water: {
      type: String,
      required: true,
      trim: true,
    },
    description: {
      type: String,
      required: true,
      trim: true,
    },
    tags: {
      type: [String],
      default: [],
    },
    icon: {
      type: String,
      trim: true,
    },
    imageUrl: {
      type: String,
      trim: true,
    },
    isActive: {
      type: Boolean,
      default: true,
    },
  },
  {
    timestamps: true,
  }
);

// Indexes
ExplorePlantSchema.index({ category: 1, isActive: 1 });
ExplorePlantSchema.index({ name: 'text', scientificName: 'text', description: 'text' });

export const ExplorePlant = mongoose.model<IExplorePlant>('ExplorePlant', ExplorePlantSchema);
