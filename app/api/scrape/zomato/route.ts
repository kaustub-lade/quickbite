import { NextRequest } from 'next/server'
import connectToDatabase from '@/lib/mongodb'
import { scraperService } from '@/lib/services/scraper-service'
import { authenticateUser } from '@/lib/middleware/auth'

/**
 * Manual scrape endpoint for Zomato
 * POST /api/scrape/zomato
 */
export async function POST(req: NextRequest) {
  await connectToDatabase()
  
  const { user, error } = await authenticateUser(req)
  if (error) {
    return Response.json({ success: false, error }, { status: 401 })
  }
  
  try {
    const body = await req.json()
    const { restaurantId, restaurantName, restaurantSlug, forceRefresh } = body
    
    if (!restaurantId || !restaurantName || !restaurantSlug) {
      return Response.json(
        { 
          success: false, 
          error: 'Missing required fields: restaurantId, restaurantName, restaurantSlug' 
        },
        { status: 400 }
      )
    }
    
    console.log(`📥 Zomato scrape request from user ${user.email}:`, {
      restaurantId,
      restaurantName,
      restaurantSlug,
      forceRefresh
    })
    
    // If forceRefresh, scrape directly without cache check
    let menuItems
    if (forceRefresh) {
      menuItems = await scraperService.scrapeZomato({
        restaurantId,
        restaurantName,
        restaurantSlug
      })
    } else {
      // Use cache-aware method
      menuItems = await scraperService.getLivePrices({
        restaurantId,
        restaurantName,
        restaurantSlug,
        platform: 'zomato',
        cacheHours: 6
      })
    }
    
    return Response.json({
      success: true,
      message: 'Scraped successfully',
      data: {
        platform: 'zomato',
        itemCount: menuItems.length,
        menuItems
      }
    })
  } catch (error: any) {
    console.error('❌ Zomato scraping API error:', error)
    return Response.json(
      { 
        success: false, 
        error: error.message || 'Scraping failed',
        details: process.env.NODE_ENV === 'development' ? error.stack : undefined
      },
      { status: 500 }
    )
  }
}
