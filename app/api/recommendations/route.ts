import { NextRequest, NextResponse } from 'next/server'
import connectDB from '@/lib/mongodb'
import { Restaurant, Platform, RestaurantPrice } from '@/lib/models'

export async function GET(request: NextRequest) {
  try {
    await connectDB()

    const { searchParams } = new URL(request.url)
    const category = searchParams.get('category')

    if (!category) {
      return NextResponse.json(
        { error: 'Category parameter is required' },
        { status: 400 }
      )
    }

    // Find restaurants matching the cuisine category
    const restaurants = await Restaurant.find({
      cuisine: { $regex: new RegExp(category, 'i') }
    }).limit(5)

    if (restaurants.length === 0) {
      return NextResponse.json(
        { message: 'No restaurants found for this category', recommendations: [] },
        { status: 200 }
      )
    }

    // Get all platforms
    const platforms = await Platform.find({})
    const platformMap = new Map(platforms.map(p => [p._id.toString(), p]))

    // Get pricing data for all found restaurants
    const restaurantIds = restaurants.map(r => r._id)
    const prices = await RestaurantPrice.find({
      restaurant_id: { $in: restaurantIds }
    }).populate('platform_id')

    // Group prices by restaurant
    const pricesByRestaurant = new Map()
    for (const price of prices) {
      const restId = price.restaurant_id.toString()
      if (!pricesByRestaurant.has(restId)) {
        pricesByRestaurant.set(restId, [])
      }
      pricesByRestaurant.get(restId).push(price)
    }

    // Build recommendations with smart insights
    const recommendations = []
    
    for (const restaurant of restaurants) {
      const restaurantPrices = pricesByRestaurant.get(restaurant._id.toString()) || []
      
      if (restaurantPrices.length === 0) continue

      // Find cheapest and fastest options
      const sortedByPrice = [...restaurantPrices].sort((a, b) => a.price - b.price)
      const sortedByTime = [...restaurantPrices].sort((a, b) => a.delivery_time_mins - b.delivery_time_mins)
      
      const cheapest = sortedByPrice[0]
      const fastest = sortedByTime[0]
      const mostExpensive = sortedByPrice[sortedByPrice.length - 1]

      // Determine which option to recommend based on best value
      let recommended = cheapest
      let badge = 'Best Deal'
      let badgeVariant: 'default' | 'secondary' | 'outline' = 'default'
      let reason = ''
      let savings = 0

      if (sortedByPrice.length > 1) {
        savings = mostExpensive.price - cheapest.price
        
        if (savings > 50) {
          recommended = cheapest
          badge = 'Best Deal'
          badgeVariant = 'default'
          reason = `₹${savings} cheaper than ${(mostExpensive.platform_id as any).name} with same great taste`
        } else if (fastest.delivery_time_mins < cheapest.delivery_time_mins - 10) {
          recommended = fastest
          badge = 'Fastest'
          badgeVariant = 'secondary'
          reason = `Arrives in just ${fastest.delivery_time_mins} minutes`
        } else {
          recommended = cheapest
          badge = 'Top Rated'
          badgeVariant = 'outline'
          reason = `${restaurant.rating}★ rating with great reviews`
        }
      } else {
        badge = 'Available'
        badgeVariant = 'outline'
        reason = `${restaurant.rating}★ rated restaurant`
      }

      const platform = platformMap.get(recommended.platform_id.toString())

      recommendations.push({
        id: restaurant._id,
        title: restaurant.name,
        badge,
        badgeVariant,
        price: recommended.price,
        savings,
        platform: platform?.name || 'Unknown',
        deliveryTime: recommended.delivery_time_mins,
        rating: restaurant.rating,
        reason,
        image_url: restaurant.image_url,
        cuisine: restaurant.cuisine,
        location: restaurant.location
      })
    }

    // Sort recommendations: best deals first, then by savings
    recommendations.sort((a, b) => {
      if (a.badgeVariant === 'default' && b.badgeVariant !== 'default') return -1
      if (a.badgeVariant !== 'default' && b.badgeVariant === 'default') return 1
      return b.savings - a.savings
    })

    return NextResponse.json({
      category,
      count: recommendations.length,
      recommendations
    })

  } catch (error) {
    console.error('Error fetching recommendations:', error)
    return NextResponse.json(
      { error: 'Failed to fetch recommendations', details: (error as Error).message },
      { status: 500 }
    )
  }
}
