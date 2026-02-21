import { NextRequest, NextResponse } from 'next/server';
import connectToDatabase from '@/lib/mongodb';
import Restaurant from '@/lib/models/Restaurant';

// GET /api/restaurants/stats - Get restaurant statistics by category
export async function GET(req: NextRequest) {
  try {
    await connectToDatabase();

    // Get all restaurants
    const restaurants = await Restaurant.find().lean();

    // Calculate category counts
    const categoryMap: { [key: string]: number } = {
      biryani: 0,
      pizza: 0,
      burger: 0,
      healthy: 0,
    };

    restaurants.forEach((restaurant) => {
      const cuisines = restaurant.cuisine?.toLowerCase() || '';
      const name = restaurant.name?.toLowerCase() || '';
      
      // Check for biryani
      if (name.includes('biryani') || cuisines.includes('biryani') || cuisines.includes('indian')) {
        categoryMap.biryani++;
      }
      
      // Check for pizza
      if (name.includes('pizza') || cuisines.includes('pizza') || cuisines.includes('italian')) {
        categoryMap.pizza++;
      }
      
      // Check for burger
      if (name.includes('burger') || cuisines.includes('burger') || cuisines.includes('american') || 
          name.includes('mcdonald') || name.includes('kfc')) {
        categoryMap.burger++;
      }
      
      // Check for healthy
      if (cuisines.includes('salad') || cuisines.includes('healthy') || name.includes('subway')) {
        categoryMap.healthy++;
      }
    });

    return NextResponse.json({
      success: true,
      stats: {
        totalRestaurants: restaurants.length,
        categoryCount: categoryMap,
        categories: [
          { value: 'biryani', label: 'Biryani', emoji: '🍛', count: categoryMap.biryani },
          { value: 'pizza', label: 'Pizza', emoji: '🍕', count: categoryMap.pizza },
          { value: 'burger', label: 'Burger', emoji: '🍔', count: categoryMap.burger },
          { value: 'healthy', label: 'Healthy', emoji: '🥗', count: categoryMap.healthy },
        ],
      },
    });
  } catch (error: any) {
    console.error('Error fetching restaurant stats:', error);
    return NextResponse.json(
      {
        success: false,
        error: error.message || 'Failed to fetch restaurant stats',
      },
      { status: 500 }
    );
  }
}
