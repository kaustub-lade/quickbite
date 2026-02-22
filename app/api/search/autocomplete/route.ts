import { NextRequest } from 'next/server'
import connectDB from '@/lib/mongodb'
import Restaurant from '@/lib/models/Restaurant'
import MenuItem from '@/lib/models/MenuItem'

export async function GET(req: NextRequest) {
  try {
    await connectDB()

    const searchParams = req.nextUrl.searchParams
    const query = searchParams.get('q') || ''
    const limit = parseInt(searchParams.get('limit') || '10')

    if (!query || query.length < 2) {
      return Response.json({
        success: true,
        suggestions: [],
        message: 'Query too short - need at least 2 characters',
      })
    }

    // Search in restaurants (name and cuisine)
    const restaurantMatches = await Restaurant.find({
      $or: [
        { name: { $regex: query, $options: 'i' } },
        { cuisine: { $regex: query, $options: 'i' } },
      ],
    })
      .select('name cuisine')
      .limit(limit)
      .lean()

    // Search in menu items (name and category)
    const menuItemMatches = await MenuItem.find({
      $or: [
        { name: { $regex: query, $options: 'i' } },
        { category: { $regex: query, $options: 'i' } },
      ],
    })
      .select('name category')
      .limit(limit)
      .lean()

    // Format suggestions
    const restaurantSuggestions = restaurantMatches.map((r: any) => ({
      type: 'restaurant',
      text: r.name,
      subtitle: r.cuisine,
      id: r._id,
    }))

    const menuItemSuggestions = menuItemMatches.map((m: any) => ({
      type: 'dish',
      text: m.name,
      subtitle: m.category,
      id: m._id,
    }))

    // Popular cuisines matching query
    const cuisines = ['Biryani', 'Pizza', 'Burger', 'Chinese', 'South Indian', 'North Indian', 'Italian', 'Mexican']
    const cuisineSuggestions = cuisines
      .filter(c => c.toLowerCase().includes(query.toLowerCase()))
      .map(c => ({
        type: 'cuisine',
        text: c,
        subtitle: 'Cuisine',
        id: c.toLowerCase(),
      }))

    // Combine and deduplicate
    const allSuggestions = [
      ...restaurantSuggestions,
      ...menuItemSuggestions,
      ...cuisineSuggestions,
    ].slice(0, limit)

    return Response.json({
      success: true,
      suggestions: allSuggestions,
      count: allSuggestions.length,
    })
  } catch (error: any) {
    console.error('Error fetching autocomplete suggestions:', error)
    return Response.json(
      {
        success: false,
        error: 'Failed to fetch suggestions',
        message: error.message,
      },
      { status: 500 }
    )
  }
}
