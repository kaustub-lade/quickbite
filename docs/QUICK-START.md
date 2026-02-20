# QuickBite MongoDB Atlas - Quick Start

## ✅ What's Already Done

- ✅ Mongoose installed and configured
- ✅ MongoDB connection utility with caching ([lib/mongodb.ts](../lib/mongodb.ts))
- ✅ 4 Mongoose models created with schemas ([lib/models.ts](../lib/models.ts))
  - Restaurant, Platform, RestaurantPrice, UserOrder
- ✅ API endpoint for recommendations ([app/api/recommendations/route.ts](../app/api/recommendations/route.ts))
- ✅ Database test endpoint ([app/api/db-test/route.ts](../app/api/db-test/route.ts))
- ✅ Environment variable template updated
- ✅ Complete setup guide in [mongodb-setup.md](./mongodb-setup.md)

## 🚀 Next Steps (5 Minutes)

### 1. Create MongoDB Atlas Account

Visit: https://cloud.mongodb.com/

- Sign up (free)
- Create a new project: "QuickBite"

### 2. Create Free Cluster

- Click "Build a Database"
- Select **M0 FREE** (512 MB, perfect for MVP)
- Choose AWS Mumbai region (closest to India)
- Name: `quickbite-cluster`

### 3. Create Database User

- Go to "Database Access"
- Add New Database User
- Username: `quickbite_admin`
- Password: Generate a strong one (save it!)
- Database User Privileges: "Read and write to any database"

### 4. Configure Network Access

- Go to "Network Access"
- Add IP Address
- **For development**: Click "Allow Access from Anywhere" (0.0.0.0/0)
  - ⚠️ For production, restrict this later

### 5. Get Connection String

- Back to "Database" → "Connect"
- Choose "Connect your application"
- Driver: Node.js, Version: 5.5 or later
- Copy the connection string
- Replace `<password>` with your database user password

Your string should look like:
```
mongodb+srv://quickbite_admin:YOUR_PASSWORD@quickbite-cluster.xxxxx.mongodb.net/?retryWrites=true&w=majority
```

### 6. Update `.env.local`

Add to your `.env.local` file:
```env
MONGODB_URI=mongodb+srv://quickbite_admin:YOUR_PASSWORD@quickbite-cluster.xxxxx.mongodb.net/quickbite?retryWrites=true&w=majority
```

⚠️ **Important**: Add `/quickbite` before the `?` to specify the database name!

### 7. Test Connection

Start your dev server:
```bash
npm run dev
```

Visit: http://localhost:3000/api/db-test

You should see:
```json
{
  "status": "connected",
  "database": "quickbite",
  "collections": {
    "restaurants": 0,
    "platforms": 0,
    "restaurantPrices": 0,
    "userOrders": 0
  },
  "message": "MongoDB Atlas connection successful! 🎉"
}
```

### 8. Insert Sample Data

**Option A: MongoDB Atlas UI** (Recommended)
1. Go to your cluster → "Browse Collections"
2. Create database: `quickbite`
3. Create collections: `restaurants`, `platforms`, `restaurantprices`, `userorders`
4. Click "Insert Document" and paste JSON from [mongodb-setup.md](./mongodb-setup.md)

**Option B: MongoDB Compass** (Desktop App)
1. Download [MongoDB Compass](https://www.mongodb.com/try/download/compass)
2. Connect using your connection string
3. Create collections and import JSON data

### 9. Verify Data

Visit: http://localhost:3000/api/db-test

Now you should see non-zero counts:
```json
{
  "collections": {
    "restaurants": 8,
    "platforms": 3,
    "restaurantPrices": 24,
    "userOrders": 0
  }
}
```

### 10. Test Recommendations API

Visit: http://localhost:3000/api/recommendations?category=biryani

You should get smart recommendations with pricing comparisons! 🎉

## 🔧 Troubleshooting

### "Network Error" or "MongooseServerSelectionError"
- Check Network Access in Atlas (allow 0.0.0.0/0)
- Verify connection string has correct password
- Ensure database name is in the URI: `/quickbite?`

### "Authentication failed"
- Double-check username and password
- Regenerate password if needed (avoid special chars in password)

### "Cannot find database"
- Make sure URI includes `/quickbite?` after the cluster URL
- The database is created automatically when first data is inserted

### Connection string issues
**Wrong:**
```
mongodb+srv://user:pass@cluster.net/?params
```

**Correct:**
```
mongodb+srv://user:pass@cluster.net/quickbite?params
```

## 📊 What the API Does

### `/api/db-test` (GET)
Tests MongoDB connection and returns collection counts

### `/api/recommendations?category={category}` (GET)
- Finds restaurants matching the cuisine category
- Gets pricing from all platforms (Swiggy, Zomato, ONDC)
- Calculates best deals, fastest delivery, and savings
- Returns smart recommendations with reasons

Categories: `biryani`, `pizza`, `burger`, `healthy`

## 🎯 Next Development Steps

After data is loaded:

1. **Connect Frontend to API**
   - Update `app/page.tsx` to fetch from `/api/recommendations`
   - Replace mock data with real API calls
   - Add loading states

2. **Add More Features**
   - User authentication (Clerk or NextAuth)
   - Order tracking
   - Price history charts
   - Real-time price updates

3. **ONDC Integration**
   - ONDC Buyer App registration
   - Real-time price fetching
   - Direct checkout flow

## 📚 Additional Resources

- [MongoDB Atlas Tutorial](https://www.mongodb.com/docs/atlas/getting-started/)
- [Mongoose Quick Start](https://mongoosejs.com/docs/index.html)
- [Next.js API Routes](https://nextjs.org/docs/app/building-your-application/routing/route-handlers)

---

**Estimated setup time:** 5-10 minutes  
**Cost:** $0 (MongoDB Atlas free tier)  
**Database size:** 512 MB (sufficient for thousands of restaurants)

🚀 **Happy coding!**
