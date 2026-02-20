import { NextRequest, NextResponse } from 'next/server'
import dbConnect from '@/lib/mongodb'
import Restaurant from '@/lib/models/Restaurant'
import { requireAdmin } from '@/lib/middleware/auth'

export const dynamic = 'force-dynamic'

// GET /api/admin/restaurants - Get all restaurants
export async function GET(req: NextRequest) {
  try {
    await dbConnect()

    const { user, error, statusCode } = await requireAdmin(req)
    if (error) {
      return NextResponse.json(
        { success: false, message: error },
        { status: statusCode || 401 }
      )
    }

    const restaurants = await Restaurant.find().sort({ name: 1 })

    return NextResponse.json({
      success: true,
      data: { restaurants },
    })
  } catch (error: any) {
    console.error('Error fetching restaurants:', error)
    return NextResponse.json(
      { success: false, message: 'Failed to fetch restaurants' },
      { status: 500 }
    )
  }
}

// POST /api/admin/restaurants - Create new restaurant
export async function POST(req: NextRequest) {
  try {
    await dbConnect()

    const { user, error, statusCode } = await requireAdmin(req)
    if (error) {
      return NextResponse.json(
        { success: false, message: error },
        { status: statusCode || 401 }
      )
    }

    const body = await req.json()
    const { id, name, cuisine, location, rating, imageUrl } = body

    if (!id || !name || !cuisine || !location) {
      return NextResponse.json(
        { success: false, message: 'Missing required fields' },
        { status: 400 }
      )
    }

    // Check if restaurant already exists
    const existing = await Restaurant.findOne({ id })
    if (existing) {
      return NextResponse.json(
        { success: false, message: 'Restaurant with this ID already exists' },
        { status: 409 }
      )
    }

    const restaurant = await Restaurant.create({
      id,
      name,
      cuisine,
      location,
      rating: rating || 0,
      imageUrl,
    })

    return NextResponse.json({
      success: true,
      data: { restaurant },
      message: 'Restaurant created successfully',
    })
  } catch (error: any) {
    console.error('Error creating restaurant:', error)
    return NextResponse.json(
      { success: false, message: 'Failed to create restaurant' },
      { status: 500 }
    )
  }
}
