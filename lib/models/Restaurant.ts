import mongoose from 'mongoose'

export interface IRestaurant {
  _id?: string
  id: string
  name: string
  cuisine: string
  location: string
  rating: number
  imageUrl?: string
  createdAt?: Date
  updatedAt?: Date
}

const restaurantSchema = new mongoose.Schema<IRestaurant>(
  {
    id: {
      type: String,
      required: true,
      unique: true,
      index: true,
    },
    name: {
      type: String,
      required: true,
    },
    cuisine: {
      type: String,
      required: true,
    },
    location: {
      type: String,
      required: true,
    },
    rating: {
      type: Number,
      default: 0,
      min: 0,
      max: 5,
    },
    imageUrl: {
      type: String,
    },
  },
  {
    timestamps: true,
    collection: 'restaurants',
  }
)

// Create index on name for faster searches
restaurantSchema.index({ name: 1 })

const Restaurant =
  mongoose.models.Restaurant || mongoose.model<IRestaurant>('Restaurant', restaurantSchema)

export default Restaurant
