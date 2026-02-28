const mongoose = require('mongoose');
require('dotenv').config({ path: '.env.local' });

async function updateRestaurant() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB');

    const Restaurant = mongoose.model('Restaurant', new mongoose.Schema({}, { strict: false }));
    
    // Update Paradise Biryani with test slugs
    // Real KFC Swiggy slug for testing
    const result = await Restaurant.updateOne(
      { name: 'Paradise Biryani' },
      { 
        $set: { 
          swiggySlug: 'kfc-kurla-west-rest243517',
          zomatoSlug: 'paradise-biryani-bandra-east-mumbai'
        } 
      }
    );

    console.log('✅ Updated:', result.modifiedCount, 'restaurant(s)');
    
    // Verify the update
    const restaurant = await Restaurant.findOne({ name: 'Paradise Biryani' }, 'name swiggySlug zomatoSlug _id');
    console.log('\nUpdated Restaurant:');
    console.log(JSON.stringify(restaurant, null, 2));

    await mongoose.disconnect();
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

updateRestaurant();
