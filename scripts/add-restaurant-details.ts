import connectDB from '../lib/mongodb'
import Restaurant from '../lib/models/Restaurant'

const restaurantDetailsUpdates = [
  {
    filter: { name: 'Paradise Biryani' },
    update: {
      id: 'paradise-biryani',
      deliveryTime: '30-40 mins',
      distance: 2.3,
      openingHours: '11:00 AM - 11:30 PM',
      platforms: ['swiggy', 'zomato', 'ondc'],
      totalReviews: 1250,
      reviews: [
        {
          userId: 'user1',
          userName: 'Rajesh Kumar',
          rating: 5,
          comment: 'Best biryani in Hyderabad! Authentic flavors and generous portions.',
          createdAt: new Date('2026-02-15'),
        },
        {
          userId: 'user2',
          userName: 'Priya Sharma',
          rating: 4,
          comment: 'Great taste but delivery took longer than expected.',
          createdAt: new Date('2026-02-18'),
        },
        {
          userId: 'user3',
          userName: 'Amit Patel',
          rating: 5,
          comment: 'The chicken dum biryani is simply outstanding!',
          createdAt: new Date('2026-02-20'),
        },
      ],
    },
  },
  {
    filter: { name: "Domino's Pizza" },
    update: {
      id: 'dominos-pizza',
      deliveryTime: '25-35 mins',
      distance: 1.8,
      openingHours: '10:00 AM - 11:00 PM',
      platforms: ['swiggy', 'zomato'],
      totalReviews: 890,
      reviews: [
        {
          userId: 'user4',
          userName: 'Sneha Reddy',
          rating: 4,
          comment: 'Consistent quality and quick delivery. Love their cheese burst!',
          createdAt: new Date('2026-02-16'),
        },
        {
          userId: 'user5',
          userName: 'Karthik Rao',
          rating: 3,
          comment: 'Good but a bit overpriced compared to other options.',
          createdAt: new Date('2026-02-19'),
        },
      ],
    },
  },
  {
    filter: { name: "McDonald's" },
    update: {
      id: 'mcdonalds-jubilee',
      deliveryTime: '20-30 mins',
      distance: 3.2,
      openingHours: '9:00 AM - 12:00 AM',
      platforms: ['swiggy', 'zomato', 'ondc'],
      totalReviews: 2100,
      reviews: [
        {
          userId: 'user6',
          userName: 'Meera Shah',
          rating: 4,
          comment: 'Kids love the happy meals! Always fresh and hot.',
          createdAt: new Date('2026-02-17'),
        },
        {
          userId: 'user7',
          userName: 'Vikram Singh',
          rating: 5,
          comment: 'Fast service and great value for money.',
          createdAt: new Date('2026-02-21'),
        },
      ],
    },
  },
  {
    filter: { name: 'Burger King' },
    update: {
      id: 'kfc-banjara',
      deliveryTime: '25-35 mins',
      distance: 2.7,
      openingHours: '10:30 AM - 11:30 PM',
      platforms: ['swiggy', 'zomato'],
      totalReviews: 1550,
      reviews: [
        {
          userId: 'user8',
          userName: 'Ananya Iyer',
          rating: 5,
          comment: 'Crispy chicken is always perfect! Best fried chicken in town.',
          createdAt: new Date('2026-02-14'),
        },
        {
          userId: 'user9',
          userName: 'Rahul Verma',
          rating: 4,
          comment: 'Good food but sometimes runs out of popular items.',
          createdAt: new Date('2026-02-19'),
        },
      ],
    },
  },
  {
    filter: { name: 'Pizza Hut' },
    update: {
      id: 'subway-hitech',
      deliveryTime: '20-25 mins',
      distance: 1.5,
      openingHours: '8:00 AM - 10:00 PM',
      platforms: ['swiggy', 'zomato', 'ondc'],
      totalReviews: 670,
      reviews: [
        {
          userId: 'user10',
          userName: 'Divya Menon',
          rating: 4,
          comment: 'Healthy option with good customization. Fresh veggies!',
          createdAt: new Date('2026-02-18'),
        },
        {
          userId: 'user11',
          userName: 'Sanjay Gupta',
          rating: 4,
          comment: 'Quick and satisfying meals. Love the Italian BMT!',
          createdAt: new Date('2026-02-20'),
        },
      ],
    },
  },
  {
    filter: { name: 'Meghana Foods' },
    update: {
      id: 'starbucks-hiteccity',
      deliveryTime: '15-25 mins',
      distance: 2.0,
      openingHours: '7:00 AM - 11:00 PM',
      platforms: ['swiggy', 'zomato'],
      totalReviews: 980,
      reviews: [
        {
          userId: 'user12',
          userName: 'Kavya Nair',
          rating: 5,
          comment: 'Perfect place for coffee lovers! Great ambiance too.',
          createdAt: new Date('2026-02-16'),
        },
        {
          userId: 'user13',
          userName: 'Arjun Desai',
          rating: 4,
          comment: 'Expensive but worth it for the quality and consistency.',
          createdAt: new Date('2026-02-21'),
        },
      ],
    },
  },
  {
    filter: { name: 'Empire Restaurant' },
    update: {
      id: 'taj-mahal-hotel',
      deliveryTime: '40-50 mins',
      distance: 5.5,
      openingHours: '12:00 PM - 10:30 PM',
      platforms: ['zomato', 'ondc'],
      totalReviews: 450,
      reviews: [
        {
          userId: 'user14',
          userName: 'Rohan Kapoor',
          rating: 5,
          comment: 'Fine dining at home! Authentic Mughlai cuisine.',
          createdAt: new Date('2026-02-15'),
        },
        {
          userId: 'user15',
          userName: 'Pooja Agarwal',
          rating: 5,
          comment: 'Premium quality and presentation. Worth every rupee!',
          createdAt: new Date('2026-02-19'),
        },
      ],
    },
  },
  {
    filter: { name: 'Greens & Proteins' },
    update: {
      id: 'udupi-garden',
      deliveryTime: '25-30 mins',
      distance: 3.8,
      openingHours: '7:00 AM - 10:00 PM',
      platforms: ['swiggy', 'zomato', 'ondc'],
      totalReviews: 820,
      reviews: [
        {
          userId: 'user16',
          userName: 'Lakshmi Pillai',
          rating: 5,
          comment: 'Best South Indian food! Crispy dosas and authentic sambar.',
          createdAt: new Date('2026-02-17'),
        },
        {
          userId: 'user17',
          userName: 'Suresh Babu',
          rating: 4,
          comment: 'Reasonable prices and good portion sizes.',
          createdAt: new Date('2026-02-20'),
        },
      ],
    },
  },
]

async function updateRestaurantsWithDetails() {
  try {
    console.log('🔄 Connecting to database...')
    await connectDB()

    console.log('🔄 Updating restaurants with enhanced details...')

    let updatedCount = 0

    for (const { filter, update } of restaurantDetailsUpdates) {
      const result = await Restaurant.updateOne(filter, { $set: update })
      if (result.modifiedCount > 0) {
        updatedCount++
        console.log(`✅ Updated: ${filter.name}`)
      }
    }

    console.log(`\n✅ Updated ${updatedCount} restaurants with enhanced details`)

    // Verify one restaurant
    const sample = await Restaurant.findOne({ name: 'Paradise Biryani' })
    console.log('\n📋 Sample restaurant (Paradise Biryani):')
    console.log(JSON.stringify(sample, null, 2))

    process.exit(0)
  } catch (error) {
    console.error('❌ Error updating restaurants:', error)
    process.exit(1)
  }
}

updateRestaurantsWithDetails()
