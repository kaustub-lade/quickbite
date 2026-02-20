import { NextRequest, NextResponse } from 'next/server'
import dbConnect from '@/lib/mongodb'
import User from '@/lib/models/User'
import Restaurant from '@/lib/models/Restaurant'
import MenuItem from '@/lib/models/MenuItem'
import { requireAdmin } from '@/lib/middleware/auth'

export const dynamic = 'force-dynamic'

// GET /api/admin/stats - Get platform statistics
export async function GET(req: NextRequest) {
  try {
    await dbConnect()

    const { user, error, statusCode } = await requireAdmin(req)
    if (error) {
      return NextResponse.json(
        { success: false, message: error },
        { status: statusCode || 401 }
      )
    }

    // Get user statistics
    const totalUsers = await User.countDocuments()
    const adminCount = await User.countDocuments({ role: 'admin' })
    const customerCount = await User.countDocuments({ role: 'customer' })
    const ownerCount = await User.countDocuments({ role: 'restaurant_owner' })
    const verifiedUsers = await User.countDocuments({ isEmailVerified: true })

    // Get restaurant statistics
    const totalRestaurants = await Restaurant.countDocuments()

    // Get menu statistics
    const totalMenuItems = await MenuItem.countDocuments()
    const availableItems = await MenuItem.countDocuments({ isAvailable: true })
    const vegItems = await MenuItem.countDocuments({ isVeg: true })

    // Get recent users
    const recentUsers = await User.find()
      .select('-password')
      .sort({ createdAt: -1 })
      .limit(5)

    // Get menu items by restaurant
    const itemsByRestaurant = await MenuItem.aggregate([
      {
        $group: {
          _id: '$restaurantId',
          count: { $sum: 1 },
          avgPrice: { $avg: '$price' },
        },
      },
      { $sort: { count: -1 } },
    ])

    // Get menu items by category
    const itemsByCategory = await MenuItem.aggregate([
      {
        $group: {
          _id: '$category',
          count: { $sum: 1 },
        },
      },
      { $sort: { count: -1 } },
    ])

    return NextResponse.json({
      success: true,
      data: {
        users: {
          total: totalUsers,
          admins: adminCount,
          customers: customerCount,
          restaurantOwners: ownerCount,
          verified: verifiedUsers,
          verificationRate: totalUsers > 0 ? ((verifiedUsers / totalUsers) * 100).toFixed(1) : '0',
        },
        restaurants: {
          total: totalRestaurants,
        },
        menuItems: {
          total: totalMenuItems,
          available: availableItems,
          unavailable: totalMenuItems - availableItems,
          vegetarian: vegItems,
          nonVegetarian: totalMenuItems - vegItems,
        },
        recentActivity: {
          recentUsers,
        },
        analytics: {
          itemsByRestaurant,
          itemsByCategory,
        },
      },
    })
  } catch (error: any) {
    console.error('Error fetching stats:', error)
    return NextResponse.json(
      { success: false, message: 'Failed to fetch statistics' },
      { status: 500 }
    )
  }
}
