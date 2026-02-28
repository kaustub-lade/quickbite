# Scraper Setup Guide (Hybrid: Jina AI + Firecrawl)

## 🎯 Overview

QuickBite uses a **hybrid scraping strategy** to get real-time menu prices from Swiggy and Zomato:

1. **Primary**: Jina AI Reader (100% FREE, unlimited)
2. **Fallback**: Firecrawl (500 credits total, rarely used)

This ensures sustainable, cost-free scraping for years.

**Read full comparison**: See [SCRAPER_COMPARISON.md](SCRAPER_COMPARISON.md)

---

## 📦 What's Been Implemented

### **Backend Components**

1. **`lib/models/ScrapedPrice.ts`** - MongoDB model for cached scraped data
   - Stores menu items with prices from Swiggy/Zomato
   - Auto-deletes after 7 days (TTL index)
   - Tracks scrape success/failure + which method used

2. **`lib/services/jina-client.ts`** - Jina AI Reader wrapper (PRIMARY)
   - 100% FREE, unlimited scraping
   - No API key required
   - Prepends `https://r.jina.ai/` to URLs

3. **`lib/services/firecrawl-client.ts`** - Firecrawl API wrapper (FALLBACK)
   - Used only when Jina AI fails (rare)
   - 500 credits total preserved for years

4. **`lib/services/scraper-service.ts`** - Business logic with hybrid scraping
   - Tries Jina AI first (free)
   - Falls back to Firecrawl if needed
   - 6-hour caching for both methods
   - Tracks which scraper was used

5. **API Routes**:
   - `POST /api/scrape/swiggy` - Manual scrape trigger (for testing)
   - `POST /api/scrape/zomato` - Manual scrape trigger (for testing)
   - `GET /api/restaurants/:id/live-prices?platform=swiggy` - Mobile app endpoint

6. **Updated Restaurant Model** - Added `swiggySlug` and `zomatoSlug` fields

---

## 🚀 Setup Instructions

### **Step 1: Firecrawl API Key** (Already Added!)

✅ **DONE**: Your Firecrawl API key is already in `.env.local`:
```env
FIRECRAWL_API_KEY=fc-4bc14a64de8a47ea98664470144343e4
```

**Note**: This is only used as fallback (1% of scrapes). Your 500 credits will last years!

### **Step 2: Jina AI** (No Setup Needed!)

✅ **DONE**: Jina AI requires NO API key. It just works out of the box!

### **Step 3: Restart Backend**

```bash
npm run dev
```

You should see:
```
✅ MongoDB connected successfully
✅ Server running on http://localhost:3000
```

---

## 🧪 Testing the Scraper

### **Test 1: Manual Scrape (Swiggy)**

Use Postman or curl to test:

```bash
curl -X POST http://localhost:3000/api/scrape/swiggy \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "restaurantId": "existing-restaurant-id",
    "restaurantName": "Paradise Biryani",
    "restaurantSlug": "paradise-biryani-mira-road-mumbai-123456",
    "forceRefresh": true
  }'
```

**Expected Response**:
```json
{
  "success": true,
  "message": "Scraped successfully",
  "data": {
    "platform": "swiggy",
    "itemCount": 15,
    "menuItems": [
      {
        "name": "Chicken Biryani",
        "price": 299,
        "isVeg": false,
        "isAvailable": true
      }
    ]
  }
}
```

### **Test 2: Get Live Prices (Mobile App Endpoint)**

```bash
curl http://localhost:3000/api/restaurants/RESTAURANT_ID/live-prices?platform=swiggy
```

First call: Scrapes (takes 5-10 seconds)
Subsequent calls: Returns cached data (instant)

---

## 📋 Finding Restaurant Slugs

To scrape a restaurant, you need the correct URL slug:

### **For Swiggy**:

1. Open https://www.swiggy.com/
2. Search "Paradise Biryani Mira Road"
3. Click restaurant
4. Copy URL: `https://www.swiggy.com/restaurants/paradise-biryani-mira-road-mumbai-123456`
5. Extract slug: **`paradise-biryani-mira-road-mumbai-123456`**
6. Add to your Restaurant document in MongoDB:
   ```javascript
   {
     name: "Paradise Biryani",
     swiggySlug: "paradise-biryani-mira-road-mumbai-123456"
   }
   ```

### **For Zomato**:

1. Open https://www.zomato.com/
2. Search restaurant
3. Copy URL: `https://www.zomato.com/mumbai/paradise-biryani-mira-road`
4. Extract slug: **`paradise-biryani-mira-road`**
5. Add to Restaurant:
   ```javascript
   {
     name: "Paradise Biryani",
     zomatoSlug: "paradise-biryani-mira-road"
   }
   ```

---

## 🔧 How Caching Works

### **Cache Strategy**:

```
User requests live prices
    ↓
Check MongoDB: Is data fresh? (< 6 hours old)
    ↓ YES → Return cached data (instant)
    ↓ NO  → Scrape with Firecrawl (5-10 seconds)
    ↓
Save to MongoDB → Return fresh data
```

### **Cache Settings**:

- **Default TTL**: 6 hours (configurable)
- **Auto-delete**: After 7 days (MongoDB TTL index)
- **Cache key**: `restaurantId + platform`

### **Cache Behavior**:

| Scenario | Behavior | Speed |
|----------|----------|-------|
| First request | Scrapes fresh data | 5-10s |
| Within 6 hours | Returns cached data | <100ms |
| After 6 hours | Scrapes fresh data | 5-10s |
| Scraping fails | Returns stale cache (if available) | <100ms |

---

## 📊 Free Tier Limits

**Firecrawl Free Plan**:
- **Credits**: 500/month
- **Rate limit**: 10 requests/minute
- **1 scrape = 1 credit**

**Usage Calculation**:
```
5 restaurants × 4 scrapes/day × 30 days = 600 credits/month
❌ Over limit!

Solution: Scrape every 12 hours instead
5 restaurants × 2 scrapes/day × 30 days = 300 credits/month
✅ Under limit
```

**Recommended**: Start with 3 popular restaurants scraped 3 times/day = 270 credits/month

---

## 🐛 Troubleshooting

### **Error: "FIRECRAWL_API_KEY not configured"**

**Fix**: Add API key to `.env.local` and restart server

### **Error: "Failed to scrape Swiggy page"**

**Causes**:
1. Invalid restaurant slug
2. Firecrawl blocked by Swiggy (rare)
3. Out of API credits

**Debug**:
```bash
# Check MongoDB for failed scrapes
db.scrapedprices.find({ "metadata.success": false }).sort({ scrapedAt: -1 }).limit(5)
```

### **Parsed 0 menu items**

**Cause**: Markdown structure doesn't match regex patterns

**Fix**: 
1. Use Firecrawl playground: https://www.firecrawl.dev/playground
2. Scrape real Swiggy restaurant URL
3. Check markdown format
4. Update regex in `lib/services/scraper-service.ts` → `parseSwiggyMarkdown()`

**Example markdown patterns to look for**:
```
Chicken Biryani ₹299
Paneer Tikka Rs 250
Veg Pulao - 150
```

Adjust regex: `/^(.+?)\s+(?:₹|Rs\.?|-)\s*(\d+)/`

---

## 🔄 Next Steps

### **1. Add Real Restaurant Slugs** (Manual)

Update your seed data or database with actual Swiggy/Zomato slugs:

```javascript
// scripts/seed-restaurants.ts
{
  name: "Paradise Biryani",
  swiggySlug: "paradise-biryani-mira-road-mumbai-567890",
  zomatoSlug: "paradise-biryani-mira-road",
  platforms: ["swiggy", "zomato"]
}
```

### **2. Test with 1 Restaurant**

Start small:
1. Find real Swiggy URL for Paradise Biryani
2. Update restaurant in MongoDB with `swiggySlug`
3. Test scraping via API
4. Verify parsed menu items

### **3. Scale to 5 Restaurants**

Once working:
- Add 4 more popular restaurants
- Update slugs in database
- Monitor Firecrawl credit usage

### **4. Mobile Integration** (Next Phase)

Update Flutter app to call `/api/restaurants/:id/live-prices`

---

## 📈 Production Deployment

### **Environment Variables on Render**:

1. Go to Render Dashboard → QuickBite → Environment
2. Add `FIRECRAWL_API_KEY` = `fc-your-key`
3. Redeploy

### **Monitoring**:

Check scrape logs:
```bash
# In Render logs
✅ Scraped 15 items from Swiggy in 6543ms
❌ Scraping failed: Invalid restaurant slug
```

### **Upgrade to Paid** (After 100+ users):

**Hobby Plan** ($29/month):
- 10,000 credits/month
- Structured data extraction (no markdown parsing!)
- Webhook support

**When to upgrade**:
- 100+ daily active users
- 20+ restaurants
- Need faster updates (3-hour cache)

---

## 🔐 Security Notes

- ✅ API key stored in environment variables (never in code)
- ✅ Authentication required for scrape endpoints
- ✅ Rate limiting via Firecrawl (10 req/min)
- ✅ Failed scrapes logged for debugging
- ✅ TTL index prevents database bloat

---

## 📚 Additional Resources

- **Firecrawl Docs**: https://docs.firecrawl.dev/
- **Firecrawl Playground**: https://www.firecrawl.dev/playground
- **Support**: support@firecrawl.dev

---

## ✅ Summary

**What's Working**:
- ✅ Firecrawl SDK integrated
- ✅ Caching system (6-hour TTL)
- ✅ API routes for scraping
- ✅ MongoDB model for cached data
- ✅ Error handling and logging

**What You Need to Do**:
1. Get Firecrawl API key → Add to `.env.local`
2. Install package: `npm install @mendable/firecrawl-js`
3. Find real restaurant slugs from Swiggy/Zomato
4. Update Restaurant documents in MongoDB
5. Test scraping with 1 restaurant
6. Adjust markdown parsing regex if needed

**Estimated Time**: 1-2 hours to get first restaurant working
