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
      $or: [
        { restaurantId: { $in: restaurantIds } },
        { _id: { $in: restaurantIds } },
      ],
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


// GET /api/menu/trending - Get trending menu items based on orders
export async function GET(req: NextRequest) {
  try {
    await connectToDatabase();

    // For now, just return some menu items until we have orders
    // In future, this will use order data to show truly trending items
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
      $or: [
        { restaurantId: { $in: restaurantIds } },
        { _id: { $in: restaurantIds } },
      ],
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
        orderCount: 0, // Will be populated from actual orders in future
        platform: 'QuickBite',
      };
    });

    return NextResponse.json({
      success: true,
      items: formattedItems,
    });

      const restaurantMap = new Map();
      restaurants.forEach((r) => {
        const id = r.restaurantId || r._id.toString();
        restaurantMap.set(id, r);
      });

      const formattedItems = menuItems.map((item) => {
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
    }

    // Fetch menu item and restaurant details
    const menuItemIds = trendingItems.map((item) => item._id).filter(Boolean);
    const menuItems = await MenuItem.find({
      _id: { $in: menuItemIds },
    }).lean();

    const restaurantIds = [...new Set(menuItems.map((item) => item.restaurantId))];
    const restaurants = await Restaurant.find({
      $or: [
        { restaurantId: { $in: restaurantIds } },
        { _id: { $in: restaurantIds } },
      ],
    }).lean();

    const restaurantMap = new Map();
    restaurants.forEach((r) => {
      const id = r.restaurantId || r._id.toString();
      restaurantMap.set(id, r);
    });

    const menuItemMap = new Map();
    menuItems.forEach((item) => {
      menuItemMap.set(item._id.toString(), item);
    });

    const trendingWithDetails = trendingItems
      .map((stat) => {
        const menuItem = menuItemMap.get(stat._id?.toString());
        if (!menuItem) {
          // Use data from order items if menu item not found
          const restaurant = restaurantMap.get(stat.restaurantId);
          return {
            id: stat._id?.toString() || 'unknown',
            name: stat.itemName,
            description: '',
            price: stat.price,
            isVeg: stat.isVeg,
            restaurant: restaurant
              ? {
                  id: restaurant.restaurantId || restaurant._id.toString(),
                  name: restaurant.name,
                }
              : null,
            orderCount: stat.orderCount,
            platform: stat.platform || 'QuickBite',
          };
        }

        const restaurant = restaurantMap.get(menuItem.restaurantId);

        return {
          id: menuItem._id.toString(),
          name: menuItem.name,
          description: menuItem.description || '',
          price: stat.price || menuItem.price,
          isVeg: menuItem.isVeg,
          restaurant: restaurant
            ? {
                id: restaurant.restaurantId || restaurant._id.toString(),
                name: restaurant.name,
              }
            : null,
          orderCount: stat.orderCount,
          platform: stat.platform || 'QuickBite',
        };
      })
      .filter(Boolean);

    return NextResponse.json({
      success: true,
      items: trendingWithDetails,
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
