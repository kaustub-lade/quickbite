import { NextRequest } from 'next/server';
import connectDB from '@/lib/mongodb';
import { Coupon } from '@/lib/models/Coupon';
import { CouponUsage } from '@/lib/models/CouponUsage';
import { authenticateUser } from '@/lib/middleware/auth';

// POST /api/coupons/validate - Validate coupon code
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
    const { code, orderAmount, restaurantId, items } = body;

    if (!code) {
      return Response.json(
        { success: false, error: 'Coupon code is required' },
        { status: 400 }
      );
    }

    // Find coupon
    const coupon = await Coupon.findOne({
      code: code.toUpperCase(),
      isActive: true,
    });

    if (!coupon) {
      return Response.json(
        { success: false, error: 'Invalid coupon code' },
        { status: 404 }
      );
    }

    // Check validity dates
    const now = new Date();
    if (now < coupon.validFrom) {
      return Response.json(
        { success: false, error: 'Coupon not yet valid' },
        { status: 400 }
      );
    }

    if (now > coupon.validUntil) {
      return Response.json(
        { success: false, error: 'Coupon has expired' },
        { status: 400 }
      );
    }

    // Check usage limit
    if (coupon.usageCount >= coupon.usageLimit) {
      return Response.json(
        { success: false, error: 'Coupon usage limit reached' },
        { status: 400 }
      );
    }

    // Check user usage limit
    const userUsageCount = await CouponUsage.countDocuments({
      userId: authResult.user._id.toString(),
      couponId: coupon._id.toString(),
    });

    if (userUsageCount >= coupon.userUsageLimit) {
      return Response.json(
        { success: false, error: 'You have already used this coupon' },
        { status: 400 }
      );
    }

    // Check minimum order amount
    if (orderAmount < coupon.minOrderAmount) {
      return Response.json(
        {
          success: false,
          error: `Minimum order amount is ₹${coupon.minOrderAmount}`,
        },
        { status: 400 }
      );
    }

    // Check applicable restaurants
    if (coupon.applicableRestaurants && coupon.applicableRestaurants.length > 0) {
      if (!restaurantId || !coupon.applicableRestaurants.includes(restaurantId)) {
        return Response.json(
          { success: false, error: 'Coupon not applicable for this restaurant' },
          { status: 400 }
        );
      }
    }

    // Check applicable categories
    if (coupon.applicableCategories && coupon.applicableCategories.length > 0 && items) {
      const itemCategories = items.map((item: any) => item.category).filter(Boolean);
      const hasMatchingCategory = itemCategories.some((cat: string) =>
        coupon.applicableCategories?.includes(cat)
      );

      if (!hasMatchingCategory) {
        return Response.json(
          { success: false, error: 'Coupon not applicable for selected items' },
          { status: 400 }
        );
      }
    }

    // Calculate discount
    let discountAmount = 0;
    let deliveryDiscount = 0;

    switch (coupon.type) {
      case 'percentage':
        discountAmount = (orderAmount * coupon.value) / 100;
        if (coupon.maxDiscountAmount) {
          discountAmount = Math.min(discountAmount, coupon.maxDiscountAmount);
        }
        break;

      case 'fixed':
        discountAmount = Math.min(coupon.value, orderAmount);
        break;

      case 'free_delivery':
        deliveryDiscount = coupon.value; // Delivery fee amount
        break;
    }

    // Round to 2 decimals
    discountAmount = Math.round(discountAmount * 100) / 100;
    deliveryDiscount = Math.round(deliveryDiscount * 100) / 100;

    return Response.json({
      success: true,
      coupon: {
        id: coupon._id,
        code: coupon.code,
        type: coupon.type,
        value: coupon.value,
        discountAmount,
        deliveryDiscount,
        description: _getCouponDescription(coupon),
      },
    });
  } catch (error: any) {
    console.error('Coupon validation error:', error);
    return Response.json(
      { success: false, error: 'Failed to validate coupon' },
      { status: 500 }
    );
  }
}

function _getCouponDescription(coupon: any): string {
  switch (coupon.type) {
    case 'percentage':
      return `${coupon.value}% off${coupon.maxDiscountAmount ? ` up to ₹${coupon.maxDiscountAmount}` : ''}`;
    case 'fixed':
      return `₹${coupon.value} off`;
    case 'free_delivery':
      return 'Free delivery';
    default:
      return '';
  }
}
