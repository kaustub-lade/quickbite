import mongoose, { Document, Schema } from 'mongoose';

export interface ICouponUsage extends Document {
  userId: string;
  couponId: string;
  couponCode: string;
  orderId: string;
  discountAmount: number;
  usedAt: Date;
}

const couponUsageSchema = new Schema<ICouponUsage>(
  {
    userId: {
      type: String,
      required: true,
    },
    couponId: {
      type: String,
      required: true,
    },
    couponCode: {
      type: String,
      required: true,
      uppercase: true,
    },
    orderId: {
      type: String,
      required: true,
    },
    discountAmount: {
      type: Number,
      required: true,
      min: 0,
    },
    usedAt: {
      type: Date,
      default: Date.now,
    },
  },
  {
    timestamps: true,
  }
);

// Compound index for user + coupon lookups
couponUsageSchema.index({ userId: 1, couponId: 1 });
couponUsageSchema.index({ orderId: 1 });

export const CouponUsage = mongoose.models.CouponUsage || mongoose.model<ICouponUsage>('CouponUsage', couponUsageSchema);
