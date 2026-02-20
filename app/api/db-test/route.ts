import { NextResponse } from 'next/server'
import connectDB from '@/lib/mongodb'
import { Restaurant, Platform, RestaurantPrice, UserOrder } from '@/lib/models'

export async function GET() {
  try {
    // Test MongoDB connection
    const conn = await connectDB()
    
    // Test collection counts
    const [restaurantCount, platformCount, priceCount, orderCount] = await Promise.all([
      Restaurant.countDocuments(),
      Platform.countDocuments(),
      RestaurantPrice.countDocuments(),
      UserOrder.countDocuments()
    ])

    return NextResponse.json({
      status: 'connected',
      database: conn.connection.db?.databaseName || 'unknown',
      collections: {
        restaurants: restaurantCount,
        platforms: platformCount,
        restaurantPrices: priceCount,
        userOrders: orderCount
      },
      message: 'MongoDB Atlas connection successful! 🎉'
    })

  } catch (error) {
    console.error('MongoDB connection error:', error)
    return NextResponse.json(
      { 
        status: 'error',
        error: 'Failed to connect to MongoDB',
        details: (error as Error).message
      },
      { status: 500 }
    )
  }
}
