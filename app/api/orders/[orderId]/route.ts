import { NextRequest, NextResponse } from 'next/server';
import connectToDatabase from '@/lib/mongodb';
import { Order } from '@/lib/models/Order';

// GET /api/orders/[orderId] - Get specific order details
export async function GET(
  req: NextRequest,
  { params }: { params: Promise<{ orderId: string }> }
) {
  try {
    await connectToDatabase();
    const { orderId } = await params;

    const order = await Order.findById(orderId).lean();

    if (!order) {
      return NextResponse.json(
        { error: 'Order not found' },
        { status: 404 }
      );
    }

    return NextResponse.json({
      success: true,
      order: {
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
      }
    });

  } catch (error) {
    console.error('Fetch order error:', error);
    return NextResponse.json(
      { error: 'Failed to fetch order' },
      { status: 500 }
    );
  }
}

// PATCH /api/orders/[orderId] - Update order status
export async function PATCH(
  req: NextRequest,
  { params }: { params: Promise<{ orderId: string }> }
) {
  try {
    await connectToDatabase();
    const { orderId } = await params;
    const body = await req.json();
    const { status, paymentStatus } = body;

    const updateData: any = {};
    if (status) updateData.status = status;
    if (paymentStatus) updateData.paymentStatus = paymentStatus;

    const order = await Order.findByIdAndUpdate(
      orderId,
      updateData,
      { new: true }
    ).lean();

    if (!order) {
      return NextResponse.json(
        { error: 'Order not found' },
        { status: 404 }
      );
    }

    return NextResponse.json({
      success: true,
      order: {
        id: order._id,
        status: order.status,
        paymentStatus: order.paymentStatus,
        updatedAt: order.updatedAt
      },
      message: 'Order updated successfully'
    });

  } catch (error) {
    console.error('Update order error:', error);
    return NextResponse.json(
      { error: 'Failed to update order' },
      { status: 500 }
    );
  }
}
