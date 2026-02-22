import mongoose, { Document, Schema } from 'mongoose';

export interface ICoupon extends Document {
  code: string;
  type: 'percentage' | 'fixed' | 'free_delivery';
  value: number; // Percentage (e.g., 20) or fixed amount (e.g., 50)
  minOrderAmount: number;
  maxDiscountAmount?: number; // For percentage coupons
  validFrom: Date;
  validUntil: Date;
  usageLimit: number; // Total times this coupon can be used
  usageCount: number; // Times this coupon has been used
  userUsageLimit: number; // Times a single user can use this
  applicableRestaurants?: string[]; // Empty = all restaurants
  applicableCategories?: string[]; // Empty = all categories
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

const couponSchema = new Schema<ICoupon>(
  {
    code: {
      type: String,
      required: true,
      unique: true,
      uppercase: true,
      trim: true,
    },
    type: {
      type: String,
      enum: ['percentage', 'fixed', 'free_delivery'],
      required: true,
    },
    value: {
      type: Number,
      required: true,
      min: 0,
    },
    minOrderAmount: {
      type: Number,
      default: 0,
      min: 0,
    },
    maxDiscountAmount: {
      type: Number,
      min: 0,
    },
    validFrom: {
      type: Date,
      required: true,
    },
    validUntil: {
      type: Date,
      required: true,
    },
    usageLimit: {
      type: Number,
      default: 1000,
      min: 1,
    },
    usageCount: {
      type: Number,
      default: 0,
      min: 0,
    },
    userUsageLimit: {
      type: Number,
      default: 1,
      min: 1,
    },
    applicableRestaurants: [{
      type: String,
    }],
    applicableCategories: [{
      type: String,
    }],
    isActive: {
      type: Boolean,
      default: true,
    },
  },
  {
    timestamps: true,
  }
);

// Index for efficient lookups
couponSchema.index({ code: 1, isActive: 1 });
couponSchema.index({ validFrom: 1, validUntil: 1 });

export const Coupon = mongoose.models.Coupon || mongoose.model<ICoupon>('Coupon', couponSchema);
