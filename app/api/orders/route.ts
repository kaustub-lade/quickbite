import { NextRequest, NextResponse } from 'next/server';
import connectToDatabase from '@/lib/mongodb';
import { Order } from '@/lib/models/Order';
import User from '@/lib/models/User';
import Restaurant from '@/lib/models/Restaurant';

// POST /api/orders - Create new order
export async function POST(req: NextRequest) {
  try {
    await connectToDatabase();

    const body = await req.json();
    const {
      userId,
      restaurantId,
      items,
      deliveryAddress,
      platform,
      paymentMethod,
      specialInstructions
    } = body;

    // Validate required fields
    if (!userId || !restaurantId || !items || items.length === 0 || !deliveryAddress || !platform) {
      return NextResponse.json(
        { error: 'Missing required fields' },
        { status: 400 }
      );
    }

    // Verify user exists
    const user = await User.findById(userId);
    if (!user) {
      return NextResponse.json(
        { error: 'User not found' },
        { status: 404 }
      );
    }

    // Verify restaurant exists (handle both ObjectId and string ID)
    const restaurant = await Restaurant.findOne({
      $or: [
        { _id: restaurantId },
        { restaurantId: restaurantId }
      ]
    }).catch(() => null);
    
    if (!restaurant) {
      return NextResponse.json(
        { error: 'Restaurant not found' },
        { status: 404 }
      );
    }

    // Calculate total amount
    const totalAmount = items.reduce((sum: number, item: any) => {
      return sum + (item.price * item.quantity);
    }, 0);

    // Create order
    const order = new Order({
      userId,
      restaurantId,
      restaurantName: restaurant.name,
      items,
      totalAmount,
      deliveryAddress,
      platform,
      paymentMethod: paymentMethod || 'cod',
      paymentStatus: paymentMethod === 'cod' ? 'pending' : 'pending',
      status: 'pending',
      specialInstructions
    });

    await order.save();

    return NextResponse.json({
      success: true,
      order: {
        id: order._id,
        orderNumber: order._id.toString().slice(-8).toUpperCase(),
        restaurantName: order.restaurantName,
        totalAmount: order.totalAmount,
        status: order.status,
        createdAt: order.createdAt
      },
      message: 'Order placed successfully!'
    }, { status: 201 });

  } catch (error) {
    console.error('Order creation error:', error);
    return NextResponse.json(
      { error: 'Failed to create order' },
      { status: 500 }
    );
  }
}

// GET /api/orders?userId=xxx - Get user's orders
export async function GET(req: NextRequest) {
  try {
    await connectToDatabase();

    const searchParams = req.nextUrl.searchParams;
    const userId = searchParams.get('userId');

    if (!userId) {
      return NextResponse.json(
        { error: 'userId parameter is required' },
        { status: 400 }
      );
    }

    const orders = await Order.find({ userId })
      .sort({ createdAt: -1 })
      .limit(50)
      .lean();

    return NextResponse.json({
      success: true,
      orders: orders.map(order => ({
        id: order._id,
        orderNumber: order._id.toString().slice(-8).toUpperCase(),
        restaurantName: order.restaurantName,
        items: order.items,
        totalAmount: order.totalAmount,
        status: order.status,
        paymentStatus: order.paymentStatus,
        paymentMethod: order.paymentMethod,
        deliveryAddress: order.deliveryAddress,
        platform: order.platform,
        specialInstructions: order.specialInstructions,
        createdAt: order.createdAt,
        updatedAt: order.updatedAt
      }))
    });

  } catch (error) {
    console.error('Fetch orders error:', error);
    return NextResponse.json(
      { error: 'Failed to fetch orders' },
      { status: 500 }
    );
  }
}
