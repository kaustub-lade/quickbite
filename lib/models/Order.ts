import mongoose from 'mongoose';

export interface IOrderItem {
  menuItemId: mongoose.Types.ObjectId;
  name: string;
  price: number;
  quantity: number;
  isVeg: boolean;
  platform: 'swiggy' | 'zomato' | 'ondc';
}

export interface IOrder extends mongoose.Document {
  userId: mongoose.Types.ObjectId;
  restaurantId: mongoose.Types.ObjectId;
  restaurantName: string;
  items: IOrderItem[];
  subtotal: number; // Before discounts
  totalAmount: number; // After discounts
  deliveryFee: number;
  // Coupon and gift card
  coupon?: {
    code: string;
    couponId: string;
    discountAmount: number;
    deliveryDiscount: number;
  };
  giftCard?: {
    code: string;
    giftCardId: string;
    amountUsed: number;
  };
  deliveryAddress: {
    fullAddress: string;
    landmark?: string;
    city: string;
    pincode: string;
    phone: string;
  };
  status: 'pending' | 'confirmed' | 'preparing' | 'out_for_delivery' | 'delivered' | 'cancelled';
  platform: 'swiggy' | 'zomato' | 'ondc';
  paymentStatus: 'pending' | 'processing' | 'completed' | 'failed';
  paymentMethod?: 'cod' | 'online';
  paymentDetails?: {
    razorpayOrderId?: string;
    razorpayPaymentId?: string;
    razorpaySignature?: string;
  };
  paymentFailureReason?: string;
  specialInstructions?: string;
  // Commission tracking
  commission: {
    rate: number; // Percentage (10-15%)
    amount: number; // Calculated commission amount
    status: 'pending' | 'paid' | 'refunded';
    paidAt?: Date;
  };
  restaurantPayout: {
    amount: number; // totalAmount - commission.amount
    status: 'pending' | 'paid' | 'refunded';
    paidAt?: Date;
  };
  createdAt: Date;
  updatedAt: Date;
}

const orderItemSchema = new mongoose.Schema({
  menuItemId: { type: mongoose.Schema.Types.ObjectId, required: true },
  name: { type: String, required: true },
  price: { type: Number, required: true },
  quantity: { type: Number, required: true, min: 1 },
  isVeg: { type: Boolean, required: true },
  platform: { type: String, enum: ['swiggy', 'zomato', 'ondc'], required: true }
});

const orderSchema = new mongoose.Schema({
  userId: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'User',
    required: true,
    index: true
  },
  restaurantId: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'Restaurant',
    required: true,
    index: true
  },
  restaurantName: { type: String, required: true },
  items: [orderItemSchema],
  subtotal: { type: Number, required: true, min: 0 },
  totalAmount: { type: Number, required: true, min: 0 },
  deliveryFee: { type: Number, required: true, default: 0 },
  // Coupon and gift card
  coupon: {
    code: { type: String, uppercase: true },
    couponId: { type: String },
    discountAmount: { type: Number, default: 0 },
    deliveryDiscount: { type: Number, default: 0 }
  },
  giftCard: {
    code: { type: String, uppercase: true },
    giftCardId: { type: String },
    amountUsed: { type: Number, default: 0 }
  },
  deliveryAddress: {
    fullAddress: { type: String, required: true },
    landmark: { type: String },
    city: { type: String, required: true },
    pincode: { type: String, required: true },
    phone: { type: String, required: true }
  },
  status: {
    type: String,
    enum: ['pending', 'confirmed', 'preparing', 'out_for_delivery', 'delivered', 'cancelled'],
    default: 'pending',
    index: true
  },
  platform: {
    type: String,
    enum: ['swiggy', 'zomato', 'ondc'],
    required: true
  },
  paymentStatus: {
    type: String,
    enum: ['pending', 'processing', 'completed', 'failed'],
    default: 'pending'
  },
  paymentMethod: {
    type: String,
    enum: ['cod', 'online']
  },
  paymentDetails: {
    razorpayOrderId: { type: String },
    razorpayPaymentId: { type: String },
    razorpaySignature: { type: String }
  },
  paymentFailureReason: { type: String },
  specialInstructions: { type: String },
  // Commission tracking
  commission: {
    rate: { type: Number, required: true, default: 12 }, // 12% default
    amount: { type: Number, required: true, default: 0 },
    status: { 
      type: String, 
      enum: ['pending', 'paid', 'refunded'],
      default: 'pending'
    },
    paidAt: { type: Date }
  },
  restaurantPayout: {
    amount: { type: Number, required: true, default: 0 },
    status: { 
      type: String, 
      enum: ['pending', 'paid', 'refunded'],
      default: 'pending'
    },
    paidAt: { type: Date }
  }
}, {
  timestamps: true
});

// Index for efficient queries
orderSchema.index({ userId: 1, createdAt: -1 });
orderSchema.index({ restaurantId: 1, createdAt: -1 });

// Calculate commission and restaurant payout before saving
orderSchema.pre('save', function() {
  if (this.isNew || this.isModified('totalAmount') || this.isModified('commission.rate')) {
    const commissionRate = this.commission?.rate || 12; // Default 12%
    const commissionAmount = (this.totalAmount * commissionRate) / 100;
    const restaurantPayoutAmount = this.totalAmount - commissionAmount;

    this.commission = {
      rate: commissionRate,
      amount: Math.round(commissionAmount * 100) / 100, // Round to 2 decimals
      status: this.commission?.status || 'pending',
      paidAt: this.commission?.paidAt
    };

    this.restaurantPayout = {
      amount: Math.round(restaurantPayoutAmount * 100) / 100, // Round to 2 decimals
      status: this.restaurantPayout?.status || 'pending',
      paidAt: this.restaurantPayout?.paidAt
    };
  }
});

export const Order = mongoose.models.Order || mongoose.model<IOrder>('Order', orderSchema);
