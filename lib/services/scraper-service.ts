import { firecrawlClient } from './firecrawl-client'
import { jinaClient } from './jina-client'
import ScrapedPrice, { IScrapedMenuItem } from '@/lib/models/ScrapedPrice'

/**
 * Scraper Service
 * 
 * Uses Jina AI Reader as primary scraper (100% free, unlimited)
 * Falls back to Firecrawl if Jina fails (500 credits total)
 * 
 * This hybrid approach ensures:
 * - Free unlimited scraping via Jina AI
 * - Reliability via Firecrawl fallback
 * - Minimal Firecrawl credit usage
 */
export class ScraperService {
  /**
   * Parse Swiggy markdown to extract menu items
   * NOTE: Adjust regex patterns based on actual Swiggy HTML structure
   * Test with real data first and update parsing logic accordingly
   */
  private parseSwiggyMarkdown(markdown: string): IScrapedMenuItem[] {
    const items: IScrapedMenuItem[] = []
    
    // Split by lines
    const lines = markdown.split('\n')
    
    for (let i = 0; i < lines.length; i++) {
      const line = lines[i].trim()
      
      // Match patterns like "Chicken Biryani ₹299" or "Paneer Tikka Rs 250"
      const priceMatch = line.match(/^(.+?)\s+(?:₹|Rs\.?)\s*(\d+)/)
      
      if (priceMatch) {
        const name = priceMatch[1].trim()
        const price = parseInt(priceMatch[2])
        
        // Look ahead for veg/non-veg indicator
        const nextLine = lines[i + 1]?.toLowerCase() || ''
        const prevLine = lines[i - 1]?.toLowerCase() || ''
        const contextLines = `${prevLine} ${line} ${nextLine}`.toLowerCase()
        
        // Detect veg (look for veg emoji 🟢 or text "veg")
        const isVeg = contextLines.includes('veg') && !contextLines.includes('non')
        
        // Check for availability
        const isAvailable = !contextLines.includes('sold out') &&
                           !contextLines.includes('unavailable') &&
                           !contextLines.includes('not available')
        
        items.push({
          name,
          price,
          isVeg,
          isAvailable,
          description: ''
        })
      }
    }
    
    return items
  }

  /**
   * Parse Zomato markdown (similar pattern, adjust as needed)
   */
  private parseZomatoMarkdown(markdown: string): IScrapedMenuItem[] {
    // Similar logic to Swiggy, adjust based on Zomato's structure
    return this.parseSwiggyMarkdown(markdown)
  }

  /**
   * Scrape restaurant from Swiggy
   * Uses Jina AI (free) first, falls back to Firecrawl if needed
   */
  async scrapeSwiggy(params: {
    restaurantId: string
    restaurantName: string
    restaurantSlug: string
    cityCode?: string
  }): Promise<IScrapedMenuItem[]> {
    const url = jinaClient.getSwiggyUrl(params.restaurantSlug, params.cityCode)
    const startTime = Date.now()
    
    try {
      console.log(`🔄 Scraping Swiggy: ${url}`)
      
      // Try Jina AI first (free, unlimited)
      let result = await jinaClient.scrapePage(url)
      let scrapeMethod = 'jina'
      
      // Fallback to Firecrawl if Jina fails
      if (!result) {
        console.log('⚠️ Jina AI failed, falling back to Firecrawl...')
        result = await firecrawlClient.scrapePage(url)
        scrapeMethod = 'firecrawl'
        
        if (!result) {
          throw new Error('Both Jina AI and Firecrawl failed')
        }
      }
      
      const menuItems = this.parseSwiggyMarkdown(result.markdown)
      const scrapeDuration = Date.now() - startTime
      
      // Save to database
      await ScrapedPrice.create({
        restaurantId: params.restaurantId,
        restaurantName: params.restaurantName,
        platform: 'swiggy',
        scrapedAt: new Date(),
        menuItems,
        metadata: {
          url,
          scrapeDuration,
          success: true,
          scrapeMethod  // Track which method was used
        }
      })
      
      console.log(`✅ Scraped ${menuItems.length} items from Swiggy via ${scrapeMethod} in ${scrapeDuration}ms`)
      
      return menuItems
    } catch (error: any) {
      const scrapeDuration = Date.now() - startTime
      
      // Save failed scrape to database for debugging
      await ScrapedPrice.create({
        restaurantId: params.restaurantId,
        restaurantName: params.restaurantName,
        platform: 'swiggy',
        scrapedAt: new Date(),
        menuItems: [],
        metadata: {
          url,
          scrapeDuration,
          success: false,
          errorMessage: error.message
        }
      })
      
      console.error(`❌ Scraping failed: ${error.message}`)
      throw error
    }
  }

  /**
   * Scrape restaurant from Zomato
   * Uses Jina AI (free) first, falls back to Firecrawl if needed
   */
  async scrapeZomato(params: {
    restaurantId: string
    restaurantName: string
    restaurantSlug: string
    cityCode?: string
  }): Promise<IScrapedMenuItem[]> {
    const url = jinaClient.getZomatoUrl(params.restaurantSlug, params.cityCode)
    const startTime = Date.now()
    
    try {
      console.log(`🔄 Scraping Zomato: ${url}`)
      
      // Try Jina AI first (free, unlimited)
      let result = await jinaClient.scrapePage(url)
      let scrapeMethod = 'jina'
      
      // Fallback to Firecrawl if Jina fails
      if (!result) {
        console.log('⚠️ Jina AI failed, falling back to Firecrawl...')
        result = await firecrawlClient.scrapePage(url)
        scrapeMethod = 'firecrawl'
        
        if (!result) {
          throw new Error('Both Jina AI and Firecrawl failed')
        }
      }
      
      const menuItems = this.parseZomatoMarkdown(result.markdown)
      const scrapeDuration = Date.now() - startTime
      
      await ScrapedPrice.create({
        restaurantId: params.restaurantId,
        restaurantName: params.restaurantName,
        platform: 'zomato',
        scrapedAt: new Date(),
        menuItems,
        metadata: {
          url,
          scrapeDuration,
          success: true,
          scrapeMethod  // Track which method was used
        }
      })
      
      console.log(`✅ Scraped ${menuItems.length} items from Zomato via ${scrapeMethod} in ${scrapeDuration}ms`)
      
      return menuItems
    } catch (error: any) {
      const scrapeDuration = Date.now() - startTime
      
      await ScrapedPrice.create({
        restaurantId: params.restaurantId,
        restaurantName: params.restaurantName,
        platform: 'zomato',
        scrapedAt: new Date(),
        menuItems: [],
        metadata: {
          url,
          scrapeDuration,
          success: false,
          errorMessage: error.message
        }
      })
      
      console.error(`❌ Scraping failed: ${error.message}`)
      throw error
    }
  }

  /**
   * Get cached prices or scrape if stale
   * This is the main method mobile app should call
   */
  async getLivePrices(params: {
    restaurantId: string
    restaurantName: string
    restaurantSlug: string
    platform: 'swiggy' | 'zomato'
    cacheHours?: number
  }): Promise<IScrapedMenuItem[]> {
    const cacheHours = params.cacheHours || 6
    const cacheThreshold = new Date(Date.now() - cacheHours * 3600000)
    
    // Check cache
    const cached = await ScrapedPrice.findOne({
      restaurantId: params.restaurantId,
      platform: params.platform,
      scrapedAt: { $gte: cacheThreshold },
      'metadata.success': true
    }).sort({ scrapedAt: -1 })
    
    if (cached) {
      const ageMinutes = Math.round((Date.now() - cached.scrapedAt.getTime()) / 60000)
      console.log(`✅ Cache hit for ${params.platform} (${ageMinutes} minutes old, ${cacheHours}h TTL)`)
      return cached.menuItems
    }
    
    // Cache miss - scrape now
    console.log(`🔄 Cache miss - scraping ${params.platform}...`)
    
    if (params.platform === 'swiggy') {
      return await this.scrapeSwiggy(params)
    } else {
      return await this.scrapeZomato(params)
    }
  }

  /**
   * Get all cached prices for a restaurant (both platforms)
   */
  async getAllCachedPrices(restaurantId: string): Promise<{
    swiggy: IScrapedMenuItem[] | null
    zomato: IScrapedMenuItem[] | null
  }> {
    const [swiggyCache, zomatoCache] = await Promise.all([
      ScrapedPrice.findOne({
        restaurantId,
        platform: 'swiggy',
        'metadata.success': true
      }).sort({ scrapedAt: -1 }),
      ScrapedPrice.findOne({
        restaurantId,
        platform: 'zomato',
        'metadata.success': true
      }).sort({ scrapedAt: -1 })
    ])

    return {
      swiggy: swiggyCache?.menuItems || null,
      zomato: zomatoCache?.menuItems || null
    }
  }
}

export const scraperService = new ScraperService()
