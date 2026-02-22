import { NextRequest } from 'next/server';
import connectDB from '@/lib/mongodb';
import { Favorite } from '@/lib/models/Favorite';
import { authenticateUser } from '@/lib/middleware/auth';

// GET - Get user's favorites
export async function GET(req: NextRequest) {
  try {
    const { user, error } = await authenticateUser(req);
    if (error || !user) {
      return Response.json({ error: error || 'Unauthorized' }, { status: 401 });
    }

    await connectDB();

    const { searchParams } = new URL(req.url);
    const itemType = searchParams.get('type'); // 'restaurant' or 'dish' or null for all

    const query: any = { userId: user.id };
    if (itemType && (itemType === 'restaurant' || itemType === 'dish')) {
      query.itemType = itemType;
    }

    const favorites = await Favorite.find(query).sort({ createdAt: -1 });

    return Response.json({
      success: true,
      favorites,
      count: favorites.length,
    });
  } catch (error: any) {
    console.error('Get favorites error:', error);
    return Response.json(
      { error: 'Failed to fetch favorites', details: error.message },
      { status: 500 }
    );
  }
}

// POST - Add to favorites
export async function POST(req: NextRequest) {
  try {
    const { user, error } = await authenticateUser(req);
    if (error || !user) {
      return Response.json({ error: error || 'Unauthorized' }, { status: 401 });
    }

    await connectDB();

    const body = await req.json();
    const { itemType, itemId, itemName, itemImage, restaurantId, restaurantName } = body;

    // Validation
    if (!itemType || !itemId || !itemName) {
      return Response.json(
        { error: 'Missing required fields: itemType, itemId, itemName' },
        { status: 400 }
      );
    }

    if (itemType !== 'restaurant' && itemType !== 'dish') {
      return Response.json(
        { error: 'itemType must be "restaurant" or "dish"' },
        { status: 400 }
      );
    }

    if (itemType === 'dish' && !restaurantId) {
      return Response.json(
        { error: 'restaurantId required for dish favorites' },
        { status: 400 }
      );
    }

    // Check if already favorited
    const existing = await Favorite.findOne({
      userId: user.id,
      itemType,
      itemId,
    });

    if (existing) {
      return Response.json(
        { error: 'Item already in favorites', favorite: existing },
        { status: 409 }
      );
    }

    // Create favorite
    const favorite = await Favorite.create({
      userId: user.id,
      itemType,
      itemId,
      itemName,
      itemImage,
      restaurantId,
      restaurantName,
    });

    return Response.json({
      success: true,
      message: 'Added to favorites',
      favorite,
    }, { status: 201 });
  } catch (error: any) {
    console.error('Add favorite error:', error);
    
    // Handle duplicate key error
    if (error.code === 11000) {
      return Response.json(
        { error: 'Item already in favorites' },
        { status: 409 }
      );
    }

    return Response.json(
      { error: 'Failed to add favorite', details: error.message },
      { status: 500 }
    );
  }
}

// DELETE - Remove from favorites
export async function DELETE(req: NextRequest) {
  try {
    const { user, error } = await authenticateUser(req);
    if (error || !user) {
      return Response.json({ error: error || 'Unauthorized' }, { status: 401 });
    }

    await connectDB();

    const { searchParams } = new URL(req.url);
    const favoriteId = searchParams.get('id');
    const itemType = searchParams.get('itemType');
    const itemId = searchParams.get('itemId');

    // Can delete by favorite ID or by itemType + itemId
    let query: any = { userId: user.id };

    if (favoriteId) {
      query._id = favoriteId;
    } else if (itemType && itemId) {
      query.itemType = itemType;
      query.itemId = itemId;
    } else {
      return Response.json(
        { error: 'Provide either "id" or both "itemType" and "itemId"' },
        { status: 400 }
      );
    }

    const deleted = await Favorite.findOneAndDelete(query);

    if (!deleted) {
      return Response.json({ error: 'Favorite not found' }, { status: 404 });
    }

    return Response.json({
      success: true,
      message: 'Removed from favorites',
      favorite: deleted,
    });
  } catch (error: any) {
    console.error('Delete favorite error:', error);
    return Response.json(
      { error: 'Failed to remove favorite', details: error.message },
      { status: 500 }
    );
  }
}
