import { NextRequest, NextResponse } from 'next/server'
import connectDB from '@/lib/mongodb'
import MenuItem from '@/lib/models/MenuItem'

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ restaurantId: string }> }
) {
  try {
    await connectDB()

    const { restaurantId } = await params
    const { searchParams } = new URL(request.url)
    const category = searchParams.get('category')
    const isVeg = searchParams.get('isVeg')

    // Build query
    const query: any = { restaurantId, isAvailable: true }
    
    if (category && category !== 'All') {
      query.category = category
    }
    
    if (isVeg === 'true') {
      query.isVeg = true
    }

    // Fetch menu items
    const menuItems = await MenuItem.find(query)
      .sort({ category: 1, name: 1 })
      .lean()

    // Get unique categories for this restaurant
    const categories = await MenuItem.distinct('category', { 
      restaurantId, 
      isAvailable: true 
    })

    return NextResponse.json({
      success: true,
      data: {
        menuItems,
        categories: ['All', ...categories],
      },
    })
  } catch (error) {
    console.error('Menu API Error:', error)
    return NextResponse.json(
      {
        success: false,
        error: 'Failed to fetch menu items',
      },
      { status: 500 }
    )
  }
}
