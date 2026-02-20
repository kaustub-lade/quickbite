# MongoDB Atlas Setup Guide

## 1. Create MongoDB Atlas Account

1. Visit [MongoDB Atlas](https://cloud.mongodb.com/)
2. Sign up for a free account
3. Create a new project called "QuickBite"

## 2. Create a Cluster

1. Click "Build a Database"
2. Choose **M0 FREE** tier (512 MB storage)
3. Select a cloud provider and region (choose one closest to India for best performance)
4. Name your cluster (e.g., "quickbite-cluster")
5. Click "Create"

## 3. Create Database User

1. Go to "Database Access" in the left sidebar
2. Click "Add New Database User"
3. Choose "Password" authentication
4. Set username and password (save these securely!)
5. Set privileges to "Read and write to any database"
6. Click "Add User"

## 4. Configure Network Access

1. Go to "Network Access" in the left sidebar
2. Click "Add IP Address"
3. For development, click "Allow Access from Anywhere" (0.0.0.0/0)
   - ⚠️ For production, restrict to specific IP addresses
4. Click "Confirm"

## 5. Get Connection String

1. Go back to "Database" (Clusters)
2. Click "Connect" on your cluster
3. Choose "Connect your application"
4. Copy the connection string
5. Replace `<password>` with your database user password
6. Add to your `.env.local` file as `MONGODB_URI`

Example:
```
MONGODB_URI=mongodb+srv://quickbite_user:YourPassword123@quickbite-cluster.xxxxx.mongodb.net/quickbite?retryWrites=true&w=majority
```

## 6. Database Schema

Our MongoDB database uses 4 collections:

### Collections Overview

1. **restaurants** - Restaurant information
2. **platforms** - Delivery platforms (Swiggy, Zomato, ONDC)
3. **restaurantprices** - Pricing data for items across platforms
4. **userorders** - User order history and savings tracking

## 7. Seed Sample Data

You can use MongoDB Compass or the Atlas UI to insert sample data:

### Sample Platforms

```json
[
  {
    "name": "Swiggy",
    "commission_rate": 25,
    "created_at": { "$date": "2026-02-11T00:00:00Z" }
  },
  {
    "name": "Zomato",
    "commission_rate": 23,
    "created_at": { "$date": "2026-02-11T00:00:00Z" }
  },
  {
    "name": "ONDC",
    "commission_rate": 5,
    "created_at": { "$date": "2026-02-11T00:00:00Z" }
  }
]
```

### Sample Restaurants

```json
[
  {
    "name": "Paradise Biryani",
    "cuisine": "Biryani",
    "location": "Koramangala, Bangalore",
    "rating": 4.3,
    "image_url": "https://placeholder.com/paradise.jpg",
    "created_at": { "$date": "2026-02-11T00:00:00Z" }
  },
  {
    "name": "Meghana Foods",
    "cuisine": "Biryani",
    "location": "Indiranagar, Bangalore",
    "rating": 4.5,
    "image_url": "https://placeholder.com/meghana.jpg",
    "created_at": { "$date": "2026-02-11T00:00:00Z" }
  },
  {
    "name": "Empire Restaurant",
    "cuisine": "Biryani",
    "location": "Jayanagar, Bangalore",
    "rating": 4.6,
    "image_url": "https://placeholder.com/empire.jpg",
    "created_at": { "$date": "2026-02-11T00:00:00Z" }
  },
  {
    "name": "Domino's Pizza",
    "cuisine": "Pizza",
    "location": "HSR Layout, Bangalore",
    "rating": 4.2,
    "image_url": "https://placeholder.com/dominos.jpg",
    "created_at": { "$date": "2026-02-11T00:00:00Z" }
  },
  {
    "name": "Pizza Hut",
    "cuisine": "Pizza",
    "location": "Whitefield, Bangalore",
    "rating": 4.1,
    "image_url": "https://placeholder.com/pizzahut.jpg",
    "created_at": { "$date": "2026-02-11T00:00:00Z" }
  },
  {
    "name": "McDonald's",
    "cuisine": "Burger",
    "location": "MG Road, Bangalore",
    "rating": 4.0,
    "image_url": "https://placeholder.com/mcdonalds.jpg",
    "created_at": { "$date": "2026-02-11T00:00:00Z" }
  },
  {
    "name": "Burger King",
    "cuisine": "Burger",
    "location": "Brigade Road, Bangalore",
    "rating": 4.1,
    "image_url": "https://placeholder.com/burgerking.jpg",
    "created_at": { "$date": "2026-02-11T00:00:00Z" }
  },
  {
    "name": "Greens & Proteins",
    "cuisine": "Healthy",
    "location": "Electronic City, Bangalore",
    "rating": 4.4,
    "image_url": "https://placeholder.com/greens.jpg",
    "created_at": { "$date": "2026-02-11T00:00:00Z" }
  }
]
```

### Sample Pricing Data

After inserting restaurants and platforms, note their `_id` values and use them in the pricing data:

```json
[
  {
    "restaurant_id": { "$oid": "INSERT_PARADISE_ID_HERE" },
    "platform_id": { "$oid": "INSERT_ONDC_ID_HERE" },
    "item_name": "Chicken Biryani",
    "price": 280,
    "delivery_time_mins": 35,
    "last_updated": { "$date": "2026-02-11T00:00:00Z" }
  },
  {
    "restaurant_id": { "$oid": "INSERT_PARADISE_ID_HERE" },
    "platform_id": { "$oid": "INSERT_SWIGGY_ID_HERE" },
    "item_name": "Chicken Biryani",
    "price": 365,
    "delivery_time_mins": 30,
    "last_updated": { "$date": "2026-02-11T00:00:00Z" }
  }
]
```

## 8. Test Connection

Run your Next.js app to test the MongoDB connection:

```bash
npm run dev
```

The connection will be automatically tested when the API routes are called.

## 9. MongoDB Indexes

Our models already include indexes for optimal query performance:

- **RestaurantPrice**: Compound index on `(restaurant_id, platform_id, item_name)`
- **UserOrder**: Compound index on `(user_id, order_date)` in descending order

Indexes are created automatically when the app connects to MongoDB.

## 10. Monitoring

You can monitor your database usage in the MongoDB Atlas dashboard:
- Database size
- Connection count
- Query performance
- Network traffic

## Notes

- Free tier (M0) provides 512 MB storage - sufficient for MVP
- Connection pooling is handled automatically by Mongoose
- Database connection is cached in development to prevent connection exhaustion
- For production, ensure you restrict IP access and use strong passwords
