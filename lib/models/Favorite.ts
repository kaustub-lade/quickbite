import mongoose, { Schema, Document } from 'mongoose';

export interface IFavorite extends Document {
  userId: string;
  itemType: 'restaurant' | 'dish';
  itemId: string; // Restaurant ID or Menu Item ID
  itemName: string;
  itemImage?: string;
  restaurantId?: string; // For dishes, store parent restaurant
  restaurantName?: string;
  createdAt: Date;
}

const favoriteSchema = new Schema<IFavorite>({
  userId: {
    type: String,
    required: true,
    index: true,
  },
  itemType: {
    type: String,
    enum: ['restaurant', 'dish'],
    required: true,
  },
  itemId: {
    type: String,
    required: true,
  },
  itemName: {
    type: String,
    required: true,
  },
  itemImage: {
    type: String,
  },
  restaurantId: {
    type: String,
  },
  restaurantName: {
    type: String,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

// Compound index to prevent duplicate favorites
favoriteSchema.index({ userId: 1, itemType: 1, itemId: 1 }, { unique: true });

export const Favorite = mongoose.models.Favorite || mongoose.model<IFavorite>('Favorite', favoriteSchema);
