import { NextRequest } from 'next/server'
import connectDB from '@/lib/mongodb'
import Order from '@/lib/models/Order'

export async function GET(req: NextRequest) {
  try {
    await connectDB()

    const searchParams = req.nextUrl.searchParams
    const days = parseInt(searchParams.get('days') || '30')
    const groupBy = searchParams.get('groupBy') || 'day' // 'day', 'week', 'month'

    // Calculate date range
    const endDate = new Date()
    const startDate = new Date()
    startDate.setDate(startDate.getDate() - days)

    // Aggregate orders by date
    const orderTrends = await Order.aggregate([
      {
        $match: {
          createdAt: { $gte: startDate, $lte: endDate },
        },
      },
      {
        $group: {
          _id: {
            $dateToString: {
              format: groupBy === 'day' ? '%Y-%m-%d' : groupBy === 'week' ? '%Y-W%V' : '%Y-%m',
              date: '$createdAt',
            },
          },
          totalOrders: { $sum: 1 },
          totalRevenue: { $sum: '$totalAmount' },
          avgOrderValue: { $avg: '$totalAmount' },
          completedOrders: {
            $sum: { $cond: [{ $eq: ['$status', 'delivered'] }, 1, 0] },
          },
          cancelledOrders: {
            $sum: { $cond: [{ $eq: ['$status', 'cancelled'] }, 1, 0] },
          },
        },
      },
      {
        $sort: { _id: 1 },
      },
    ])

    // Calculate totals
    const totals = orderTrends.reduce(
      (acc, day) => ({
        totalOrders: acc.totalOrders + day.totalOrders,
        totalRevenue: acc.totalRevenue + day.totalRevenue,
        completedOrders: acc.completedOrders + day.completedOrders,
        cancelledOrders: acc.cancelledOrders + day.cancelledOrders,
      }),
      { totalOrders: 0, totalRevenue: 0, completedOrders: 0, cancelledOrders: 0 }
    )

    return Response.json({
      success: true,
      trends: orderTrends,
      summary: {
        ...totals,
        avgOrderValue: totals.totalOrders > 0 ? totals.totalRevenue / totals.totalOrders : 0,
        completionRate: totals.totalOrders > 0 ? (totals.completedOrders / totals.totalOrders) * 100 : 0,
        cancellationRate: totals.totalOrders > 0 ? (totals.cancelledOrders / totals.totalOrders) * 100 : 0,
      },
      period: {
        startDate: startDate.toISOString(),
        endDate: endDate.toISOString(),
        days,
      },
    })
  } catch (error: any) {
    console.error('Error fetching order trends:', error)
    return Response.json(
      {
        success: false,
        error: 'Failed to fetch order trends',
        message: error.message,
      },
      { status: 500 }
    )
  }
}
