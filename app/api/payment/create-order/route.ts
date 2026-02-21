import { NextRequest, NextResponse } from 'next/server';
import connectToDatabase from '@/lib/mongodb';
import { razorpayConfig } from '@/lib/razorpay';
import crypto from 'crypto';

// POST /api/payment/create-order - Create Razorpay order
export async function POST(req: NextRequest) {
  try {
    await connectToDatabase();

    const { amount, currency = 'INR', orderId, receipt } = await req.json();

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

    // In a real implementation, we would call Razorpay API here
    // For demo purposes, we'll return a mock order
    const razorpayOrderId = `order_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

    // Mock Razorpay order response
    const razorpayOrder = {
      id: razorpayOrderId,
      entity: 'order',
      amount: amount * 100, // Razorpay expects amount in paise
      amount_paid: 0,
      amount_due: amount * 100,
      currency,
      receipt: receipt || orderId || `receipt_${Date.now()}`,
      status: 'created',
      attempts: 0,
      created_at: Math.floor(Date.now() / 1000),
    };

    return NextResponse.json({
      success: true,
      order: razorpayOrder,
      keyId: razorpayConfig.keyId,
    });
  } catch (error: any) {
    console.error('Error creating Razorpay order:', error);
    return NextResponse.json(
      {
        success: false,
        error: error.message || 'Failed to create payment order',
      },
      { status: 500 }
    );
  }
}
