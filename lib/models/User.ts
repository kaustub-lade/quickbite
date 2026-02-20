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
      required: true,
      unique: true,
      trim: true,
    },
    password: {
      type: String,
      required: true,
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
  },
  {
    timestamps: true,
  }
)

// Index for faster lookups
userSchema.index({ email: 1 })
userSchema.index({ phone: 1 })

export default mongoose.models.User || mongoose.model<IUser>('User', userSchema)
