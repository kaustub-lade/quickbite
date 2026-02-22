import mongoose from 'mongoose'

export interface IUser {
  _id?: string
  name: string
  email: string
  phone: string
  password: string
  role: 'customer' | 'admin' | 'restaurant_owner'
  restaurantId?: string
  isEmailVerified: boolean
  googleId?: string
  profilePicture?: string
  location?: {
    latitude: number
    longitude: number
    address?: string
    lastUpdated?: Date
  }
  createdAt?: Date
  updatedAt?: Date
}

const userSchema = new mongoose.Schema<IUser>(
  {
    name: {
      type: String,
      required: true,
      trim: true,
      minlength: 3,
    },
    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true,
    },
    phone: {
      type: String,
      required: false, // Optional for Google sign-in users
      trim: true,
    },
    password: {
      type: String,
      required: false, // Optional for Google sign-in users
      minlength: 6,
    },
    role: {
      type: String,
      enum: ['customer', 'admin', 'restaurant_owner'],
      default: 'customer',
    },
    restaurantId: {
      type: String,
      required: false,
    },
    isEmailVerified: {
      type: Boolean,
      default: false,
    },
    googleId: {
      type: String,
      unique: true,
      sparse: true, // Allows null values with unique constraint
    },
    profilePicture: {
      type: String,
    },
    location: {
      latitude: Number,
      longitude: Number,
      address: String,
      lastUpdated: Date,
    },
  },
  {
    timestamps: true,
  }
)

// Index for faster lookups
userSchema.index({ email: 1 })
userSchema.index({ phone: 1 })

export default mongoose.models.User || mongoose.model<IUser>('User', userSchema)
