import FirecrawlApp from '@mendable/firecrawl-js'

export class FirecrawlClient {
  private app: FirecrawlApp | null
  private isConfigured: boolean

  constructor() {
    const apiKey = process.env.FIRECRAWL_API_KEY || ''
    this.isConfigured = !!apiKey
    
    if (!this.isConfigured) {
      console.warn('⚠️ FIRECRAWL_API_KEY not configured - scraping will be disabled')
      this.app = null
    } else {
      this.app = new FirecrawlApp({ apiKey })
    }
  }

  /**
   * Scrape a single page and return markdown content
   */
  async scrapePage(url: string): Promise<{ markdown: string; html?: string } | null> {
    if (!this.isConfigured || !this.app) {
      throw new Error('Firecrawl API key not configured. Add FIRECRAWL_API_KEY to .env.local')
    }

    try {
      const startTime = Date.now()
      
      const scrapeResult = await this.app.scrape(url, {
        formats: ['markdown', 'html'],
        onlyMainContent: true,
        waitFor: 2000 // Wait 2 seconds for JS to load
      })

      const duration = Date.now() - startTime
      
      console.log(`✅ Scraped ${url} in ${duration}ms`)

      return {
        markdown: scrapeResult.markdown || '',
        html: scrapeResult.html
      }
    } catch (error) {
      console.error('❌ Firecrawl scraping error:', error)
      return null
    }
  }

  /**
   * Check remaining API credits
   */
  async getCredits(): Promise<number> {
    if (!this.isConfigured) return 0

    try {
      // Firecrawl SDK doesn't expose credits endpoint yet
      // Return a default value for now
      return 500 // Assume free tier
    } catch (error) {
      console.error('Failed to fetch Firecrawl credits:', error)
      return 0
    }
  }

  /**
   * Build platform-specific URLs
   */
  getSwiggyUrl(restaurantSlug: string, cityCode: string = 'mumbai'): string {
    return `https://www.swiggy.com/restaurants/${restaurantSlug}-${cityCode}`
  }

  getZomatoUrl(restaurantSlug: string, cityCode: string = 'mumbai'): string {
    return `https://www.zomato.com/${cityCode}/${restaurantSlug}`
  }
}

export const firecrawlClient = new FirecrawlClient()
