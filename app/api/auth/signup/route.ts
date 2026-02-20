import { NextRequest, NextResponse } from 'next/server'
import connectDB from '@/lib/mongodb'
import User from '@/lib/models/User'

// Simple hash function (in production, use bcrypt)
function simpleHash(password: string): string {
  return Buffer.from(password).toString('base64')
}

function simpleVerify(password: string, hash: string): boolean {
  return simpleHash(password) === hash
}

export async function POST(request: NextRequest) {
  try {
    await connectDB()

    const { name, email, phone, password } = await request.json()

    // Validate input
    if (!name || !email || !phone || !password) {
      return NextResponse.json(
        { success: false, error: 'All fields are required' },
        { status: 400 }
      )
    }

    // Check if user already exists
    const existingUser = await User.findOne({
      $or: [{ email }, { phone }],
    })

    if (existingUser) {
      return NextResponse.json(
        { 
          success: false, 
          error: existingUser.email === email 
            ? 'Email already registered' 
            : 'Phone number already registered' 
        },
        { status: 409 }
      )
    }

    // Hash password (simplified)
    const hashedPassword = simpleHash(password)

    // Create user
    const user = await User.create({
      name,
      email,
      phone,
      password: hashedPassword,
      role: 'customer', // Default role for mobile app signups
      isEmailVerified: false,
    })

    // Generate token (simplified JWT alternative)
    const token = Buffer.from(JSON.stringify({
      userId: user._id,
      email: user.email,
      exp: Date.now() + (7 * 24 * 60 * 60 * 1000) // 7 days
    })).toString('base64')

    return NextResponse.json({
      success: true,
      data: {
        token,
        user: {
          id: user._id,
          name: user.name,
          email: user.email,
          phone: user.phone,
        },
      },
      message: 'Account created successfully',
    })
  } catch (error) {
    console.error('Signup error:', error)
    return NextResponse.json(
      {
        success: false,
        error: 'Failed to create account. Please try again.',
      },
      { status: 500 }
    )
  }
}
