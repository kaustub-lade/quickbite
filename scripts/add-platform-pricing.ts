import connectDB from '../lib/mongodb'
import MenuItem from '../lib/models/MenuItem'

// Update existing menu items with platform pricing for best deals
async function addPlatformPricingToMenuItems() {
  console.log('🔄 Updating menu items with platform pricing...')
  
  await connectDB()

  // Best Deals configuration for specific items  
  const bestDealsUpdates = [
    {
      filter: { restaurantId: 'paradise-biryani', name: 'Hyderabadi Chicken Dum Biryani' },
      platformPrices: [
        { platform: 'swiggy', price: 350, savings: 0 },
        { platform: 'zomato', price: 290, savings: 60 },
        { platform: 'ondc', price: 280, savings: 70 }
      ]
    },
    {
      filter: { restaurantId: 'paradise-biryani', name: 'Mutton Biryani' },
      platformPrices: [
        { platform: 'swiggy', price: 450, savings: 0 },
        { platform: 'zomato', price: 399, savings: 51 },
        { platform: 'ondc', price: 380, savings: 70 }
      ]
    },
    {
      filter: { restaurantId: 'paradise-biryani', name: 'Veg Biryani' },
      platformPrices: [
        { platform: 'swiggy', price: 250, savings: 0 },
        { platform: 'zomato', price: 220, savings: 30 },
        { platform: 'ondc', price: 200, savings: 50 }
      ]
    },
    {
      filter: { restaurantId: 'dominos', name: /Margherita Pizza/ },
      platformPrices: [
        { platform: 'swiggy', price: 399, savings: 0 },
        { platform: 'zomato', price: 349, savings: 50 },
        { platform: 'ondc', price: 299, savings: 100 }
      ]
    },
    {
      filter: { restaurantId: 'dominos', name: /Pepperoni Pizza/ },
      platformPrices: [
        { platform: 'swiggy', price: 499, savings: 0 },
        { platform: 'zomato', price: 429, savings: 70 },
        { platform: 'ondc', price: 399, savings: 100 }
      ]
    },
    {
      filter: { restaurantId: 'mcdonalds', name: /Big Mac/ },
      platformPrices: [
        { platform: 'swiggy', price: 215, savings: 0 },
        { platform: 'zomato', price: 175, savings: 40 },
        { platform: 'ondc', price: 160, savings: 55 }
      ]
    },
    {
      filter: { restaurantId: 'mcdonalds', name: /Chicken McNuggets/ },
      platformPrices: [
        { platform: 'swiggy', price: 180, savings: 0 },
        { platform: 'zomato', price: 145, savings: 35 },
        { platform: 'ondc', price: 130, savings: 50 }
      ]
    },
    {
      filter: { restaurantId: 'kfc', name: /Chicken Bucket/ },
      platformPrices: [
        { platform: 'swiggy', price: 599, savings: 0 },
        { platform: 'zomato', price: 519, savings: 80 },
        { platform: 'ondc', price: 499, savings: 100 }
      ]
    },
    {
      filter: { restaurantId: 'subway', name: /Veggie Delite/ },
      platformPrices: [
        { platform: 'swiggy', price: 139, savings: 0 },
        { platform: 'zomato', price: 115, savings: 24 },
        { platform: 'ondc', price: 99, savings: 40 }
      ]
    },
    {
      filter: { restaurantId: 'subway', name: /Chicken Tikka/ },
      platformPrices: [
        { platform: 'swiggy', price: 219, savings: 0 },
        { platform: 'zomato', price: 179, savings: 40 },
        { platform: 'ondc', price: 169, savings: 50 }
      ]
    }
  ]

  let updateCount = 0
  for (const update of bestDealsUpdates) {
    const result = await MenuItem.updateMany(
      update.filter,
      { $set: { platformPrices: update.platformPrices } }
    )
    updateCount += result.modifiedCount
  }

  console.log(`✅ Updated ${updateCount} menu items with platform pricing`)

  // Verify by checking one item
  const sample = await MenuItem.findOne({ 
    restaurantId: 'paradise-biryani',
    name: 'Hyderabadi Chicken Dum Biryani' 
  })
  console.log('Sample item:', {
    name: sample?.name,
    price: sample?.price,
    platformPrices: sample?.platformPrices
  })
}

// Run the update
addPlatformPricingToMenuItems()
  .then(() => {
    console.log('✅ Platform pricing update complete!')
    process.exit(0)
  })
  .catch((error) => {
    console.error('❌ Error updating platform pricing:', error)
    process.exit(1)
  })
