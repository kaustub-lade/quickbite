# QuickBite Mobile App 🍽️

Native Flutter mobile app for smart food ordering with AI-powered price comparisons.

## Current Status ✅

**✅ Completed:**
- Flutter project structure created
- All core UI screens built (HomeScreen with category selection)
- API service layer for backend connection
- Custom widgets (CategoryCard, RecommendationCard)
- Data models matching backend API
- Material 3 design with QuickBite branding

**⚠️ Setup Required:**
The Flutter CLI is encountering issues on Windows. Follow the manual setup steps below.

## Manual Setup Instructions

### Prerequisites
- Flutter SDK installed (run `flutter doctor` to verify)
- Android Studio or Xcode (for emulator/simulator)
- Next.js backend running on `localhost:3000`

### Steps to Fix Flutter CLI Issues

**Option 1: Clear Flutter Cache**
```powershell
# Close all terminals and VS Code
# Delete these folders:
C:\Users\<YourUser>\AppData\Local\Pub\Cache
C:\Users\<YourUser>\.flutter-devtools

# Reopen terminal and run:
flutter doctor -v
cd mobile
flutter pub get
```

**Option 2: Use Flutter from Git (if above fails)**
```powershell
# Navigate to your Flutter SDK directory
cd C:\path\to\flutter\bin\cache
rm -r -fo *
cd ..\..
.\bin\flutter doctor
```

**Option 3: Reinstall Flutter**
- Download fresh Flutter SDK from https://flutter.dev
- Extract to C:\flutter
- Add C:\flutter\bin to PATH
- Restart terminal
- Run `flutter doctor`

### After Flutter Works

1. **Install dependencies:**
   ```bash
   cd mobile
   flutter pub get
   ```

2. **Generate platform code:**
   ```bash
   # This creates android/ and ios/ folders
   flutter create --platforms=android,ios .
   ```

3. **Add internet permissions:**
   
   **Android** - Edit `mobile/android/app/src/main/AndroidManifest.xml`:
   ```xml
   <manifest xmlns:android="http://schemas.android.com/apk/res/android">
       <!-- Add this line: -->
       <uses-permission android:name="android.permission.INTERNET" />
       
       <application ...>
   ```

   **iOS** - Edit `mobile/ios/Runner/Info.plist`:
   ```xml
   <key>NSAppTransportSecurity</key>
   <dict>
       <key>NSAllowsArbitraryLoads</key>
       <true/>
   </dict>
   ```

4. **Start backend server:**
   ```bash
   cd ..
   npm run dev
   ```

5. **Run mobile app:**
   ```bash
   cd mobile
   flutter run
   ```

## Project Structure

```
mobile/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── models/
│   │   └── recommendation.dart      # Data models
│   ├── screens/
│   │   └── home_screen.dart         # Main UI
│   ├── services/
│   │   └── api_service.dart         # Backend API client
│   └── widgets/
│       ├── category_card.dart       # Category selection card
│       └── recommendation_card.dart # Restaurant card
├── pubspec.yaml                     # Dependencies
└── .env                             # Configuration
```

## API Configuration

**Android Emulator:**
- API URL: `http://10.0.2.2:3000` (connects to host machine's localhost:3000)

**iOS Simulator:**
- API URL: `http://localhost:3000` or `http://127.0.0.1:3000`

**Physical Device:**
- Update `api_service.dart` with your computer's IP address:
  ```dart
  static const String baseUrl = 'http://192.168.1.XXX:3000';
  ```

## Features

### Implemented
- ✅ Category selection (Biryani, Pizza, Burger, Healthy)
- ✅ Real-time recommendations from backend API
- ✅ Smart badge system (Best Deal 🥇, Fastest ⚡, Top Rated ⭐)
- ✅ Price comparison with savings calculation
- ✅ Restaurant cards with ratings, delivery time, platform
- ✅ Loading and error states
- ✅ Responsive Material 3 design

### To Do
- ⏳ Restaurant detail screen
- ⏳ Order placement
- ⏳ User statistics and savings tracking
- ⏳ Search functionality
- ⏳ Favorites
- ⏳ Order history
- ⏳ Push notifications

## Backend API

The mobile app connects to the existing Next.js backend:

**Endpoints Used:**
- `GET /api/recommendations?category={category}` - Get restaurant recommendations
- `GET /api/db-test` - Test MongoDB connection

**Categories:**  
`biryani`, `pizza`, `burger`, `healthy`

**Response Format:**
```json
{
  "category": "biryani",
  "count": 3,
  "recommendations": [
    {
      "id": "restaurant_platform_1",
      "title": "Paradise Biryani",
      "badge": "Best Deal",
      "badgeVariant": "success",
      "price": 320,
      "savings": 45,
      "platform": "ONDC",
      "deliveryTime": 35,
      "rating": 4.5,
      "reason": "Lowest price with fast delivery",
      "cuisine": "Biryani",
      "location": "Jubilee Hills"
    }
  ]
}
```

## Troubleshooting

### "No MaterialLocalizations found" Error
Run: `flutter pub get` and restart app

### "Failed host lookup: '10.0.2.2'" Error
- Ensure Next.js backend is running (`npm run dev` in root directory)
- Check your MongoDB connection is active
- Verify Android emulator is running (not iOS simulator)

### "SocketException: Connection refused"
- Backend not running - start with `npm run dev`
- Wrong IP address - use `10.0.2.2` for Android emulator

### "TimeoutException" Errors
- Check internet connection
- Increase timeout in `api_service.dart`
- Verify MongoDB Atlas connection string in backend `.env.local`

## Development Workflow

1. **Start backend:**
   ```bash
   npm run dev
   ```

2. **Hot reload mobile app:**
   ```bash
   cd mobile
   flutter run
   # Press 'r' to hot reload
   # Press 'R' to hot restart
   ```

3. **View logs:**
   ```bash
   flutter logs
   ```

## Testing

To test API connection without running full app:

1. Start backend: `npm run dev`
2. Test in browser: `http://localhost:3000/api/recommendations?category=biryani`
3. Should see JSON response with restaurant data

## Tech Stack

- **Frontend:** Flutter 3.x (Dart)
- **State Management:** Provider
- **HTTP Client:** Dio + http
- **UI:** Material 3 Design
- **Fonts:** Google Fonts (Inter)
- **Backend:** Next.js 15 API routes
- **Database:** MongoDB Atlas

## Environment Variables

Edit `mobile/.env`:
```env
API_BASE_URL=http://10.0.2.2:3000
```

For iOS simulator, change to:
```env
API_BASE_URL=http://localhost:3000
```

## Next Steps

1. **Fix Flutter CLI** - Follow setup instructions above
2. **Install dependencies** - `flutter pub get`
3. **Generate platform code** - `flutter create --platforms=android,ios .`
4. **Run app** - `flutter run`
5. **Test all categories** - Verify data loads from backend
6. **Add order functionality** - Implement ordering flow
7. **Deploy backend** - Use Vercel for production API

## Need Help?

**Common Issues:**
- Flutter CLI stuck: Clear cache and restart terminal
- Connection errors: Check backend is running on port 3000
- Build errors: Run `flutter clean` then `flutter pub get`

**Useful Commands:**
```bash
flutter doctor           # Check Flutter installation
flutter devices          # List available devices
flutter clean            # Clean build cache
flutter pub upgrade      # Update dependencies
```
