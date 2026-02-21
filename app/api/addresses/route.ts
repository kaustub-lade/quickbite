import { NextRequest } from 'next/server'
import connectToDatabase from '@/lib/mongodb'
import Address from '@/lib/models/Address'

/**
 * GET /api/addresses?userId=xxx
 * Get all saved addresses for a user
 */
export async function GET(req: NextRequest) {
  try {
    await connectToDatabase()

    const { searchParams } = new URL(req.url)
    const userId = searchParams.get('userId')

    if (!userId) {
      return Response.json(
        { success: false, message: 'User ID is required' },
        { status: 400 }
      )
    }

    // Get all addresses for this user, sorted by default first, then by creation date
    const addresses = await Address.find({ userId })
      .sort({ isDefault: -1, createdAt: -1 })
      .lean()

    return Response.json({
      success: true,
      addresses: addresses.map(addr => ({
        id: addr._id,
        userId: addr.userId,
        label: addr.label,
        customLabel: addr.customLabel,
        address: addr.address,
        landmark: addr.landmark,
        city: addr.city,
        pincode: addr.pincode,
        phone: addr.phone,
        isDefault: addr.isDefault,
        createdAt: addr.createdAt,
      })),
    })
  } catch (error) {
    console.error('Get Addresses Error:', error)
    return Response.json(
      {
        success: false,
        message: 'Failed to fetch addresses',
        error: error instanceof Error ? error.message : 'Unknown error',
      },
      { status: 500 }
    )
  }
}

/**
 * POST /api/addresses
 * Create a new address
 */
export async function POST(req: NextRequest) {
  try {
    await connectToDatabase()

    const body = await req.json()
    const { userId, label, customLabel, address, landmark, city, pincode, phone, isDefault } = body

    // Validation
    if (!userId || !label || !address || !city || !pincode || !phone) {
      return Response.json(
        { success: false, message: 'Required fields are missing' },
        { status: 400 }
      )
    }

    // Validate pincode format
    if (!/^[0-9]{6}$/.test(pincode)) {
      return Response.json(
        { success: false, message: 'Invalid pincode format (must be 6 digits)' },
        { status: 400 }
      )
    }

    // Validate phone format
    if (!/^[0-9]{10}$/.test(phone)) {
      return Response.json(
        { success: false, message: 'Invalid phone format (must be 10 digits)' },
        { status: 400 }
      )
    }

    // If setting as default, unset other defaults
    if (isDefault) {
      await Address.updateMany(
        { userId, isDefault: true },
        { $set: { isDefault: false } }
      )
    }

    // Create new address
    const newAddress = await Address.create({
      userId,
      label,
      customLabel: label === 'Other' ? customLabel : undefined,
      address,
      landmark,
      city,
      pincode,
      phone,
      isDefault: isDefault || false,
    })

    return Response.json(
      {
        success: true,
        message: 'Address saved successfully',
        address: {
          id: newAddress._id,
          userId: newAddress.userId,
          label: newAddress.label,
          customLabel: newAddress.customLabel,
          address: newAddress.address,
          landmark: newAddress.landmark,
          city: newAddress.city,
          pincode: newAddress.pincode,
          phone: newAddress.phone,
          isDefault: newAddress.isDefault,
        },
      },
      { status: 201 }
    )
  } catch (error) {
    console.error('Create Address Error:', error)
    return Response.json(
      {
        success: false,
        message: 'Failed to save address',
        error: error instanceof Error ? error.message : 'Unknown error',
      },
      { status: 500 }
    )
  }
}

/**
 * PATCH /api/addresses
 * Update an existing address
 */
export async function PATCH(req: NextRequest) {
  try {
    await connectToDatabase()

    const body = await req.json()
    const { addressId, label, customLabel, address, landmark, city, pincode, phone, isDefault } = body

    if (!addressId) {
      return Response.json(
        { success: false, message: 'Address ID is required' },
        { status: 400 }
      )
    }

    // Find the address
    const existingAddress = await Address.findById(addressId)
    if (!existingAddress) {
      return Response.json(
        { success: false, message: 'Address not found' },
        { status: 404 }
      )
    }

    // If setting as default, unset other defaults for this user
    if (isDefault && !existingAddress.isDefault) {
      await Address.updateMany(
        { userId: existingAddress.userId, isDefault: true },
        { $set: { isDefault: false } }
      )
    }

    // Update the address
    const updatedAddress = await Address.findByIdAndUpdate(
      addressId,
      {
        $set: {
          ...(label && { label }),
          ...(label === 'Other' && customLabel && { customLabel }),
          ...(address && { address }),
          ...(landmark !== undefined && { landmark }),
          ...(city && { city }),
          ...(pincode && { pincode }),
          ...(phone && { phone }),
          ...(isDefault !== undefined && { isDefault }),
        },
      },
      { new: true, runValidators: true }
    )

    return Response.json({
      success: true,
      message: 'Address updated successfully',
      address: {
        id: updatedAddress!._id,
        userId: updatedAddress!.userId,
        label: updatedAddress!.label,
        customLabel: updatedAddress!.customLabel,
        address: updatedAddress!.address,
        landmark: updatedAddress!.landmark,
        city: updatedAddress!.city,
        pincode: updatedAddress!.pincode,
        phone: updatedAddress!.phone,
        isDefault: updatedAddress!.isDefault,
      },
    })
  } catch (error) {
    console.error('Update Address Error:', error)
    return Response.json(
      {
        success: false,
        message: 'Failed to update address',
        error: error instanceof Error ? error.message : 'Unknown error',
      },
      { status: 500 }
    )
  }
}

/**
 * DELETE /api/addresses?addressId=xxx
 * Delete an address
 */
export async function DELETE(req: NextRequest) {
  try {
    await connectToDatabase()

    const { searchParams } = new URL(req.url)
    const addressId = searchParams.get('addressId')

    if (!addressId) {
      return Response.json(
        { success: false, message: 'Address ID is required' },
        { status: 400 }
      )
    }

    const deletedAddress = await Address.findByIdAndDelete(addressId)

    if (!deletedAddress) {
      return Response.json(
        { success: false, message: 'Address not found' },
        { status: 404 }
      )
    }

    return Response.json({
      success: true,
      message: 'Address deleted successfully',
    })
  } catch (error) {
    console.error('Delete Address Error:', error)
    return Response.json(
      {
        success: false,
        message: 'Failed to delete address',
        error: error instanceof Error ? error.message : 'Unknown error',
      },
      { status: 500 }
    )
  }
}
