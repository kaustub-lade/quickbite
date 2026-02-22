import { NextRequest } from 'next/server';
import connectDB from '@/lib/mongodb';
import { Order } from '@/lib/models/Order';
import { requireAdmin } from '@/lib/middleware/auth';

// GET - Commission statistics and reports
export async function GET(req: NextRequest) {
  try {
    const authResult = await requireAdmin(req);
    if (authResult.error) {
      return Response.json({ error: authResult.error }, { status: 401 });
    }

    await connectDB();

    const { searchParams } = new URL(req.url);
    const startDate = searchParams.get('startDate');
    const endDate = searchParams.get('endDate');
    const restaurantId = searchParams.get('restaurantId');
    const status = searchParams.get('status'); // 'pending', 'paid', 'refunded'

    // Build query
    const query: any = {
      paymentStatus: 'completed', // Only count completed payments
    };

    if (startDate || endDate) {
      query.createdAt = {};
      if (startDate) query.createdAt.$gte = new Date(startDate);
      if (endDate) query.createdAt.$lte = new Date(endDate);
    }

    if (restaurantId) {
      query.restaurantId = restaurantId;
    }

    if (status) {
      query['commission.status'] = status;
    }

    // Get commission summary
    const summary = await Order.aggregate([
      { $match: query },
      {
        $group: {
          _id: null,
          totalOrders: { $sum: 1 },
          totalRevenue: { $sum: '$totalAmount' },
          totalCommission: { $sum: '$commission.amount' },
          totalRestaurantPayout: { $sum: '$restaurantPayout.amount' },
          pendingCommission: {
            $sum: {
              $cond: [{ $eq: ['$commission.status', 'pending'] }, '$commission.amount', 0]
            }
          },
          paidCommission: {
            $sum: {
              $cond: [{ $eq: ['$commission.status', 'paid'] }, '$commission.amount', 0]
            }
          },
          pendingPayout: {
            $sum: {
              $cond: [{ $eq: ['$restaurantPayout.status', 'pending'] }, '$restaurantPayout.amount', 0]
            }
          },
          paidPayout: {
            $sum: {
              $cond: [{ $eq: ['$restaurantPayout.status', 'paid'] }, '$restaurantPayout.amount', 0]
            }
          }
        }
      }
    ]);

    // Get commission by restaurant
    const byRestaurant = await Order.aggregate([
      { $match: query },
      {
        $group: {
          _id: '$restaurantId',
          restaurantName: { $first: '$restaurantName' },
          orderCount: { $sum: 1 },
          totalRevenue: { $sum: '$totalAmount' },
          commissionEarned: { $sum: '$commission.amount' },
          restaurantPayout: { $sum: '$restaurantPayout.amount' },
          pendingPayout: {
            $sum: {
              $cond: [{ $eq: ['$restaurantPayout.status', 'pending'] }, '$restaurantPayout.amount', 0]
            }
          }
        }
      },
      { $sort: { commissionEarned: -1 } },
      { $limit: 50 }
    ]);

    // Get commission by date (last 30 days)
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    const byDate = await Order.aggregate([
      { 
        $match: { 
          ...query, 
          createdAt: { $gte: thirtyDaysAgo } 
        } 
      },
      {
        $group: {
          _id: { $dateToString: { format: '%Y-%m-%d', date: '$createdAt' } },
          orderCount: { $sum: 1 },
          revenue: { $sum: '$totalAmount' },
          commission: { $sum: '$commission.amount' }
        }
      },
      { $sort: { _id: 1 } }
    ]);

    return Response.json({
      success: true,
      summary: summary[0] || {
        totalOrders: 0,
        totalRevenue: 0,
        totalCommission: 0,
        totalRestaurantPayout: 0,
        pendingCommission: 0,
        paidCommission: 0,
        pendingPayout: 0,
        paidPayout: 0
      },
      byRestaurant,
      byDate
    });
  } catch (error: any) {
    console.error('Commission report error:', error);
    return Response.json(
      { error: 'Failed to generate commission report', details: error.message },
      { status: 500 }
    );
  }
}

// PATCH - Update commission/payout status
export async function PATCH(req: NextRequest) {
  try {
    const authResult = await requireAdmin(req);
    if (authResult.error) {
      return Response.json({ error: authResult.error }, { status: 401 });
    }

    await connectDB();

    const body = await req.json();
    const { orderId, type, status } = body; // type: 'commission' or 'payout'

    if (!orderId || !type || !status) {
      return Response.json(
        { error: 'Missing required fields: orderId, type, status' },
        { status: 400 }
      );
    }

    if (type !== 'commission' && type !== 'payout') {
      return Response.json(
        { error: 'Type must be "commission" or "payout"' },
        { status: 400 }
      );
    }

    if (!['pending', 'paid', 'refunded'].includes(status)) {
      return Response.json(
        { error: 'Status must be "pending", "paid", or "refunded"' },
        { status: 400 }
      );
    }

    const updateField = type === 'commission' ? 'commission.status' : 'restaurantPayout.status';
    const paidAtField = type === 'commission' ? 'commission.paidAt' : 'restaurantPayout.paidAt';

    const update: any = { [updateField]: status };
    if (status === 'paid') {
      update[paidAtField] = new Date();
    } else {
      update[paidAtField] = null;
    }

    const order = await Order.findByIdAndUpdate(
      orderId,
      { $set: update },
      { new: true }
    );

    if (!order) {
      return Response.json({ error: 'Order not found' }, { status: 404 });
    }

    return Response.json({
      success: true,
      message: `${type === 'commission' ? 'Commission' : 'Restaurant payout'} status updated`,
      order: {
        _id: order._id,
        restaurantName: order.restaurantName,
        totalAmount: order.totalAmount,
        commission: order.commission,
        restaurantPayout: order.restaurantPayout
      }
    });
  } catch (error: any) {
    console.error('Update commission status error:', error);
    return Response.json(
      { error: 'Failed to update status', details: error.message },
      { status: 500 }
    );
  }
}
