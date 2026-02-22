import { NextRequest } from 'next/server'
import connectDB from '@/lib/mongodb'
import Order from '@/lib/models/Order'
import { authenticateUser } from '@/lib/middleware/auth'

export async function GET(req: NextRequest) {
  try {
    await connectDB()

    // Authenticate user
    const user = await authenticateUser(req)
    if (!user) {
      return Response.json({ success: false, error: 'Unauthorized' }, { status: 401 })
    }

    // Check if user is restaurant owner or admin
    if (user.role !== 'restaurant_owner' && user.role !== 'admin') {
      return Response.json(
        { success: false, error: 'Only restaurant owners can access this endpoint' },
        { status: 403 }
      )
    }

    const searchParams = req.nextUrl.searchParams
    const restaurantId = searchParams.get('restaurantId')
    const status = searchParams.get('status') // 'pending', 'confirmed', 'preparing', 'out_for_delivery', 'delivered', 'cancelled'
    const limit = parseInt(searchParams.get('limit') || '50')
    const page = parseInt(searchParams.get('page') || '1')
    const skip = (page - 1) * limit

    // Build query
    let query: any = {}

    if (restaurantId) {
      query.restaurantId = restaurantId
    }

    if (status) {
      query.status = status
    }

    // Fetch orders
    const orders = await Order.find(query)
      .sort({ createdAt: -1 })
      .limit(limit)
      .skip(skip)
      .lean()

    // Get total count
    const totalCount = await Order.countDocuments(query)

    // Calculate statistics
    const stats = await Order.aggregate([
      { $match: query },
      {
        $group: {
          _id: '$status',
          count: { $sum: 1 },
          totalRevenue: { $sum: '$totalAmount' },
        },
      },
    ])

    return Response.json({
      success: true,
      orders,
      pagination: {
        page,
        limit,
        total: totalCount,
        pages: Math.ceil(totalCount / limit),
      },
      stats,
    })
  } catch (error: any) {
    console.error('Error fetching owner orders:', error)
    return Response.json(
      {
        success: false,
        error: 'Failed to fetch orders',
        message: error.message,
      },
      { status: 500 }
    )
  }
}

// Update order status
export async function PATCH(req: NextRequest) {
  try {
    await connectDB()

    // Authenticate user
    const user = await authenticateUser(req)
    if (!user) {
      return Response.json({ success: false, error: 'Unauthorized' }, { status: 401 })
    }

    // Check if user is restaurant owner or admin
    if (user.role !== 'restaurant_owner' && user.role !== 'admin') {
      return Response.json(
        { success: false, error: 'Only restaurant owners can update orders' },
        { status: 403 }
      )
    }

    const body = await req.json()
    const { orderId, status } = body

    if (!orderId || !status) {
      return Response.json(
        { success: false, error: 'orderId and status are required' },
        { status: 400 }
      )
    }

    // Valid statuses
    const validStatuses = ['pending', 'confirmed', 'preparing', 'out_for_delivery', 'delivered', 'cancelled']
    if (!validStatuses.includes(status)) {
      return Response.json(
        { success: false, error: 'Invalid status' },
        { status: 400 }
      )
    }

    // Update order
    const updatedOrder = await Order.findByIdAndUpdate(
      orderId,
      { status, updatedAt: new Date() },
      { new: true }
    )

    if (!updatedOrder) {
      return Response.json(
        { success: false, error: 'Order not found' },
        { status: 404 }
      )
    }

    return Response.json({
      success: true,
      order: updatedOrder,
    })
  } catch (error: any) {
    console.error('Error updating order status:', error)
    return Response.json(
      {
        success: false,
        error: 'Failed to update order',
        message: error.message,
      },
      { status: 500 }
    )
  }
}
