import { NextRequest } from 'next/server'
import connectDB from '@/lib/mongodb'
import Restaurant from '@/lib/models/Restaurant'
import MenuItem from '@/lib/models/MenuItem'

export async function GET(req: NextRequest) {
  try {
    await connectDB()

    const searchParams = req.nextUrl.searchParams
    const query = searchParams.get('q') || ''
    const minRating = parseFloat(searchParams.get('minRating') || '0')
    const maxPrice = parseInt(searchParams.get('maxPrice') || '99999')
    const isVeg = searchParams.get('isVeg') // 'true', 'false', or null (both)
    const platform = searchParams.get('platform') // 'swiggy', 'zomato', 'ondc', or null
    const cuisine = searchParams.get('cuisine')
    const maxDeliveryTime = parseInt(searchParams.get('maxDeliveryTime') || '999')
    const sortBy = searchParams.get('sortBy') || 'relevance' // 'relevance', 'rating', 'price', 'deliveryTime'
    const limit = parseInt(searchParams.get('limit') || '50')

    // Build restaurant query
    let restaurantQuery: any = {}
    
    if (query) {
      restaurantQuery.$or = [
        { name: { $regex: query, $options: 'i' } },
        { cuisine: { $regex: query, $options: 'i' } },
      ]
    }

    if (minRating > 0) {
      restaurantQuery.rating = { $gte: minRating }
    }

    if (platform) {
      restaurantQuery.platforms = platform
    }

    if (cuisine) {
      restaurantQuery.cuisine = { $regex: cuisine, $options: 'i' }
    }

    // Fetch restaurants
    let restaurantsPromise = Restaurant.find(restaurantQuery)
      .select('id name cuisine location rating deliveryTime distance openingHours platforms totalReviews imageUrl image_url')
      .lean()

    // Build menu items query
    let menuQuery: any = {}
    
    if (query) {
      menuQuery.$or = [
        { name: { $regex: query, $options: 'i' } },
        { category: { $regex: query, $options: 'i' } },
        { description: { $regex: query, $options: 'i' } },
      ]
    }

    if (maxPrice < 99999) {
      menuQuery.price = { $lte: maxPrice }
    }

    if (isVeg === 'true') {
      menuQuery.isVeg = true
    } else if (isVeg === 'false') {
      menuQuery.isVeg = false
    }

    // Fetch menu items with restaurant details
    let menuItemsPromise = MenuItem.find(menuQuery)
      .select('name description price isVeg category imageUrl restaurant_id restaurantId')
      .limit(limit)
      .lean()

    const [restaurants, menuItems] = await Promise.all([restaurantsPromise, menuItemsPromise])

    // Normalize restaurant image URLs
    const normalizedRestaurants = restaurants.map((r: any) => ({
      ...r,
      imageUrl: r.imageUrl || r.image_url,
    }))

    // Filter restaurants by delivery time if specified
    let filteredRestaurants = normalizedRestaurants
    if (maxDeliveryTime < 999) {
      filteredRestaurants = normalizedRestaurants.filter((r: any) => {
        if (!r.deliveryTime) return true
        const match = r.deliveryTime.match(/(\d+)/)
        if (match) {
          const mins = parseInt(match[1])
          return mins <= maxDeliveryTime
        }
        return true
      })
    }

    // Sort restaurants based on sortBy parameter
    if (sortBy === 'rating') {
      filteredRestaurants.sort((a: any, b: any) => (b.rating || 0) - (a.rating || 0))
    } else if (sortBy === 'deliveryTime') {
      filteredRestaurants.sort((a: any, b: any) => {
        const aTime = parseInt(a.deliveryTime?.match(/(\d+)/)?.[1] || '999')
        const bTime = parseInt(b.deliveryTime?.match(/(\d+)/)?.[1] || '999')
        return aTime - bTime
      })
    }

    // Sort menu items
    let sortedMenuItems = menuItems
    if (sortBy === 'price') {
      sortedMenuItems.sort((a: any, b: any) => (a.price || 0) - (b.price || 0))
    }

    // Limit results
    const limitedRestaurants = filteredRestaurants.slice(0, limit)
    const limitedMenuItems = sortedMenuItems.slice(0, limit)

    return Response.json({
      success: true,
      restaurants: limitedRestaurants,
      menuItems: limitedMenuItems,
      totalRestaurants: limitedRestaurants.length,
      totalMenuItems: limitedMenuItems.length,
      filters: {
        query,
        minRating,
        maxPrice,
        isVeg,
        platform,
        cuisine,
        maxDeliveryTime,
        sortBy,
      },
    })
  } catch (error: any) {
    console.error('Error performing advanced search:', error)
    return Response.json(
      {
        success: false,
        error: 'Search failed',
        message: error.message,
      },
      { status: 500 }
    )
  }
}
