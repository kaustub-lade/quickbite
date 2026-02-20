import mongoose from 'mongoose'
import dotenv from 'dotenv'
import User from '../lib/models/User'

dotenv.config({ path: '.env.local' })

async function seedUsers() {
  try {
    console.log('🔗 Connecting to MongoDB...')
    await mongoose.connect(process.env.MONGODB_URI!)
    console.log('✅ Connected to MongoDB')

    // Clear existing users (optional - comment out to keep existing)
    // await User.deleteMany({})
    // console.log('🗑️  Cleared existing users')

    const users = [
      // Admin User
      {
        name: 'Admin User',
        email: 'admin@quickbite.com',
        phone: '9999999999',
        password: Buffer.from('admin123').toString('base64'), // Simple hash for demo
        role: 'admin',
        isEmailVerified: true,
      },
      
      // Regular Customer Users
      {
        name: 'Kaustub Lade',
        email: 'kaustub@example.com',
        phone: '9876543210',
        password: Buffer.from('customer123').toString('base64'),
        role: 'customer',
        isEmailVerified: true,
      },
      {
        name: 'Priya Sharma',
        email: 'priya@example.com',
        phone: '9876543211',
        password: Buffer.from('customer123').toString('base64'),
        role: 'customer',
        isEmailVerified: false,
      },
      
      // Restaurant Owner Users
      {
        name: 'Paradise Biryani Manager',
        email: 'manager@paradisebiryani.com',
        phone: '9876543220',
        password: Buffer.from('owner123').toString('base64'),
        role: 'restaurant_owner',
        restaurantId: 'paradise-biryani',
        isEmailVerified: true,
      },
      {
        name: 'Dominos Manager',
        email: 'manager@dominos.com',
        phone: '9876543221',
        password: Buffer.from('owner123').toString('base64'),
        role: 'restaurant_owner',
        restaurantId: 'dominos',
        isEmailVerified: true,
      },
      {
        name: 'McDonald\'s Manager',
        email: 'manager@mcdonalds.com',
        phone: '9876543222',
        password: Buffer.from('owner123').toString('base64'),
        role: 'restaurant_owner',
        restaurantId: 'mcdonalds',
        isEmailVerified: true,
      },
    ]

    console.log('\n🌱 Seeding users...')
    
    for (const userData of users) {
      // Check if user already exists
      const existingUser = await User.findOne({ email: userData.email })
      
      if (existingUser) {
        console.log(`⚠️  User ${userData.email} already exists, skipping...`)
        continue
      }
      
      const user = await User.create(userData)
      console.log(`✅ Created ${user.role}: ${user.name} (${user.email})`)
    }

    console.log('\n📊 Seeding Summary:')
    const adminCount = await User.countDocuments({ role: 'admin' })
    const customerCount = await User.countDocuments({ role: 'customer' })
    const ownerCount = await User.countDocuments({ role: 'restaurant_owner' })
    
    console.log(`   👑 Admins: ${adminCount}`)
    console.log(`   👤 Customers: ${customerCount}`)
    console.log(`   🏪 Restaurant Owners: ${ownerCount}`)
    console.log(`   📈 Total Users: ${adminCount + customerCount + ownerCount}`)

    console.log('\n🔑 Default Login Credentials:')
    console.log('   Admin:')
    console.log('      Email: admin@quickbite.com')
    console.log('      Password: admin123\n')
    console.log('   Customer:')
    console.log('      Email: kaustub@example.com')
    console.log('      Password: customer123\n')
    console.log('   Restaurant Owner:')
    console.log('      Email: manager@paradisebiryani.com')
    console.log('      Password: owner123\n')

    console.log('✅ User seeding completed successfully!')
    process.exit(0)
  } catch (error) {
    console.error('❌ Error seeding users:', error)
    process.exit(1)
  }
}

seedUsers()
