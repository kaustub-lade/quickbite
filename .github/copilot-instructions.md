# QuickBite - AI Coding Agent Instructions

## 🏗️ Architecture Overview

**Monorepo Structure**: This is a **hybrid monorepo** with two distinct applications that share no code:
- **Backend** (`/app`, `/lib`, `/scripts`): Next.js 16.1.6 with Turbopack, TypeScript, MongoDB Atlas
- **Mobile** (`/mobile`): Flutter 3.35+ with Dart, Provider state management

**Critical**: These are completely separate runtimes. Backend runs on `localhost:3000`, mobile connects via HTTP API. Never attempt to import backend code in mobile or vice versa.

## 🔑 Key Conventions

### Backend (Next.js + MongoDB)

**Next.js 16 Specifics**:
- Uses **App Router** (not Pages Router) - all routes in `app/` directory
- **Turbopack** bundler (not Webpack) - requires `@tailwindcss/postcss` plugin instead of standard `tailwindcss`
- **Root layout REQUIRED**: Must have `app/layout.tsx` with `<html>` and `<body>` tags or app crashes
- PostCSS config: Use `{ '@tailwindcss/postcss': {} }` not `tailwindcss` plugin

**Database Patterns**:
- **Two model locations**: Legacy models in `lib/models.ts` AND newer models in `lib/models/` directory (e.g., `Restaurant.ts`, `User.ts`)
- When adding models: Check both locations, prefer `lib/models/` for new models
- **Connection caching**: Always use `lib/mongodb.ts` connection manager (never create new connections)
- **Mongoose requirement**: All models must call `mongoose.models.X || mongoose.model()` pattern to avoid re-compilation errors

**API Route Pattern**:
```typescript
// app/api/[endpoint]/route.ts
import { NextRequest } from 'next/server'
import { connectToDatabase } from '@/lib/mongodb'

export async function GET(req: NextRequest) {
  await connectToDatabase()
  // Query using Mongoose models
  return Response.json({ data })
}
```

**Authentication**:
- Simple Base64 JWT tokens (not production-grade)
- Middleware in `lib/middleware/auth.ts` with `authenticateUser()` and `requireAdmin()`
- User model has 3 roles: `customer`, `restaurant_owner`, `admin`
- Admin routes protected with `requireAdmin()` check

### Mobile (Flutter + Provider)

**State Management**: Uses `provider` package, not BLoC/Riverpod/GetX
- **Two providers**: `ApiService` (HTTP client) and `CartProvider` (global cart state)
- Setup in `main.dart` with `MultiProvider`
- Access pattern: `Provider.of<CartProvider>(context)` or `context.read<CartProvider>()`

**API Configuration**:
- Base URL in `mobile/.env` file: `API_BASE_URL=http://localhost:3000`
- **Environment-specific URLs**:
  - Android emulator: `http://10.0.2.2:3000` (special IP for host machine)
  - iOS simulator: `http://localhost:3000`
  - Physical device: `http://192.168.1.x:3000` (computer's local IP)
  - Web/Chrome: `http://localhost:3000`
- Load with `flutter_dotenv`: `dotenv.env['API_BASE_URL']`

**Model Pattern**:
```dart
class Restaurant {
  final String id;
  final String name;
  
  Restaurant({required this.id, required this.name});
  
  factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
    id: json['id'] as String,
    name: json['name'] as String,
  );
}
```

**UI Architecture**:
- Material 3 design with orange theme (`#EA580C`)
- 4 main screens: Home, RestaurantDetail, Cart, Search
- Reusable widgets in `mobile/lib/widgets/` (CategoryCard, MenuItemCard, etc.)
- CustomScrollView with Slivers for performance on large lists

## 🚀 Critical Workflows

### Starting Development
```bash
# Backend (port 3000)
npm run dev

# Mobile - Web (Chrome)
cd mobile
flutter run -d chrome

# Mobile - Android Emulator
cd mobile
flutter run
```

### Database Operations
```bash
# Seed all data (restaurants, users, menu items)
npm run seed

# Seed specific collections
npm run seed:users
npm run seed:menu

# Test connection
curl http://localhost:3000/api/db-test
```

**Important**: Seed scripts use `tsx --env-file=.env.local` to load MongoDB connection string. Never commit `.env.local` (MongoDB credentials).

### Mobile Platform Setup
- **Add web support**: `cd mobile && flutter create .` (creates 59 files for web/desktop)
- **Build APK**: GitHub Actions workflow in `.github/workflows/build-apk.yml` auto-builds on push
- APK includes `.env` file baked in at build time (change requires rebuild)

## ⚠️ Common Pitfalls

1. **Tailwind not working**: Verify `postcss.config.js` uses `@tailwindcss/postcss` (not `tailwindcss`)
2. **Missing HTML tags error**: Ensure `app/layout.tsx` exists with proper structure
3. **MongoDB connection fails**: Check `.env.local` has `MONGODB_URI` with correct credentials
4. **Flutter localhost fails on device**: Physical devices can't use `localhost` - use computer's IP (`ipconfig` on Windows)
5. **Restaurant model not found**: Import from `@/lib/models/Restaurant` not `@/lib/models`
6. **Cart validation**: CartProvider enforces single restaurant per cart - shows dialog if user tries to add from different restaurant

## 📁 File Organization

**When adding features**:
- Backend API routes → `app/api/[feature]/route.ts`
- Backend models → `lib/models/[Model].ts` with TypeScript interface + Mongoose schema
- Mobile screens → `mobile/lib/screens/[feature]_screen.dart`
- Mobile widgets → `mobile/lib/widgets/[widget]_name.dart`
- Mobile models → `mobile/lib/models/[model].dart` with `fromJson()` factory

## 🎯 Testing Quick Reference

**Backend**:
- Homepage: `http://localhost:3000`
- Admin dashboard: `http://localhost:3000/admin/login`
- API test: `http://localhost:3000/api/db-test`

**Test Credentials**:
- Customer: `kaustub@example.com` / `customer123`
- Admin: `admin@quickbite.com` / `admin123`
- Restaurant Owner: `manager@paradisebiryani.com` / `owner123`

**Mobile**:
- Hot reload: Press `r` in terminal
- Hot restart: Press `R` in terminal
- Test connection: Run `dart mobile/lib/test_connection.dart`

## 📚 Reference Documentation

- Full architecture: `ARCHITECTURE.md` (954 lines, complete system design)
- Setup guide: `SETUP_GUIDE.md` (mobile app setup)
- Admin guide: `ADMIN_SETUP.md` (admin dashboard documentation)
- APK build: `APK_BUILD_GUIDE.md` (GitHub Actions workflow)

## 🔄 Integration Points

**Backend ⟷ Mobile**:
- Main API: `GET /api/recommendations?category=biryani` returns restaurant list with pricing
- Auth API: `POST /api/auth/login` with email/password, returns Base64 token
- Admin APIs: `/api/admin/users`, `/api/admin/restaurants`, `/api/admin/menu`, `/api/admin/stats`

**Data Flow**: Mobile → HTTP → Next.js API Route → Mongoose Model → MongoDB Atlas

**CORS**: Not configured (assumes same-origin or future backend deployment handles it)

## 💡 Project-Specific Patterns

- **Price comparison engine**: Backend calculates "Best Deal" by comparing same item across Swiggy/Zomato/ONDC platforms
- **Cart validation**: Different restaurant = show confirmation dialog, never silently merge
- **Veg/Non-veg indicators**: Green square (🟢) for veg, red square (🔴) for non-veg
- **Mongoose model safety**: Always use `mongoose.models.X || mongoose.model('X', schema)` to prevent re-registration
- **Material 3 theme**: Primary color orange `#EA580C`, use Material Design 3 components
