import { NextRequest, NextResponse } from 'next/server'
import connectToDatabase from '@/lib/mongodb'
import mongoose from 'mongoose'

// GET /api/menu/best-deals - Get items with highest savings across platforms
export async function GET(req: NextRequest) {
  try {
    await connectToDatabase()

    const { searchParams } = new URL(req.url)
    const limit = parseInt(searchParams.get('limit') || '15')
    const minSavings = parseInt(searchParams.get('minSavings') || '20')

    // Get the MenuItem model (use existing model)
    const MenuItem = mongoose.models.MenuItem || mongoose.model('MenuItem', new mongoose.Schema({}, { strict: false }))

    // Get menu items with platform pricing
    const menuItems = await MenuItem.find({
      isAvailable: true,
      'platformPrices.0': { $exists: true } // Has at least one platform price
    })
      .select('name description price imageUrl isVeg category restaurantId platformPrices')
      .lean()

    // Calculate savings for each item and filter
    const itemsWithSavings = menuItems.map((item: any) => {
      const platformPrices = item.platformPrices || []
      
      // Calculate max savings across all platforms
      let maxSavings = 0
      let bestPlatform = 'swiggy'
      let lowestPrice = item.price
      
      platformPrices.forEach((platformPrice: any) => {
        const savings = platformPrice.savings || 0
        if (savings > maxSavings) {
          maxSavings = savings
          bestPlatform = platformPrice.platform
          lowestPrice = platformPrice.price
        }
      })

      return {
        ...item,
        maxSavings,
        bestPlatform,
        lowestPrice,
        savingsPercent: item.price > 0 ? Math.round((maxSavings / item.price) * 100) : 0
      }
    })
      .filter((item: any) => item.maxSavings >= minSavings)
      .sort((a: any, b: any) => b.maxSavings - a.maxSavings)
      .slice(0, limit)

    // Get restaurant details for each item
    const Restaurant = mongoose.models.Restaurant || mongoose.model('Restaurant', new mongoose.Schema({}, { strict: false }))
    
    const restaurantIds = [...new Set(itemsWithSavings.map((item: any) => item.restaurantId))]
    const restaurants = await Restaurant.find({ 
      restaurantId: { $in: restaurantIds } 
    })
      .select('restaurantId name rating deliveryTime')
      .lean()

    // Create restaurant lookup map
    const restaurantMap = new Map()
    restaurants.forEach((r: any) => {
      restaurantMap.set(r.restaurantId, {
        id: r.restaurantId,
        name: r.name,
        rating: r.rating,
        deliveryTime: r.deliveryTime
      })
    })

    // Attach restaurant data to items
    const bestDeals = itemsWithSavings.map((item: any) => ({
      id: item._id,
      name: item.name,
      description: item.description,
      originalPrice: item.price,
      bestPrice: item.lowestPrice,
      savings: item.maxSavings,
      savingsPercent: item.savingsPercent,
      bestPlatform: item.bestPlatform,
      imageUrl: item.imageUrl,
      isVeg: item.isVeg,
      category: item.category,
      restaurant: restaurantMap.get(item.restaurantId) || null
    }))

    return NextResponse.json({
      success: true,
      deals: bestDeals,
      count: bestDeals.length
    })
  } catch (error: any) {
    console.error('Error fetching best deals:', error)
    return NextResponse.json(
      { error: 'Failed to fetch best deals', message: error.message },
      { status: 500 }
    )
  }
}
