import mongoose, { Document, Schema } from 'mongoose';

export interface IGiftCard extends Document {
  code: string;
  balance: number;
  originalAmount: number;
  purchasedBy?: string; // User ID
  recipientEmail?: string;
  recipientName?: string;
  message?: string;
  expiresAt: Date;
  isActive: boolean;
  transactions: {
    type: 'purchase' | 'redemption' | 'refund';
    amount: number;
    orderId?: string;
    userId?: string;
    timestamp: Date;
    note?: string;
  }[];
  createdAt: Date;
  updatedAt: Date;
}

const giftCardSchema = new Schema<IGiftCard>(
  {
    code: {
      type: String,
      required: true,
      unique: true,
      uppercase: true,
      trim: true,
    },
    balance: {
      type: Number,
      required: true,
      min: 0,
    },
    originalAmount: {
      type: Number,
      required: true,
      min: 0,
    },
    purchasedBy: {
      type: String,
    },
    recipientEmail: {
      type: String,
      lowercase: true,
      trim: true,
    },
    recipientName: {
      type: String,
      trim: true,
    },
    message: {
      type: String,
      maxlength: 500,
    },
    expiresAt: {
      type: Date,
      required: true,
    },
    isActive: {
      type: Boolean,
      default: true,
    },
    transactions: [
      {
        type: {
          type: String,
          enum: ['purchase', 'redemption', 'refund'],
          required: true,
        },
        amount: {
          type: Number,
          required: true,
        },
        orderId: String,
        userId: String,
        timestamp: {
          type: Date,
          default: Date.now,
        },
        note: String,
      },
    ],
  },
  {
    timestamps: true,
  }
);

// Index for efficient lookups
giftCardSchema.index({ code: 1, isActive: 1 });
giftCardSchema.index({ purchasedBy: 1 });
giftCardSchema.index({ recipientEmail: 1 });

export const GiftCard = mongoose.models.GiftCard || mongoose.model<IGiftCard>('GiftCard', giftCardSchema);
