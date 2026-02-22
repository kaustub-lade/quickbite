import { NextRequest } from 'next/server'
import connectDB from '@/lib/mongodb'
import Order from '@/lib/models/Order'
import MenuItem from '@/lib/models/MenuItem'

export async function GET(req: NextRequest) {
  try {
    await connectDB()

    const searchParams = req.nextUrl.searchParams
    const limit = parseInt(searchParams.get('limit') || '20')
    const days = parseInt(searchParams.get('days') || '30')

    // Calculate date range
    const startDate = new Date()
    startDate.setDate(startDate.getDate() - days)

    // Aggregate most ordered items
    const popularItems = await Order.aggregate([
      {
        $match: {
          createdAt: { $gte: startDate },
          status: { $ne: 'cancelled' },
        },
      },
      {
        $unwind: '$items',
      },
      {
        $group: {
          _id: '$items.menuItemId',
          itemName: { $first: '$items.name' },
          totalOrders: { $sum: '$items.quantity' },
          totalRevenue: { $sum: { $multiply: ['$items.price', '$items.quantity'] } },
          avgPrice: { $avg: '$items.price' },
        },
      },
      {
        $sort: { totalOrders: -1 },
      },
      {
        $limit: limit,
      },
    ])

    // Get full menu item details for top items
    const itemIds = popularItems.map(item => item._id)
    const menuItems = await MenuItem.find({ _id: { $in: itemIds } })
      .select('name description price imageUrl category isVeg')
      .lean()

    // Merge data
    const enrichedItems = popularItems.map((popItem: any) => {
      const menuItem = menuItems.find((mi: any) => mi._id.toString() === popItem._id.toString())
      return {
        ...popItem,
        ...menuItem,
      }
    })

    // Calculate category distribution
    const categoryDistribution = await Order.aggregate([
      {
        $match: {
          createdAt: { $gte: startDate },
          status: { $ne: 'cancelled' },
        },
      },
      {
        $unwind: '$items',
      },
      {
        $lookup: {
          from: 'menuitems',
          localField: 'items.menuItemId',
          foreignField: '_id',
          as: 'menuItem',
        },
      },
      {
        $unwind: '$menuItem',
      },
      {
        $group: {
          _id: '$menuItem.category',
          count: { $sum: '$items.quantity' },
          revenue: { $sum: { $multiply: ['$items.price', '$items.quantity'] } },
        },
      },
      {
        $sort: { count: -1 },
      },
    ])

    return Response.json({
      success: true,
      popularItems: enrichedItems,
      categoryDistribution,
      totalItems: enrichedItems.length,
      period: {
        days,
        startDate: startDate.toISOString(),
      },
    })
  } catch (error: any) {
    console.error('Error fetching popular items:', error)
    return Response.json(
      {
        success: false,
        error: 'Failed to fetch popular items',
        message: error.message,
      },
      { status: 500 }
    )
  }
}
