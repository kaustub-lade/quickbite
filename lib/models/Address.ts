import mongoose from 'mongoose'

export interface IAddress {
  _id?: string
  userId: string
  label: 'Home' | 'Work' | 'Other'
  customLabel?: string // For 'Other' type
  address: string
  landmark?: string
  city: string
  pincode: string
  phone: string
  isDefault: boolean
  createdAt?: Date
  updatedAt?: Date
}

const addressSchema = new mongoose.Schema<IAddress>(
  {
    userId: {
      type: String,
      required: true,
      index: true,
    },
    label: {
      type: String,
      required: true,
      enum: ['Home', 'Work', 'Other'],
      default: 'Home',
    },
    customLabel: {
      type: String,
    },
    address: {
      type: String,
      required: true,
    },
    landmark: {
      type: String,
    },
    city: {
      type: String,
      required: true,
    },
    pincode: {
      type: String,
      required: true,
      match: /^[0-9]{6}$/,
    },
    phone: {
      type: String,
      required: true,
      match: /^[0-9]{10}$/,
    },
    isDefault: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
  }
)

// Create compound index for efficient queries
addressSchema.index({ userId: 1, isDefault: -1 })
addressSchema.index({ userId: 1, label: 1 })

export default mongoose.models.Address || mongoose.model<IAddress>('Address', addressSchema)
