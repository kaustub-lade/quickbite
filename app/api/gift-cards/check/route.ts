import { NextRequest } from 'next/server';
import connectDB from '@/lib/mongodb';
import { GiftCard } from '@/lib/models/GiftCard';
import { authenticateUser } from '@/lib/middleware/auth';

// POST /api/gift-cards/check - Check gift card balance
export async function POST(req: NextRequest) {
  try {
    await connectDB();

    // Authenticate user
    const authResult = await authenticateUser(req);
    if (!authResult.user) {
      return Response.json(
        { success: false, error: 'Authentication required' },
        { status: 401 }
      );
    }

    const body = await req.json();
    const { code } = body;

    if (!code) {
      return Response.json(
        { success: false, error: 'Gift card code is required' },
        { status: 400 }
      );
    }

    // Find gift card
    const giftCard = await GiftCard.findOne({
      code: code.toUpperCase(),
      isActive: true,
    });

    if (!giftCard) {
      return Response.json(
        { success: false, error: 'Invalid gift card code' },
        { status: 404 }
      );
    }

    // Check expiration
    const now = new Date();
    if (now > giftCard.expiresAt) {
      return Response.json(
        { success: false, error: 'Gift card has expired' },
        { status: 400 }
      );
    }

    // Check balance
    if (giftCard.balance <= 0) {
      return Response.json(
        { success: false, error: 'Gift card has no balance' },
        { status: 400 }
      );
    }

    return Response.json({
      success: true,
      giftCard: {
        id: giftCard._id,
        code: giftCard.code,
        balance: giftCard.balance,
        originalAmount: giftCard.originalAmount,
        expiresAt: giftCard.expiresAt,
      },
    });
  } catch (error: any) {
    console.error('Gift card check error:', error);
    return Response.json(
      { success: false, error: 'Failed to check gift card' },
      { status: 500 }
    );
  }
}

// PATCH /api/gift-cards/check - Redeem gift card (called during order placement)
export async function PATCH(req: NextRequest) {
  try {
    await connectDB();

    // Authenticate user
    const authResult = await authenticateUser(req);
    if (!authResult.user) {
      return Response.json(
        { success: false, error: 'Authentication required' },
        { status: 401 }
      );
    }

    const body = await req.json();
    const { code, amount, orderId } = body;

    if (!code || !amount || !orderId) {
      return Response.json(
        { success: false, error: 'Code, amount, and orderId are required' },
        { status: 400 }
      );
    }

    // Find gift card
    const giftCard = await GiftCard.findOne({
      code: code.toUpperCase(),
      isActive: true,
    });

    if (!giftCard) {
      return Response.json(
        { success: false, error: 'Invalid gift card code' },
        { status: 404 }
      );
    }

    // Check expiration
    const now = new Date();
    if (now > giftCard.expiresAt) {
      return Response.json(
        { success: false, error: 'Gift card has expired' },
        { status: 400 }
      );
    }

    // Check balance
    if (giftCard.balance < amount) {
      return Response.json(
        { success: false, error: 'Insufficient gift card balance' },
        { status: 400 }
      );
    }

    // Deduct amount from balance
    giftCard.balance -= amount;

    // Add transaction record
    giftCard.transactions.push({
      type: 'redemption',
      amount: -amount,
      orderId,
      userId: authResult.user._id.toString(),
      timestamp: new Date(),
      note: `Redeemed for order #${orderId}`,
    } as any);

    await giftCard.save();

    return Response.json({
      success: true,
      giftCard: {
        id: giftCard._id,
        code: giftCard.code,
        balance: giftCard.balance,
        amountRedeemed: amount,
      },
    });
  } catch (error: any) {
    console.error('Gift card redemption error:', error);
    return Response.json(
      { success: false, error: 'Failed to redeem gift card' },
      { status: 500 }
    );
  }
}
