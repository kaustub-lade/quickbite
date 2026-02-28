/**
 * Jina AI Reader Client
 * 
 * Free API that converts any URL to LLM-friendly markdown
 * Usage: Prepend https://r.jina.ai/ to any URL
 * 
 * Advantages over Firecrawl:
 * - 100% FREE forever (no credit limits)
 * - Fast response times
 * - Designed for RAG/LLM workflows
 * - No API key required
 * - No rate limits documented
 * 
 * Documentation: https://jina.ai/reader
 */

export class JinaClient {
  private baseUrl = 'https://r.jina.ai'

  /**
   * Scrape a single page and return markdown content
   * 
   * @param url - The URL to scrape
   * @returns Markdown content or null if failed
   */
  async scrapePage(url: string): Promise<{ markdown: string } | null> {
    try {
      const startTime = Date.now()
      
      // Jina AI Reader: Prepend r.jina.ai/ to the URL
      const jinaUrl = `${this.baseUrl}/${url}`
      
      console.log(`🔄 Scraping with Jina AI: ${url}`)
      
      const response = await fetch(jinaUrl, {
        headers: {
          'Accept': 'text/plain',
          'X-Return-Format': 'markdown'
        }
      })

      if (!response.ok) {
        throw new Error(`Jina AI request failed: ${response.status} ${response.statusText}`)
      }

      const markdown = await response.text()
      const duration = Date.now() - startTime
      
      console.log(`✅ Scraped with Jina AI in ${duration}ms (${markdown.length} chars)`)
      
      return { markdown }
    } catch (error) {
      console.error('❌ Jina AI scraping error:', error)
      return null
    }
  }

  /**
   * Build platform-specific URLs (same as Firecrawl)
   */
  getSwiggyUrl(restaurantSlug: string, cityCode: string = 'mumbai'): string {
    return `https://www.swiggy.com/restaurants/${restaurantSlug}-${cityCode}`
  }

  getZomatoUrl(restaurantSlug: string, cityCode: string = 'mumbai'): string {
    return `https://www.zomato.com/${cityCode}/${restaurantSlug}`
  }
}

export const jinaClient = new JinaClient()
