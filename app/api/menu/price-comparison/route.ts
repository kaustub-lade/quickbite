import { NextRequest } from 'next/server'
import connectToDatabase from '@/lib/mongodb'
import MenuItem from '@/lib/models/MenuItem'
import { RestaurantPrice, Platform } from '@/lib/models'

/**
 * GET /api/menu/price-comparison?restaurantId=xxx&itemName=xxx
 * Returns price comparison across all platforms for a specific item
 * OR
 * GET /api/menu/price-comparison?restaurantId=xxx
 * Returns price comparison for all menu items of a restaurant
 */
export async function GET(req: NextRequest) {
  try {
    await connectToDatabase()

    const { searchParams } = new URL(req.url)
    const restaurantId = searchParams.get('restaurantId')
    const itemName = searchParams.get('itemName')

    if (!restaurantId) {
      return Response.json(
        { success: false, message: 'Restaurant ID is required' },
        { status: 400 }
      )
    }

    // Fetch menu items for this restaurant to get the actual data
    const menuItems = await MenuItem.find({ restaurantId }).lean()
    
    if (menuItems.length === 0) {
      return Response.json({
        success: false,
        message: 'No menu items found for this restaurant',
      }, { status: 404 })
    }

    // Try to find the Restaurant document by matching menu item data
    // Since MenuItem uses string restaurantId but RestaurantPrice uses ObjectId,
    // we need to find the Restaurant by other means
    // For now, we'll match based on the item names in the RestaurantPrice collection
    
    // Fetch all platforms
    const platforms = await Platform.find().lean()
    const platformMap = new Map(
      platforms.map(p => [p._id.toString(), { id: p._id.toString(), name: p.name }])
    )

    // Get all restaurant prices and try to match by item names
    const allPrices = await RestaurantPrice.find().lean()
    
    // Group prices by item name
    const pricesByItemName = new Map<string, any[]>()
    allPrices.forEach(price => {
      const itemName = price.item_name
      if (!pricesByItemName.has(itemName)) {
        pricesByItemName.set(itemName, [])
      }
      pricesByItemName.get(itemName)!.push({
        platform: platformMap.get(price.platform_id.toString())?.name || 'Unknown',
        platformId: price.platform_id.toString(),
        price: price.price,
        deliveryTime: price.delivery_time_mins,
        restaurantId: price.restaurant_id.toString(),
      })
    })

    // If specific item requested
    if (itemName) {
      const prices = pricesByItemName.get(itemName) || []

      if (prices.length === 0) {
        return Response.json({
          success: false,
          message: 'No price data found for this item',
        }, { status: 404 })
      }

      // Find best deal
      const bestDeal = prices.reduce((best, current) =>
        current.price < best.price ? current : best
      )

      // Calculate savings
      const pricesWithSavings = prices.map(p => ({
        platform: p.platform,
        platformId: p.platformId,
        price: p.price,
        deliveryTime: p.deliveryTime,
        isBestDeal: p.price === bestDeal.price,
        savings: p.price > bestDeal.price ? p.price - bestDeal.price : 0,
      }))

      return Response.json({
        success: true,
        data: {
          itemName,
          restaurantId,
          platformPrices: pricesWithSavings,
          bestDeal: {
            platform: bestDeal.platform,
            price: bestDeal.price,
            deliveryTime: bestDeal.deliveryTime,
          },
        },
      })
    }

    // Otherwise, return all menu items with platform prices
    // Match menu items with price data by item name
    const itemsWithPricing = menuItems.map(item => {
      const platformPrices = pricesByItemName.get(item.name) || []
      
      let bestDeal: { platform: string; platformId: string; price: number; deliveryTime: number } | null = null
      let pricesWithSavings: any[] = []

      if (platformPrices.length > 0) {
        bestDeal = platformPrices.reduce((best, current) =>
          current.price < best.price ? current : best
        )

        pricesWithSavings = platformPrices.map(p => ({
          platform: p.platform,
          platformId: p.platformId,
          price: p.price,
          deliveryTime: p.deliveryTime,
          isBestDeal: p.price === bestDeal!.price,
          savings: p.price > bestDeal!.price ? p.price - bestDeal!.price : 0,
        }))
      }

      return {
        id: item._id,
        name: item.name,
        description: item.description,
        basePrice: item.price,
        category: item.category,
        isVeg: item.isVeg,
        imageUrl: item.imageUrl,
        rating: item.rating,
        hasPlatformPricing: platformPrices.length > 0,
        platformPrices: pricesWithSavings,
        bestDeal: bestDeal ? {
          platform: bestDeal.platform,
          price: bestDeal.price,
          deliveryTime: bestDeal.deliveryTime,
        } : null,
      }
    })

    return Response.json({
      success: true,
      data: {
        restaurantId,
        menuItems: itemsWithPricing,
        totalItems: itemsWithPricing.length,
        itemsWithPricing: itemsWithPricing.filter(i => i.hasPlatformPricing).length,
      },
    })

  } catch (error) {
    console.error('Price Comparison API Error:', error)
    return Response.json(
      {
        success: false,
        message: 'Failed to fetch price comparison',
        error: error instanceof Error ? error.message : 'Unknown error',
      },
      { status: 500 }
    )
  }
}
