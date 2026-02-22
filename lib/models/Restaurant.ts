import mongoose from 'mongoose'

export interface IRestaurant {
  _id?: string
  id: string
  name: string
  cuisine: string
  location: string
  rating: number
  imageUrl?: string
  deliveryTime?: string
  distance?: number
  openingHours?: string
  platforms?: ('swiggy' | 'zomato' | 'ondc')[]
  reviews?: Array<{
    userId: string
    userName: string
    rating: number
    comment: string
    createdAt: Date
  }>
  totalReviews?: number
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
    deliveryTime: {
      type: String,
      default: '30-40 mins',
    },
    distance: {
      type: Number,
      default: 2.5,
    },
    openingHours: {
      type: String,
      default: '9:00 AM - 11:00 PM',
    },
    platforms: {
      type: [String],
      enum: ['swiggy', 'zomato', 'ondc'],
      default: ['swiggy', 'zomato'],
    },
    reviews: {
      type: [
        {
          userId: String,
          userName: String,
          rating: Number,
          comment: String,
          createdAt: Date,
        },
      ],
      default: [],
    },
    totalReviews: {
      type: Number,
      default: 0,
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
