import mongoose from 'mongoose';

export interface IOrderTracking extends mongoose.Document {
  orderId: mongoose.Types.ObjectId;
  userId: mongoose.Types.ObjectId;
  restaurantId: mongoose.Types.ObjectId;
  status: 'pending' | 'confirmed' | 'preparing' | 'out_for_delivery' | 'delivered' | 'cancelled';
  statusHistory: Array<{
    status: string;
    timestamp: Date;
    note?: string;
    location?: {
      latitude: number;
      longitude: number;
    };
  }>;
  deliveryPerson?: {
    name: string;
    phone: string;
    currentLocation?: {
      latitude: number;
      longitude: number;
      lastUpdated: Date;
    };
  };
  estimatedDeliveryTime?: Date;
  actualDeliveryTime?: Date;
  createdAt: Date;
  updatedAt: Date;
}

const orderTrackingSchema = new mongoose.Schema({
  orderId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Order',
    required: true,
    unique: true,
    index: true
  },
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true
  },
  restaurantId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Restaurant',
    required: true
  },
  status: {
    type: String,
    enum: ['pending', 'confirmed', 'preparing', 'out_for_delivery', 'delivered', 'cancelled'],
    default: 'pending'
  },
  statusHistory: [{
    status: {
      type: String,
      required: true
    },
    timestamp: {
      type: Date,
      default: Date.now
    },
    note: String,
    location: {
      latitude: Number,
      longitude: Number
    }
  }],
  deliveryPerson: {
    name: String,
    phone: String,
    currentLocation: {
      latitude: Number,
      longitude: Number,
      lastUpdated: Date
    }
  },
  estimatedDeliveryTime: Date,
  actualDeliveryTime: Date
}, {
  timestamps: true
});

// Update status history when status changes
orderTrackingSchema.pre('save', function() {
  if (this.isModified('status')) {
    this.statusHistory.push({
      status: this.status,
      timestamp: new Date(),
      note: `Order ${this.status}`
    });

    // Set actual delivery time when delivered
    if (this.status === 'delivered' && !this.actualDeliveryTime) {
      this.actualDeliveryTime = new Date();
    }
  }
});

export const OrderTracking = mongoose.models.OrderTracking || 
  mongoose.model<IOrderTracking>('OrderTracking', orderTrackingSchema);
