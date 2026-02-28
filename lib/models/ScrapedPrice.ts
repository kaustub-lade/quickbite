import mongoose, { Schema, Document } from 'mongoose'

export interface IScrapedMenuItem {
  name: string
  price: number
  originalPrice?: number // For discounts
  isVeg: boolean
  isAvailable: boolean
  image?: string
  description?: string
}

export interface IScrapedPrice extends Document {
  restaurantId: string
  restaurantName: string
  platform: 'swiggy' | 'zomato'
  scrapedAt: Date
  menuItems: IScrapedMenuItem[]
  metadata: {
    url: string
    scrapeDuration: number // milliseconds
    success: boolean
    errorMessage?: string
    scrapeMethod?: 'jina' | 'firecrawl' // Track which scraper was used
  }
}

const ScrapedMenuItemSchema = new Schema({
  name: { type: String, required: true },
  price: { type: Number, required: true },
  originalPrice: { type: Number },
  isVeg: { type: Boolean, required: true },
  isAvailable: { type: Boolean, default: true },
  image: { type: String },
  description: { type: String }
}, { _id: false })

const ScrapedPriceSchema = new Schema({
  restaurantId: { type: String, required: true, index: true },
  restaurantName: { type: String, required: true },
  platform: { 
    type: String, 
    required: true, 
    enum: ['swiggy', 'zomato'],
    index: true 
  },
  scrapedAt: { type: Date, default: Date.now, index: true },
  menuItems: [ScrapedMenuItemSchema],
  metadata: {
    url: { type: String, required: true },
    scrapeDuration: { type: Number },
    success: { type: Boolean, default: true },
    errorMessage: { type: String },
    scrapeMethod: { type: String, enum: ['jina', 'firecrawl'] }
  }
}, { timestamps: true })

// Compound index for efficient lookups
ScrapedPriceSchema.index({ restaurantId: 1, platform: 1, scrapedAt: -1 })

// TTL index - auto-delete after 7 days
ScrapedPriceSchema.index({ scrapedAt: 1 }, { expireAfterSeconds: 604800 })

export default mongoose.models.ScrapedPrice || 
  mongoose.model<IScrapedPrice>('ScrapedPrice', ScrapedPriceSchema)
