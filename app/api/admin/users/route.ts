import { NextRequest, NextResponse } from 'next/server'
import dbConnect from '@/lib/mongodb'
import User from '@/lib/models/User'
import { requireAdmin } from '@/lib/middleware/auth'

export const dynamic = 'force-dynamic'

// GET /api/admin/users - Get all users
export async function GET(req: NextRequest) {
  try {
    await dbConnect()

    // Check admin authentication
    const { user, error, statusCode } = await requireAdmin(req)
    if (error) {
      return NextResponse.json(
        { success: false, message: error },
        { status: statusCode || 401 }
      )
    }

    const searchParams = req.nextUrl.searchParams
    const role = searchParams.get('role')
    const page = parseInt(searchParams.get('page') || '1')
    const limit = parseInt(searchParams.get('limit') || '20')
    const skip = (page - 1) * limit

    // Build query
    const query: any = {}
    if (role) {
      query.role = role
    }

    // Get users
    const users = await User.find(query)
      .select('-password')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit)

    const total = await User.countDocuments(query)

    // Get role counts
    const roleCounts = await User.aggregate([
      {
        $group: {
          _id: '$role',
          count: { $sum: 1 },
        },
      },
    ])

    return NextResponse.json({
      success: true,
      data: {
        users,
        pagination: {
          page,
          limit,
          total,
          pages: Math.ceil(total / limit),
        },
        stats: {
          total: await User.countDocuments(),
          byRole: roleCounts.reduce((acc: any, item: any) => {
            acc[item._id] = item.count
            return acc
          }, {}),
        },
      },
    })
  } catch (error: any) {
    console.error('Error fetching users:', error)
    return NextResponse.json(
      { success: false, message: 'Failed to fetch users' },
      { status: 500 }
    )
  }
}

// POST /api/admin/users - Create new user (admin only)
export async function POST(req: NextRequest) {
  try {
    await dbConnect()

    // Check admin authentication
    const { user: adminUser, error, statusCode } = await requireAdmin(req)
    if (error) {
      return NextResponse.json(
        { success: false, message: error },
        { status: statusCode || 401 }
      )
    }

    const body = await req.json()
    const { name, email, phone, password, role, restaurantId } = body

    // Validation
    if (!name || !email || !phone || !password || !role) {
      return NextResponse.json(
        { success: false, message: 'All fields are required' },
        { status: 400 }
      )
    }

    // Check if user already exists
    const existingUser = await User.findOne({
      $or: [{ email: email.toLowerCase() }, { phone }],
    })

    if (existingUser) {
      return NextResponse.json(
        { success: false, message: 'User with this email or phone already exists' },
        { status: 409 }
      )
    }

    // Hash password (simple Base64 for demo - use bcrypt in production)
    const hashedPassword = Buffer.from(password).toString('base64')

    // Create user
    const newUser = await User.create({
      name,
      email: email.toLowerCase(),
      phone,
      password: hashedPassword,
      role,
      restaurantId: role === 'restaurant_owner' ? restaurantId : undefined,
      isEmailVerified: false,
    })

    const userResponse = newUser.toObject()
    delete userResponse.password

    return NextResponse.json({
      success: true,
      data: { user: userResponse },
      message: 'User created successfully',
    })
  } catch (error: any) {
    console.error('Error creating user:', error)
    return NextResponse.json(
      { success: false, message: 'Failed to create user' },
      { status: 500 }
    )
  }
}
