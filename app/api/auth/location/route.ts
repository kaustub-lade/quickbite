import { NextRequest, NextResponse } from 'next/server';
import connectToDatabase from '@/lib/mongodb';
import User from '@/lib/models/User';
import { authenticateUser } from '@/lib/middleware/auth';

export async function PATCH(req: NextRequest) {
  try {
    await connectToDatabase();

    // Authenticate user
    const authResult = await authenticateUser(req);
    if (!authResult.user) {
      return NextResponse.json(
        { success: false, error: 'Authentication required' },
        { status: 401 }
      );
    }

    const body = await req.json();
    const { latitude, longitude, address } = body;

    // Validate required fields
    if (latitude === undefined || longitude === undefined) {
      return NextResponse.json(
        { success: false, error: 'Latitude and longitude are required' },
        { status: 400 }
      );
    }

    // Validate coordinates
    if (
      typeof latitude !== 'number' ||
      typeof longitude !== 'number' ||
      latitude < -90 ||
      latitude > 90 ||
      longitude < -180 ||
      longitude > 180
    ) {
      return NextResponse.json(
        { success: false, error: 'Invalid coordinates' },
        { status: 400 }
      );
    }

    // Update user location
    const updatedUser = await User.findByIdAndUpdate(
      authResult.user.id,
      {
        $set: {
          'location.latitude': latitude,
          'location.longitude': longitude,
          'location.address': address || '',
          'location.lastUpdated': new Date(),
        },
      },
      { new: true, runValidators: true }
    ).select('-password');

    if (!updatedUser) {
      return NextResponse.json(
        { success: false, error: 'User not found' },
        { status: 404 }
      );
    }

    return NextResponse.json({
      success: true,
      user: updatedUser,
      message: 'Location updated successfully',
    });
  } catch (error: any) {
    console.error('Location update error:', error);
    return NextResponse.json(
      { success: false, error: error.message || 'Failed to update location' },
      { status: 500 }
    );
  }
}
