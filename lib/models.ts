import mongoose, { Schema, Model } from 'mongoose'

// Restaurant Interface
export interface IRestaurant {
  name: string
  cuisine: string
  location: string
  rating: number
  image_url?: string
  created_at: Date
}

// Platform Interface
export interface IPlatform {
  name: string
  commission_rate: number
  created_at: Date
}

// RestaurantPrice Interface
export interface IRestaurantPrice {
  restaurant_id: mongoose.Types.ObjectId
  platform_id: mongoose.Types.ObjectId
  item_name: string
  price: number
  delivery_time_mins: number
  last_updated: Date
}

// UserOrder Interface
export interface IUserOrder {
  user_id: string
  restaurant_id: mongoose.Types.ObjectId
  platform_id: mongoose.Types.ObjectId
  total_price: number
  estimated_savings: number
  order_date: Date
}

// Restaurant Schema
const RestaurantSchema = new Schema<IRestaurant>({
  name: { type: String, required: true, unique: true },
  cuisine: { type: String, required: true },
  location: { type: String, required: true },
  rating: { type: Number, required: true, min: 0, max: 5 },
  image_url: { type: String },
  created_at: { type: Date, default: Date.now },
})

// Platform Schema
const PlatformSchema = new Schema<IPlatform>({
  name: { type: String, required: true, unique: true },
  commission_rate: { type: Number, required: true, min: 0, max: 100 },
  created_at: { type: Date, default: Date.now },
})

// RestaurantPrice Schema
const RestaurantPriceSchema = new Schema<IRestaurantPrice>({
  restaurant_id: { type: Schema.Types.ObjectId, ref: 'Restaurant', required: true },
  platform_id: { type: Schema.Types.ObjectId, ref: 'Platform', required: true },
  item_name: { type: String, required: true },
  price: { type: Number, required: true, min: 0 },
  delivery_time_mins: { type: Number, required: true, min: 0 },
  last_updated: { type: Date, default: Date.now },
})

// Create compound index for efficient queries
RestaurantPriceSchema.index({ restaurant_id: 1, platform_id: 1, item_name: 1 })

// UserOrder Schema
const UserOrderSchema = new Schema<IUserOrder>({
  user_id: { type: String, required: true },
  restaurant_id: { type: Schema.Types.ObjectId, ref: 'Restaurant', required: true },
  platform_id: { type: Schema.Types.ObjectId, ref: 'Platform', required: true },
  total_price: { type: Number, required: true, min: 0 },
  estimated_savings: { type: Number, default: 0 },
  order_date: { type: Date, default: Date.now },
})

UserOrderSchema.index({ user_id: 1, order_date: -1 })

// Models (with proper TypeScript typing)
export const Restaurant: Model<IRestaurant> = 
  mongoose.models.Restaurant || mongoose.model<IRestaurant>('Restaurant', RestaurantSchema)

export const Platform: Model<IPlatform> = 
  mongoose.models.Platform || mongoose.model<IPlatform>('Platform', PlatformSchema)

export const RestaurantPrice: Model<IRestaurantPrice> = 
  mongoose.models.RestaurantPrice || mongoose.model<IRestaurantPrice>('RestaurantPrice', RestaurantPriceSchema)

export const UserOrder: Model<IUserOrder> = 
  mongoose.models.UserOrder || mongoose.model<IUserOrder>('UserOrder', UserOrderSchema)
