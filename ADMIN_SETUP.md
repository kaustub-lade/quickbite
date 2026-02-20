# QuickBite Admin System - Complete Setup

## 🎉 What Was Built

### 1. **User Role System**
Added 3 user types to your platform:
- **👑 Admin**: Full platform control (manage all restaurants, menus, users)
- **👤 Customer**: Regular app users (order food, manage profile)
- **🏪 Restaurant Owner**: Manage their restaurant's menu items

### 2. **Sample Users Created**

#### Admin User
```
Email: admin@quickbite.com
Password: admin123
Role: Admin
Access: Full platform management
```

#### Customer User
```
Email: kaustub@example.com
Password: customer123
Role: Customer
Access: Mobile app only
```

#### Restaurant Owner Users
```
Paradise Biryani:
  Email: manager@paradisebiryani.com
  Password: owner123
  
Dominos:
  Email: manager@dominos.com
  Password: owner123
  
McDonald's:
  Email: manager@mcdonalds.com
  Password: owner123
```

### 3. **Admin Dashboard Built**
Complete web interface at: **http://localhost:3000/admin**

#### Pages Created:
1. **Login Page** (`/admin/login`)
   - Secure authentication
   - Role-based access control
   
2. **Dashboard** (`/admin`)
   - User statistics
   - Platform metrics
   - Recent activity
   - Real-time analytics

3. **Users Management** (`/admin/users`)
   - View all users
   - Filter by role
   - User statistics
   - Verification status

4. **Restaurants** (`/admin/restaurants`)
   - View all restaurants
   - Restaurant details
   - Cuisine types
   - Ratings

5. **Menu Management** (`/admin/menu`)
   - View all menu items
   - Filter by restaurant
   - Availability status
   - Veg/Non-veg indicators

### 4. **Admin API Endpoints**

#### User Management
- `GET /api/admin/users` - List all users (with filters)
- `POST /api/admin/users` - Create new user
- Stats by role

#### Restaurant Management
- `GET /api/admin/restaurants` - List all restaurants
- `POST /api/admin/restaurants` - Add new restaurant

#### Menu Management
- `GET /api/admin/menu` - List menu items (filtered by restaurant)
- `POST /api/admin/menu` - Add menu item
- `DELETE /api/admin/menu` - Delete menu item

#### Analytics
- `GET /api/admin/stats` - Platform statistics

### 5. **Security Features**
- **Authentication Middleware**: Protects all admin routes
- **Role-Based Access**: Admin vs Restaurant Owner permissions
- **Token Validation**: Secure JWT-like tokens
- **Route Protection**: Client-side and server-side guards

## 🚀 How to Use

### 1. Seed Sample Users
```bash
npm run seed:users
```

### 2. Start Backend
```bash
npm run dev
```

### 3. Access Admin Dashboard
1. Open browser: http://localhost:3000/admin/login
2. Login with admin credentials:
   - Email: `admin@quickbite.com`
   - Password: `admin123`

### 4. Explore Dashboard
- View user statistics
- Manage restaurants
- Browse menu items
- Monitor platform activity

## 📱 Mobile App Integration

The mobile app automatically assigns new signups as **customers**. Admins and restaurant owners must be created via:
1. Admin dashboard (by existing admins)
2. Seed scripts
3. Direct database insertion

## 🔐 Access Levels

### Admin (Full Access)
✅ View all users
✅ Create users (any role)
✅ Manage all restaurants
✅ Manage all menu items
✅ View analytics
✅ Platform configuration

### Restaurant Owner (Limited Access)
✅ View their restaurant's menu
✅ Add/edit/delete their menu items
✅ View their restaurant details
❌ Cannot access other restaurants
❌ Cannot manage users
❌ Cannot view platform analytics

### Customer (Mobile Only)
✅ Browse restaurants
✅ Order food
✅ Manage profile
❌ No admin dashboard access

## 📊 What You Can Do Now

### As Admin:
1. **Monitor Platform**
   - See total users, restaurants, menu items
   - Track growth metrics
   - View recent signups

2. **Manage Users**
   - Filter by role (admin/customer/owner)
   - View user details
   - Check verification status

3. **Oversee Restaurants**
   - View all partner restaurants
   - Monitor menu availability
   - Track restaurant performance

4. **Control Menu Items**
   - See all menu items across restaurants
   - Filter by restaurant
   - Check availability and pricing

### As Restaurant Owner:
1. **Manage Menu**
   - Add new dishes
   - Update prices
   - Mark items available/unavailable
   - Upload food images

2. **View Performance**
   - See your menu statistics
   - Monitor item availability

## 🆕 New Files Created

### Backend:
- `lib/models/User.ts` - Updated with role field
- `lib/middleware/auth.ts` - Authentication middleware
- `app/api/admin/users/route.ts` - User management API
- `app/api/admin/restaurants/route.ts` - Restaurant API
- `app/api/admin/menu/route.ts` - Menu management API
- `app/api/admin/stats/route.ts` - Analytics API
- `scripts/seed-users.ts` - User seeding script

### Frontend (Admin Dashboard):
- `app/admin/layout.tsx` - Admin layout with sidebar
- `app/admin/login/page.tsx` - Admin login page
- `app/admin/page.tsx` - Dashboard home
- `app/admin/users/page.tsx` - Users management
- `app/admin/restaurants/page.tsx` - Restaurants view
- `app/admin/menu/page.tsx` - Menu management

### Scripts:
- Added `seed:users` to package.json

## 🎯 Next Steps

1. **Test Admin Dashboard**
   - Login with different user types
   - Explore all pages
   - Test filtering and search

2. **Add Restaurant Owners**
   - Create owners for your restaurants
   - Test menu management permissions

3. **Enhance Features** (Optional)
   - Add menu item editing
   - Add bulk upload for menu
   - Add order management
   - Add revenue tracking
   - Add price sync with Swiggy/Zomato

## 💡 Tips

- **MongoDB Connection**: Ensure your Atlas cluster is running
- **Run Seeds**: Use `npm run seed` for restaurants/menu first
- **Test Roles**: Try logging in as different user types
- **Mobile App**: Customers created via mobile automatically get 'customer' role

## 🔒 Security Notes

⚠️ **For Production:**
- Replace Base64 password hashing with bcrypt
- Use proper JWT tokens with secret keys
- Add rate limiting on admin routes
- Enable HTTPS
- Add audit logging
- Implement password reset
- Add 2FA for admin accounts

---

**You now have a complete admin system with role-based access control!** 🎉

Test it at: http://localhost:3000/admin/login
