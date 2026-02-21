import { NextRequest, NextResponse } from 'next/server';
import connectToDatabase from '@/lib/mongodb';
import Restaurant from '@/lib/models/Restaurant';
import MenuItem from '@/lib/models/MenuItem';
import { Order } from '@/lib/models/Order';

// GET /api/restaurants/popular - Get popular restaurants based on orders
export async function GET(req: NextRequest) {
  try {
    await connectToDatabase();

    // Get popular restaurants from orders
    const popularRestaurants = await Order.aggregate([
      {
        $group: {
          _id: '$restaurantId',
          orderCount: { $sum: 1 },
          totalRevenue: { $sum: '$totalAmount' },
        },
      },
      {
        $sort: { orderCount: -1 },
      },
      {
        $limit: 10,
      },
    ]);

    // If no orders yet, get all restaurants
    if (popularRestaurants.length === 0) {
      const allRestaurants = await Restaurant.find()
        .limit(10)
        .lean();

      const formattedRestaurants = allRestaurants.map((restaurant) => ({
        id: restaurant.restaurantId || restaurant._id.toString(),
        name: restaurant.name,
        cuisine: restaurant.cuisine || 'Multi-cuisine',
        rating: restaurant.rating || 4.0,
        deliveryTime: restaurant.deliveryTime || '30-40 mins',
        location: restaurant.location || 'Bangalore',
        image: restaurant.image || 'https://via.placeholder.com/300x200',
        orderCount: 0,
        totalRevenue: 0,
      }));

      return NextResponse.json({
        success: true,
        restaurants: formattedRestaurants,
      });
    }

    // Fetch restaurant details for popular restaurants
    const restaurantIds = popularRestaurants.map((r) => r._id);
    const restaurants = await Restaurant.find({
      $or: [
        { restaurantId: { $in: restaurantIds } },
        { _id: { $in: restaurantIds } },
      ],
    }).lean();

    // Map restaurant details with order stats
    const restaurantMap = new Map();
    restaurants.forEach((r) => {
      const id = r.restaurantId || r._id.toString();
      restaurantMap.set(id, r);
    });

    const popularWithDetails = popularRestaurants
      .map((stat) => {
        const restaurant = restaurantMap.get(stat._id);
        if (!restaurant) return null;

        return {
          id: restaurant.restaurantId || restaurant._id.toString(),
          name: restaurant.name,
          cuisine: restaurant.cuisine || 'Multi-cuisine',
          rating: restaurant.rating || 4.0,
          deliveryTime: restaurant.deliveryTime || '30-40 mins',
          location: restaurant.location || 'Bangalore',
          image: restaurant.image || 'https://via.placeholder.com/300x200',
          orderCount: stat.orderCount,
          totalRevenue: Math.round(stat.totalRevenue),
        };
      })
      .filter(Boolean);

    return NextResponse.json({
      success: true,
      restaurants: popularWithDetails,
    });
  } catch (error: any) {
    console.error('Error fetching popular restaurants:', error);
    return NextResponse.json(
      {
        success: false,
        error: error.message || 'Failed to fetch popular restaurants',
      },
      { status: 500 }
    );
  }
}
