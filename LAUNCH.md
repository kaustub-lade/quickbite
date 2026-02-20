# 🚀 QuickBite Launch Guide

## Prerequisites
- ✅ Flutter 3.35.6 installed
- ✅ Node.js installed
- ✅ MongoDB Atlas connected
- ✅ Dependencies installed

## Quick Start (2 Terminals)

### Terminal 1: Backend
```bash
# From project root
npm run dev
```
**Expected:** Backend running on `http://localhost:3000`

### Terminal 2: Mobile App
```bash
# From project root
cd mobile
flutter run
```
**Options:**
- Select `Chrome` or `Edge` for web preview (fastest)
- Select `Android Emulator` for mobile view
- Select `Windows` for desktop app

## 🎯 First Launch Flow

1. **App Opens** → See home screen with 4 categories
2. **Tap "Biryani"** → API fetches real recommendations from MongoDB
3. **Tap a restaurant** → See full menu with mock data
4. **Tap ADD on menu item** → Item added to cart
5. **Cart icon updates** → Shows item count badge
6. **Tap cart icon** → See complete bill breakdown
7. **Tap "Proceed to Checkout"** → Demo checkout (clears cart)

## 🔥 Hot Reload

While app is running:
- Press `r` → Hot reload (reflects UI changes instantly)
- Press `R` → Hot restart (resets app state)
- Press `q` → Quit app

## 🐛 Troubleshooting

### Backend won't start
```bash
# Check if port 3000 is free
netstat -ano | findstr :3000

# If occupied, kill the process or change port in .env.local
```

### Flutter can't connect to API
```bash
# Check backend is running: http://localhost:3000/api/db-test
# For Android emulator, API uses: http://10.0.2.2:3000
# For web/desktop, API uses: http://localhost:3000
```

### App shows errors
```bash
# Clean and rebuild
cd mobile
flutter clean
flutter pub get
flutter run
```

## 📱 Platform-Specific Notes

### Web (Chrome/Edge)
- ✅ Fastest for testing
- ✅ Hot reload works perfectly
- ⚠️ Some mobile gestures different

### Android Emulator
- ✅ Full mobile experience
- ✅ Proper touch gestures
- ⚠️ Slower initial build (1-2 mins)
- Uses `10.0.2.2:3000` instead of `localhost:3000`

### Windows Desktop
- ✅ Native Windows app
- ✅ Fast performance
- ⚠️ Desktop layout (might look stretched)

## 🎨 What's Working

✅ **Complete Features:**
- Home screen with categories
- API integration with real MongoDB data
- Restaurant browsing
- Menu viewing (mock data)
- Shopping cart with validation
- Search functionality
- Bill breakdown
- Material 3 design

⚠️ **Using Mock Data:**
- Menu items (hardcoded in restaurant_detail_screen.dart)
- Food images (placeholder icons)

## 🔄 Development Workflow

1. **Start both terminals** (backend + mobile)
2. **Make code changes** in VS Code
3. **Press 'r' in Flutter terminal** → See changes instantly
4. **Test features** → Add to cart, search, navigate
5. **Check backend logs** if API issues

## 🎉 Success Checklist

After launching, verify:
- [ ] Home screen loads with 4 categories
- [ ] Tapping category shows recommendations
- [ ] Restaurant list shows real data (Paradise, Meghana, etc.)
- [ ] Can navigate to restaurant detail
- [ ] Can add items to cart
- [ ] Cart badge updates in AppBar
- [ ] Search screen works
- [ ] Cart screen shows bill breakdown

## 📚 Next Steps

Once app is running smoothly:
1. Connect menu API (replace mock menu data)
2. Add real food images
3. Implement user authentication
4. Add payment integration
5. Deploy to production

---

**Ready to launch?** Run the two commands above in separate terminals! 🚀
