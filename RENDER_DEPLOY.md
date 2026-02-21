# Deploy QuickBite Backend to Render (Free)

## 🚀 Quick Deploy Guide

### Prerequisites
- GitHub account
- MongoDB Atlas account (free tier)
- Render account (free - signup at [render.com](https://render.com))

### Step 1: Prepare Your Code

1. **Commit your changes:**
   ```bash
   git add .
   git commit -m "Prepare for Render deployment"
   git push origin master
   ```

### Step 2: Deploy to Render

1. **Go to Render Dashboard:**
   - Visit [dashboard.render.com](https://dashboard.render.com)
   - Click **"New +"** → **"Web Service"**

2. **Connect Repository:**
   - Choose **"Build and deploy from a Git repository"**
   - Click **"Connect account"** (GitHub)
   - Select your **quickbite** repository

3. **Configure Service:**
   ```
   Name: quickbite-backend
   Region: Choose closest to you
   Branch: master
   Root Directory: (leave blank)
   Runtime: Node
   Build Command: npm install && npm run build
   Start Command: npm start
   Plan: Free
   ```

4. **Add Environment Variables:**
   Click **"Advanced"** → **"Add Environment Variable"**:
   ```
   Key: MONGODB_URI
   Value: mongodb+srv://username:password@cluster0.xxxxx.mongodb.net/quickbite
   
   Key: NODE_ENV
   Value: production
   ```

5. **Deploy:**
   - Click **"Create Web Service"**
   - Wait 3-5 minutes for deployment
   - Your backend URL: `https://quickbite-backend.onrender.com`

### Step 3: Update Mobile App

1. **Update mobile/.env:**
   ```bash
   API_BASE_URL=https://quickbite-backend.onrender.com
   ```

2. **For Web (Chrome):**
   - Press `r` in Flutter terminal for hot reload
   - The app will now connect to Render backend

3. **For APK (GitHub Actions):**
   - Update `.github/workflows/build-apk.yml`:
     ```yaml
     echo "API_BASE_URL=https://quickbite-backend.onrender.com" >> .env
     ```
   - Commit and push to trigger new build

### Step 4: Test

1. **Test backend directly:**
   ```bash
   curl https://quickbite-backend.onrender.com/api/db-test
   ```

2. **Test in mobile app:**
   - Login with: `kaustub@example.com` / `customer123`
   - Should work from anywhere now (no localhost!)

## ⚠️ Important Notes

### Free Tier Limitations
- Backend **spins down after 15 minutes** of inactivity
- First request after spin-down takes ~30 seconds
- 750 hours/month free (enough for testing)
- No credit card required

### Keeping Backend Awake (Optional)
Add a cron job to ping every 14 minutes:
1. Go to Render Dashboard → Cron Jobs → New Cron Job
2. Command: `curl https://quickbite-backend.onrender.com/api/db-test`
3. Schedule: `*/14 * * * *` (every 14 minutes)

### Troubleshooting

**Build fails:**
- Check Render logs for errors
- Verify `package.json` has `"build": "next build"`

**"Application error" page:**
- Check Environment Variables are set correctly
- Check MongoDB Atlas allows connections from anywhere (0.0.0.0/0)

**Mobile app can't connect:**
- Verify URL in `mobile/.env` is correct
- Check Render service is running (not spun down)
- Test backend URL in browser first

## 🎯 Alternative: Manual Deploy

If automatic deploy doesn't work, use Render's Blueprint:

1. Create `render.yaml` in project root (already created!)
2. In Render: New → Blueprint → Connect repository
3. Render reads `render.yaml` and configures everything

## 💰 Cost Comparison

| Platform | Free Tier | Spin Down | Notes |
|----------|-----------|-----------|-------|
| **Render** | 750 hrs/month | After 15 min | Best for testing |
| Vercel | Unlimited | Never | Backend limits (10s timeout) |
| Railway | $5 credit/month | Never | Credit card required |
| Fly.io | Limited | Never | Complex setup |

**Recommendation:** Use Render for MVP testing, then upgrade or switch for production.

## 🔄 CI/CD (Automatic Deploys)

Render automatically deploys when you push to `master`:
```bash
git add .
git commit -m "Update backend"
git push origin master
# Render detects push and redeploys automatically (2-3 minutes)
```

## 📝 Next Steps

After deploying to Render:
1. ✅ Mobile app works from anywhere
2. ✅ Share APK with friends for testing
3. ✅ No need to keep laptop running
4. ✅ Professional URL for portfolio

**Your backend will be live at:**
`https://quickbite-backend.onrender.com`
