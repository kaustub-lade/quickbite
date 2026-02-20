import connectDB from '../lib/mongodb'
import { Restaurant, Platform, RestaurantPrice } from '../lib/models'

async function seedDatabase() {
  try {
    console.log('🌱 Starting database seed...')
    
    // Connect to MongoDB
    await connectDB()
    console.log('✅ Connected to MongoDB')

    // Clear existing data
    await Promise.all([
      Restaurant.deleteMany({}),
      Platform.deleteMany({}),
      RestaurantPrice.deleteMany({})
    ])
    console.log('🗑️  Cleared existing data')

    // Insert Platforms
    console.log('\n📦 Inserting platforms...')
    const platforms = await Platform.insertMany([
      { name: 'Swiggy', commission_rate: 25 },
      { name: 'Zomato', commission_rate: 23 },
      { name: 'ONDC', commission_rate: 5 }
    ])
    console.log(`✅ Inserted ${platforms.length} platforms`)

    const [swiggy, zomato, ondc] = platforms

    // Insert Restaurants
    console.log('\n🍽️  Inserting restaurants...')
    const restaurants = await Restaurant.insertMany([
      {
        name: 'Paradise Biryani',
        cuisine: 'Biryani',
        location: 'Koramangala, Bangalore',
        rating: 4.3,
        image_url: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=400'
      },
      {
        name: 'Meghana Foods',
        cuisine: 'Biryani',
        location: 'Indiranagar, Bangalore',
        rating: 4.5,
        image_url: 'https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=400'
      },
      {
        name: 'Empire Restaurant',
        cuisine: 'Biryani',
        location: 'Jayanagar, Bangalore',
        rating: 4.6,
        image_url: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=400'
      },
      {
        name: "Domino's Pizza",
        cuisine: 'Pizza',
        location: 'HSR Layout, Bangalore',
        rating: 4.2,
        image_url: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400'
      },
      {
        name: 'Pizza Hut',
        cuisine: 'Pizza',
        location: 'Whitefield, Bangalore',
        rating: 4.1,
        image_url: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400'
      },
      {
        name: "McDonald's",
        cuisine: 'Burger',
        location: 'MG Road, Bangalore',
        rating: 4.0,
        image_url: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400'
      },
      {
        name: 'Burger King',
        cuisine: 'Burger',
        location: 'Brigade Road, Bangalore',
        rating: 4.1,
        image_url: 'https://images.unsplash.com/photo-1550547660-d9450f859349?w=400'
      },
      {
        name: 'Greens & Proteins',
        cuisine: 'Healthy',
        location: 'Electronic City, Bangalore',
        rating: 4.4,
        image_url: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400'
      }
    ])
    console.log(`✅ Inserted ${restaurants.length} restaurants`)

    // Insert Restaurant Prices
    console.log('\n💰 Inserting pricing data...')
    const prices = []

    // Paradise Biryani pricing
    prices.push(
      {
        restaurant_id: restaurants[0]._id,
        platform_id: ondc._id,
        item_name: 'Chicken Biryani',
        price: 280,
        delivery_time_mins: 35
      },
      {
        restaurant_id: restaurants[0]._id,
        platform_id: swiggy._id,
        item_name: 'Chicken Biryani',
        price: 365,
        delivery_time_mins: 30
      },
      {
        restaurant_id: restaurants[0]._id,
        platform_id: zomato._id,
        item_name: 'Chicken Biryani',
        price: 350,
        delivery_time_mins: 32
      }
    )

    // Meghana Foods pricing
    prices.push(
      {
        restaurant_id: restaurants[1]._id,
        platform_id: swiggy._id,
        item_name: 'Mutton Biryani',
        price: 345,
        delivery_time_mins: 22
      },
      {
        restaurant_id: restaurants[1]._id,
        platform_id: zomato._id,
        item_name: 'Mutton Biryani',
        price: 360,
        delivery_time_mins: 25
      },
      {
        restaurant_id: restaurants[1]._id,
        platform_id: ondc._id,
        item_name: 'Mutton Biryani',
        price: 320,
        delivery_time_mins: 28
      }
    )

    // Empire Restaurant pricing
    prices.push(
      {
        restaurant_id: restaurants[2]._id,
        platform_id: zomato._id,
        item_name: 'Special Biryani',
        price: 365,
        delivery_time_mins: 28
      },
      {
        restaurant_id: restaurants[2]._id,
        platform_id: swiggy._id,
        item_name: 'Special Biryani',
        price: 380,
        delivery_time_mins: 26
      },
      {
        restaurant_id: restaurants[2]._id,
        platform_id: ondc._id,
        item_name: 'Special Biryani',
        price: 340,
        delivery_time_mins: 30
      }
    )

    // Domino's Pizza pricing
    prices.push(
      {
        restaurant_id: restaurants[3]._id,
        platform_id: swiggy._id,
        item_name: 'Margherita Pizza',
        price: 299,
        delivery_time_mins: 25
      },
      {
        restaurant_id: restaurants[3]._id,
        platform_id: zomato._id,
        item_name: 'Margherita Pizza',
        price: 310,
        delivery_time_mins: 27
      },
      {
        restaurant_id: restaurants[3]._id,
        platform_id: ondc._id,
        item_name: 'Margherita Pizza',
        price: 275,
        delivery_time_mins: 30
      }
    )

    // Pizza Hut pricing
    prices.push(
      {
        restaurant_id: restaurants[4]._id,
        platform_id: zomato._id,
        item_name: 'Farmhouse Pizza',
        price: 320,
        delivery_time_mins: 30
      },
      {
        restaurant_id: restaurants[4]._id,
        platform_id: swiggy._id,
        item_name: 'Farmhouse Pizza',
        price: 335,
        delivery_time_mins: 28
      },
      {
        restaurant_id: restaurants[4]._id,
        platform_id: ondc._id,
        item_name: 'Farmhouse Pizza',
        price: 295,
        delivery_time_mins: 32
      }
    )

    // McDonald's pricing
    prices.push(
      {
        restaurant_id: restaurants[5]._id,
        platform_id: swiggy._id,
        item_name: 'McSpicy Chicken Burger',
        price: 180,
        delivery_time_mins: 20
      },
      {
        restaurant_id: restaurants[5]._id,
        platform_id: zomato._id,
        item_name: 'McSpicy Chicken Burger',
        price: 190,
        delivery_time_mins: 22
      },
      {
        restaurant_id: restaurants[5]._id,
        platform_id: ondc._id,
        item_name: 'McSpicy Chicken Burger',
        price: 165,
        delivery_time_mins: 25
      }
    )

    // Burger King pricing
    prices.push(
      {
        restaurant_id: restaurants[6]._id,
        platform_id: zomato._id,
        item_name: 'Whopper',
        price: 200,
        delivery_time_mins: 24
      },
      {
        restaurant_id: restaurants[6]._id,
        platform_id: swiggy._id,
        item_name: 'Whopper',
        price: 215,
        delivery_time_mins: 22
      },
      {
        restaurant_id: restaurants[6]._id,
        platform_id: ondc._id,
        item_name: 'Whopper',
        price: 185,
        delivery_time_mins: 26
      }
    )

    // Greens & Proteins pricing
    prices.push(
      {
        restaurant_id: restaurants[7]._id,
        platform_id: swiggy._id,
        item_name: 'Quinoa Bowl',
        price: 280,
        delivery_time_mins: 30
      },
      {
        restaurant_id: restaurants[7]._id,
        platform_id: zomato._id,
        item_name: 'Quinoa Bowl',
        price: 295,
        delivery_time_mins: 32
      },
      {
        restaurant_id: restaurants[7]._id,
        platform_id: ondc._id,
        item_name: 'Quinoa Bowl',
        price: 260,
        delivery_time_mins: 35
      }
    )

    await RestaurantPrice.insertMany(prices)
    console.log(`✅ Inserted ${prices.length} price records`)

    console.log('\n🎉 Database seeded successfully!')
    console.log('\n📊 Summary:')
    console.log(`   • Platforms: ${platforms.length}`)
    console.log(`   • Restaurants: ${restaurants.length}`)
    console.log(`   • Price records: ${prices.length}`)
    console.log('\n✅ You can now test the API at:')
    console.log('   • http://localhost:3000/api/db-test')
    console.log('   • http://localhost:3000/api/recommendations?category=biryani')
    
    process.exit(0)
  } catch (error) {
    console.error('❌ Error seeding database:', error)
    process.exit(1)
  }
}

seedDatabase()
