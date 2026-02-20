# QuickBite Setup Guide

## ✅ What's Been Done

Your QuickBite project is now set up with:

1. **Next.js 15 Project** - Fully configured with TypeScript & Tailwind CSS
2. **Beautiful UI** - Interactive home page with category selection
3. **Database Schema** - Complete SQL schema ready for Supabase
4. **Environment Setup** - .env files ready for configuration
5. **Supabase Client** - Ready to connect once you add credentials

## 🎯 Next Steps (Do These Now!)

### Step 1: Open Your Browser
Visit **http://localhost:3000** to see your app running!

You should see:
- QuickBite header with orange branding
- Category selection (Biryani, Pizza, Burger, Healthy)
- Click any category to see mock recommendations
- Beautiful recommendation cards with price comparisons

### Step 2: Set Up Supabase (15 minutes)

1. **Create Supabase Account:**
   - Go to https://supabase.com
   - Sign up (it's free!)
   - Create a new project
     - Name: `quickbite`
     - Database password: (save this!)
     - Region: Mumbai (closest to India)
     - Plan: Free tier

2. **Get Your API Credentials:**
   - Go to Project Settings → API
   - Copy these values:
     - Project URL (looks like: `https://xxxxx.supabase.co`)
     - anon/public key (long string starting with `eyJ...`)

3. **Update Your .env.local File:**
   Open `.env.local` and replace:
   ```
   NEXT_PUBLIC_SUPABASE_URL=https://your-actual-project-id.supabase.co
   NEXT_PUBLIC_SUPABASE_ANON_KEY=your-actual-anon-key-here
   ```

4. **Set Up Database:**
   - In Supabase, go to SQL Editor
   - Click "New Query"
   - Open `docs/database-schema.md` in VS Code
   - Copy ALL the SQL code
   - Paste into Supabase SQL Editor
   - Click "Run"
   - You should see: "Success. No rows returned"

### Step 3: Test the Connection

1. Restart your dev server (it's already running)
2. Refresh http://localhost:3000
3. Once we connect the API route (next task), you'll see real data!

## 📂 Key Files to Know

- **`app/page.tsx`** - The home page UI (what you see)
- **`lib/supabase.ts`** - Database connection
- **`.env.local`** - Your secret credentials (never commit this!)
- **`docs/database-schema.md`** - Complete database setup

## 🐛 Troubleshooting

### "Cannot find module" errors
```bash
npm install
```

### Dev server not responding
Press `Ctrl+C` in terminal and run:
```bash
npm run dev
```

### Supabase connection errors
- Check `.env.local` has correct values
- Make sure there are no spaces or quotes around values
- Restart dev server after changing .env.local

## 🎨 What You Can Do Right Now

Even without Supabase set up, you can:
1. ✅ Browse the UI 
2. ✅ Click categories to see recommendations
3. ✅ See how the design looks
4. ✅ Test the responsive design (resize browser)

## 🚀 What's Coming Next

After Supabase is set up:
- [ ] Connect home page to real database
- [ ] Create API route for recommendations
- [ ] Fetch actual restaurant data
- [ ] Calculate real price comparisons
- [ ] Add ONDC integration

## 💡 Tips

- Keep Supabase dashboard open while developing
- Use the SQL Editor to check your data
- Use Table Editor to view data in a spreadsheet format
- The app auto-refreshes when you edit code

## 🆘 Need Help?

If you run into issues:
1. Check the terminal for error messages
2. Check browser console (F12)
3. Verify .env.local is correct
4. Make sure Supabase SQL ran successfully

---

**You're doing great! The hardest part (setup) is done. Now it's time to connect everything together! 🎉**
