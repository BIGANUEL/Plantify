import mongoose, { Schema, Document } from 'mongoose';

export interface IProblem extends Document {
  name: string;
  category: string;
  description: string;
  severity: 'Mild' | 'Moderate' | 'Severe';
  treatmentDifficulty: 'Easy' | 'Moderate' | 'Difficult';
  commonCauses: string[];
  solutions: string[];
  prevention: string;
  affectedPlants: string[];
  icon?: string;
  color?: string;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

const ProblemSchema = new Schema<IProblem>(
  {
    name: {
      type: String,
      required: true,
      trim: true,
      unique: true,
    },
    category: {
      type: String,
      required: true,
      enum: ['Pests', 'Diseases', 'Environmental', 'Nutrition', 'Watering'],
      trim: true,
    },
    description: {
      type: String,
      required: true,
      trim: true,
    },
    severity: {
      type: String,
      required: true,
      enum: ['Mild', 'Moderate', 'Severe'],
      default: 'Moderate',
    },
    treatmentDifficulty: {
      type: String,
      required: true,
      enum: ['Easy', 'Moderate', 'Difficult'],
      default: 'Moderate',
    },
    commonCauses: {
      type: [String],
      default: [],
    },
    solutions: {
      type: [String],
      required: true,
      default: [],
    },
    prevention: {
      type: String,
      required: true,
      trim: true,
    },
    affectedPlants: {
      type: [String],
      default: [],
    },
    icon: {
      type: String,
      trim: true,
    },
    color: {
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
ProblemSchema.index({ category: 1, isActive: 1 });
ProblemSchema.index({ name: 'text', description: 'text' });

export const Problem = mongoose.model<IProblem>('Problem', ProblemSchema);
