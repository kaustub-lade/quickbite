import { NextRequest } from 'next/server'
import connectDB from '@/lib/mongodb'
import Restaurant from '@/lib/models/Restaurant'
import User from '@/lib/models/User'
import { authenticateUser } from '@/lib/middleware/auth'

export async function GET(req: NextRequest) {
  try {
    await connectDB()

    // Authenticate user
    const user = await authenticateUser(req)
    if (!user) {
      return Response.json({ success: false, error: 'Unauthorized' }, { status: 401 })
    }

    // Check if user is restaurant owner
    if (user.role !== 'restaurant_owner' && user.role !== 'admin') {
      return Response.json(
        { success: false, error: 'Only restaurant owners can access this endpoint' },
        { status: 403 }
      )
    }

    // Get restaurants owned by this user
    // For now, we'll match by email domain or use a mapping
    // In production, you'd have a restaurantOwnerId field in Restaurant model
    const userEmail = user.email || ''
    
    // Simple matching: if email contains restaurant name or vice versa
    const restaurants = await Restaurant.find({})
      .lean()

    // Filter restaurants that might belong to this owner
    // This is a simplified version - in production, use proper ownership mapping
    const ownedRestaurants = restaurants.filter((r: any) => {
      const restaurantName = r.name.toLowerCase().replace(/[^a-z0-9]/g, '')
      const emailPrefix = userEmail.split('@')[0].toLowerCase()
      return restaurantName.includes(emailPrefix) || emailPrefix.includes(restaurantName.substring(0, 5))
    })

    // If admin, return all restaurants
    const finalRestaurants = user.role === 'admin' ? restaurants : ownedRestaurants

    return Response.json({
      success: true,
      restaurants: finalRestaurants,
      count: finalRestaurants.length,
    })
  } catch (error: any) {
    console.error('Error fetching owner restaurants:', error)
    return Response.json(
      {
        success: false,
        error: 'Failed to fetch restaurants',
        message: error.message,
      },
      { status: 500 }
    )
  }
}
