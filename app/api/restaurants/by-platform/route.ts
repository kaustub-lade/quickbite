import { NextRequest } from 'next/server'
import connectDB from '@/lib/mongodb'
import Restaurant from '@/lib/models/Restaurant'

export async function GET(req: NextRequest) {
  try {
    await connectDB()

    const searchParams = req.nextUrl.searchParams
    const platform = searchParams.get('platform') // 'swiggy', 'zomato', 'ondc', or 'all'
    const limit = parseInt(searchParams.get('limit') || '20')
    const cuisine = searchParams.get('cuisine') // optional filter by cuisine

    let query: any = {}

    // Filter by platform
    if (platform && platform !== 'all') {
      query.platforms = platform
    }

    // Filter by cuisine if provided
    if (cuisine) {
      query.cuisine = cuisine
    }

    const restaurants = await Restaurant.find(query)
      .select('id name cuisine location rating deliveryTime distance openingHours platforms totalReviews imageUrl image_url')
      .limit(limit)
      .sort({ rating: -1 })
      .lean()

    // Normalize imageUrl field
    const normalizedRestaurants = restaurants.map((r: any) => ({
      ...r,
      imageUrl: r.imageUrl || r.image_url,
    }))

    return Response.json({
      success: true,
      restaurants: normalizedRestaurants,
      count: normalizedRestaurants.length,
      platform: platform || 'all',
    })
  } catch (error: any) {
    console.error('Error fetching restaurants by platform:', error)
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
