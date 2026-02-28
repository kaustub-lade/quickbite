import { NextRequest } from 'next/server'
import connectToDatabase from '@/lib/mongodb'
import { scraperService } from '@/lib/services/scraper-service'
import Restaurant from '@/lib/models/Restaurant'

/**
 * Get live prices for a restaurant from Swiggy/Zomato
 * GET /api/restaurants/:id/live-prices?platform=swiggy
 * 
 * Returns cached data if fresh (<6 hours), otherwise scrapes
 */
export async function GET(
  req: NextRequest,
  { params }: { params: { id: string } }
) {
  await connectToDatabase()
  
  try {
    const { id } = params
    const searchParams = req.nextUrl.searchParams
    const platform = searchParams.get('platform') as 'swiggy' | 'zomato' | 'both' | null
    
    // Get restaurant details
    const restaurant = await Restaurant.findById(id)
    
    if (!restaurant) {
      return Response.json(
        { success: false, error: 'Restaurant not found' },
        { status: 404 }
      )
    }
    
    // Platform-specific slugs
    // TODO: Add these fields to Restaurant model and seed data
    // For now, generate from restaurant name
    const swiggySlug = restaurant.swiggySlug || 
                       restaurant.name.toLowerCase()
                         .replace(/[^a-z0-9]+/g, '-')
                         .replace(/^-+|-+$/g, '')
    
    const zomatoSlug = restaurant.zomatoSlug || 
                       restaurant.name.toLowerCase()
                         .replace(/[^a-z0-9]+/g, '-')
                         .replace(/^-+|-+$/g, '')
    
    const results: any = {
      restaurantId: restaurant._id,
      restaurantName: restaurant.name,
      platforms: {}
    }
    
    // Scrape requested platform(s)
    const platformsToScrape = platform === 'both' || !platform 
      ? ['swiggy', 'zomato'] 
      : [platform]
    
    for (const platformName of platformsToScrape) {
      try {
        const items = await scraperService.getLivePrices({
          restaurantId: restaurant._id.toString(),
          restaurantName: restaurant.name,
          restaurantSlug: platformName === 'swiggy' ? swiggySlug : zomatoSlug,
          platform: platformName as 'swiggy' | 'zomato',
          cacheHours: 6
        })
        
        results.platforms[platformName] = {
          success: true,
          itemCount: items.length,
          items: items
        }
      } catch (error: any) {
        console.error(`Failed to get ${platformName} prices:`, error)
        results.platforms[platformName] = {
          success: false,
          error: error.message || 'Scraping failed',
          items: []
        }
      }
    }
    
    return Response.json({
      success: true,
      data: results
    })
  } catch (error: any) {
    console.error('❌ Live prices API error:', error)
    return Response.json(
      { 
        success: false, 
        error: error.message || 'Failed to get live prices' 
      },
      { status: 500 }
    )
  }
}
