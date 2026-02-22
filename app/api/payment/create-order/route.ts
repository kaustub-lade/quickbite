import { NextRequest, NextResponse } from 'next/server';
import Razorpay from 'razorpay';
import connectToDatabase from '@/lib/mongodb';
import { razorpayConfig } from '@/lib/razorpay';
import { authenticateUser } from '@/lib/middleware/auth';

// POST /api/payment/create-order - Create Razorpay order
export async function POST(req: NextRequest) {
  try {
    await connectToDatabase();

    // Authenticate user
    const authResult = await authenticateUser(req);
    if (!authResult.user) {
      return NextResponse.json(
        { success: false, error: 'Authentication required' },
        { status: 401 }
      );
    }

    const { amount, currency = 'INR', orderId, receipt, notes } = await req.json();

    // Validate required fields
    if (!amount || amount <= 0) {
      return NextResponse.json(
        { success: false, error: 'Invalid amount' },
        { status: 400 }
      );
    }

    // Check if Razorpay is enabled
    if (!razorpayConfig.enabled) {
      return NextResponse.json(
        {
          success: false,
          error: 'Online payment is currently disabled. Please use Cash on Delivery.',
        },
        { status: 503 }
      );
    }

    // Initialize Razorpay
    const razorpay = new Razorpay({
      key_id: razorpayConfig.keyId,
      key_secret: razorpayConfig.keySecret,
    });

    // Create Razorpay order
    const razorpayOrder = await razorpay.orders.create({
      amount: Math.round(amount * 100), // Convert to paise (smallest currency unit)
      currency,
      receipt: receipt || orderId || `receipt_${Date.now()}`,
      notes: notes || { orderId: orderId || '' },
    });

    return NextResponse.json({
      success: true,
      order: razorpayOrder,
      keyId: razorpayConfig.keyId,
    });
  } catch (error: any) {
    console.error('Error creating Razorpay order:', error);
    
    // Handle specific Razorpay errors
    if (error.statusCode === 400) {
      return NextResponse.json(
        { success: false, error: 'Invalid payment details' },
        { status: 400 }
      );
    }

    return NextResponse.json(
      {
        success: false,
        error: error.message || 'Failed to create payment order',
      },
      { status: 500 }
    );
  }
}
