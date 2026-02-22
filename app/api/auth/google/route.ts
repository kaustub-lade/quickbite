import { NextRequest } from 'next/server';
import connectDB from '@/lib/mongodb';
import User from '@/lib/models/User';

// POST /api/auth/google - Google Sign-In
export async function POST(req: NextRequest) {
  try {
    await connectDB();

    const body = await req.json();
    const { idToken, googleId, email, name, photoUrl } = body;

    if (!email || !googleId) {
      return Response.json(
        { success: false, error: 'Email and Google ID are required' },
        { status: 400 }
      );
    }

    // Check if user already exists
    let user = await User.findOne({ email });

    if (user) {
      // Update Google ID if not set
      if (!user.googleId) {
        user.googleId = googleId;
        user.profilePicture = photoUrl || user.profilePicture;
        await user.save();
      }
    } else {
      // Create new user
      user = new User({
        name: name || email.split('@')[0],
        email,
        googleId,
        profilePicture: photoUrl,
        role: 'customer',
        phone: '', // Optional: Can be collected later
        password: '', // No password for Google sign-in users
      });

      await user.save();
    }

    // Generate token (simplified JWT alternative - matching login pattern)
    const token = Buffer.from(JSON.stringify({
      userId: user._id,
      email: user.email,
      exp: Date.now() + (7 * 24 * 60 * 60 * 1000) // 7 days
    })).toString('base64');

    return Response.json({
      success: true,
      token,
      user: {
        id: user._id.toString(),
        name: user.name,
        email: user.email,
        phone: user.phone,
        role: user.role,
        profilePicture: user.profilePicture,
      },
    });
  } catch (error: any) {
    console.error('Google sign-in error:', error);
    return Response.json(
      { success: false, error: 'Google sign-in failed' },
      { status: 500 }
    );
  }
}
