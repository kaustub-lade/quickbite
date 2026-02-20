import { NextRequest } from 'next/server'
import User from '../models/User'

export interface AuthRequest extends NextRequest {
  user?: {
    userId: string
    email: string
    role: string
  }
}

export async function authenticateUser(req: NextRequest): Promise<{ user: any; error?: string }> {
  try {
    const authHeader = req.headers.get('authorization')
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return { user: null, error: 'No authorization token provided' }
    }

    const token = authHeader.substring(7)
    
    // Decode the token (Base64 for now)
    const decoded = JSON.parse(Buffer.from(token, 'base64').toString())
    
    // Check if token is expired
    if (decoded.exp < Date.now()) {
      return { user: null, error: 'Token expired' }
    }

    // Get user from database
    const user = await User.findById(decoded.userId).select('-password')
    
    if (!user) {
      return { user: null, error: 'User not found' }
    }

    return { user }
  } catch (error) {
    return { user: null, error: 'Invalid token' }
  }
}

export async function requireAdmin(req: NextRequest): Promise<{ user: any; error?: string; statusCode?: number }> {
  const { user, error } = await authenticateUser(req)
  
  if (error || !user) {
    return { user: null, error: error || 'Unauthorized', statusCode: 401 }
  }

  if (user.role !== 'admin') {
    return { user: null, error: 'Admin access required', statusCode: 403 }
  }

  return { user }
}

export async function requireRestaurantOwner(req: NextRequest): Promise<{ user: any; error?: string; statusCode?: number }> {
  const { user, error } = await authenticateUser(req)
  
  if (error || !user) {
    return { user: null, error: error || 'Unauthorized', statusCode: 401 }
  }

  if (user.role !== 'restaurant_owner' && user.role !== 'admin') {
    return { user: null, error: 'Restaurant owner access required', statusCode: 403 }
  }

  return { user }
}
