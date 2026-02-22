import { NextRequest, NextResponse } from 'next/server';
import connectToDatabase from '@/lib/mongodb';
import MenuItem from '@/lib/models/MenuItem';
import Restaurant from '@/lib/models/Restaurant';

// GET /api/menu/trending - Get trending menu items
export async function GET(req: NextRequest) {
  try {
    await connectToDatabase();

    // For now, just return some menu items
    // TODO: In future, use Order data to show truly trending items
    const menuItems = await MenuItem.find()
      .limit(10)
      .lean();

    if (menuItems.length === 0) {
      return NextResponse.json({
        success: true,
        items: [],
      });
    }

    const restaurantIds = [...new Set(menuItems.map((item: any) => item.restaurantId))];
    const restaurants = await Restaurant.find({
      restaurantId: { $in: restaurantIds },
    }).lean();

    const restaurantMap = new Map();
    restaurants.forEach((r: any) => {
      const id = r.restaurantId || r._id.toString();
      restaurantMap.set(id, r);
    });

    const formattedItems = menuItems.map((item: any) => {
      const restaurant = restaurantMap.get(item.restaurantId);
      return {
        id: item._id.toString(),
        name: item.name,
        description: item.description || '',
        price: item.price,
        isVeg: item.isVeg,
        restaurant: restaurant
          ? {
              id: restaurant.restaurantId || restaurant._id.toString(),
              name: restaurant.name,
            }
          : null,
        orderCount: 0,
        platform: 'QuickBite',
      };
    });

    return NextResponse.json({
      success: true,
      items: formattedItems,
    });
  } catch (error: any) {
    console.error('Error fetching trending items:', error);
    return NextResponse.json(
      {
        success: false,
        error: error.message || 'Failed to fetch trending items',
      },
      { status: 500 }
    );
  }
}
