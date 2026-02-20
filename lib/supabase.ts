import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('Missing Supabase environment variables. Check your .env.local file.')
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey)

// Database types (will be expanded as we build)
export type Restaurant = {
  id: string
  name: string
  cuisine: string
  location: string
  latitude?: number
  longitude?: number
  rating?: number
  image_url?: string
  created_at: string
}

export type Platform = {
  id: string
  name: string
  display_name: string
  logo_url?: string
  deep_link_template?: string
}

export type RestaurantPrice = {
  id: string
  restaurant_id: string
  platform_id: string
  base_price: number
  delivery_fee: number
  platform_fee: number
  estimated_total: number
  delivery_time_min: number
  is_scraped: boolean
  last_updated: string
}
