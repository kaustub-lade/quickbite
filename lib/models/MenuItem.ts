import mongoose from 'mongoose'

export interface IMenuItem {
  _id?: string
  restaurantId: string
  name: string
  description: string
  price: number
  category: string
  isVeg: boolean
  isAvailable: boolean
  imageUrl?: string
  rating?: number
  preparationTime?: number // in minutes
  spiceLevel?: 'mild' | 'medium' | 'hot'
  tags?: string[]
  createdAt?: Date
  updatedAt?: Date
}

const menuItemSchema = new mongoose.Schema<IMenuItem>(
  {
    restaurantId: {
      type: String,
      required: true,
      index: true,
    },
    name: {
      type: String,
      required: true,
    },
    description: {
      type: String,
      required: true,
    },
    price: {
      type: Number,
      required: true,
    },
    category: {
      type: String,
      required: true,
      enum: ['Biryani', 'Starters', 'Main Course', 'Desserts', 'Beverages', 'Breads', 'Rice'],
    },
    isVeg: {
      type: Boolean,
      required: true,
      default: false,
    },
    isAvailable: {
      type: Boolean,
      default: true,
    },
    imageUrl: {
      type: String,
      default: '',
    },
    rating: {
      type: Number,
      min: 0,
      max: 5,
    },
    preparationTime: {
      type: Number,
      default: 30,
    },
    spiceLevel: {
      type: String,
      enum: ['mild', 'medium', 'hot'],
    },
    tags: {
      type: [String],
      default: [],
    },
  },
  {
    timestamps: true,
  }
)

// Create compound index for efficient queries
menuItemSchema.index({ restaurantId: 1, category: 1 })
menuItemSchema.index({ restaurantId: 1, isVeg: 1 })

export default mongoose.models.MenuItem || mongoose.model<IMenuItem>('MenuItem', menuItemSchema)
