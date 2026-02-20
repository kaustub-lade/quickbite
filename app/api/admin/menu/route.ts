import { NextRequest, NextResponse } from 'next/server'
import dbConnect from '@/lib/mongodb'
import MenuItem from '@/lib/models/MenuItem'
import { requireAdmin, requireRestaurantOwner } from '@/lib/middleware/auth'

export const dynamic = 'force-dynamic'

// GET /api/admin/menu - Get all menu items
export async function GET(req: NextRequest) {
  try {
    await dbConnect()

    const { user, error, statusCode } = await requireRestaurantOwner(req)
    if (error) {
      return NextResponse.json(
        { success: false, message: error },
        { status: statusCode || 401 }
      )
    }

    const searchParams = req.nextUrl.searchParams
    const restaurantId = searchParams.get('restaurantId')

    // Build query
    const query: any = {}
    
    // If user is restaurant owner (not admin), only show their items
    if (user.role === 'restaurant_owner') {
      query.restaurantId = user.restaurantId
    } else if (restaurantId) {
      // Admin can filter by restaurant
      query.restaurantId = restaurantId
    }

    const menuItems = await MenuItem.find(query).sort({ restaurantId: 1, category: 1, name: 1 })

    return NextResponse.json({
      success: true,
      data: { menuItems, count: menuItems.length },
    })
  } catch (error: any) {
    console.error('Error fetching menu items:', error)
    return NextResponse.json(
      { success: false, message: 'Failed to fetch menu items' },
      { status: 500 }
    )
  }
}

// POST /api/admin/menu - Create new menu item
export async function POST(req: NextRequest) {
  try {
    await dbConnect()

    const { user, error, statusCode } = await requireRestaurantOwner(req)
    if (error) {
      return NextResponse.json(
        { success: false, message: error },
        { status: statusCode || 401 }
      )
    }

    const body = await req.json()
    let { restaurantId, name, description, price, category, isVeg, imageUrl, isAvailable, preparationTime, spiceLevel, tags } = body

    // If user is restaurant owner, force their restaurantId
    if (user.role === 'restaurant_owner') {
      restaurantId = user.restaurantId
    }

    if (!restaurantId || !name || !price || !category) {
      return NextResponse.json(
        { success: false, message: 'Missing required fields' },
        { status: 400 }
      )
    }

    const menuItem = await MenuItem.create({
      restaurantId,
      name,
      description,
      price,
      category,
      isVeg: isVeg !== undefined ? isVeg : true,
      imageUrl,
      isAvailable: isAvailable !== undefined ? isAvailable : true,
      preparationTime,
      spiceLevel,
      tags: tags || [],
    })

    return NextResponse.json({
      success: true,
      data: { menuItem },
      message: 'Menu item created successfully',
    })
  } catch (error: any) {
    console.error('Error creating menu item:', error)
    return NextResponse.json(
      { success: false, message: 'Failed to create menu item' },
      { status: 500 }
    )
  }
}

// DELETE /api/admin/menu - Delete menu item
export async function DELETE(req: NextRequest) {
  try {
    await dbConnect()

    const { user, error, statusCode } = await requireRestaurantOwner(req)
    if (error) {
      return NextResponse.json(
        { success: false, message: error },
        { status: statusCode || 401 }
      )
    }

    const searchParams = req.nextUrl.searchParams
    const itemId = searchParams.get('itemId')

    if (!itemId) {
      return NextResponse.json(
        { success: false, message: 'Item ID is required' },
        { status: 400 }
      )
    }

    // Check if item exists
    const menuItem = await MenuItem.findById(itemId)
    if (!menuItem) {
      return NextResponse.json(
        { success: false, message: 'Menu item not found' },
        { status: 404 }
      )
    }

    // Ensure restaurant owner can only delete their own items
    if (user.role === 'restaurant_owner' && menuItem.restaurantId !== user.restaurantId) {
      return NextResponse.json(
        { success: false, message: 'You can only delete your own menu items' },
        { status: 403 }
      )
    }

    await MenuItem.findByIdAndDelete(itemId)

    return NextResponse.json({
      success: true,
      message: 'Menu item deleted successfully',
    })
  } catch (error: any) {
    console.error('Error deleting menu item:', error)
    return NextResponse.json(
      { success: false, message: 'Failed to delete menu item' },
      { status: 500 }
    )
  }
}
