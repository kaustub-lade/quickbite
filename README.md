# 🍽️ QuickBite - Your AI Food Assistant

QuickBite is a smart food-ordering intelligence platform that helps users make better ordering decisions by comparing prices across Swiggy, Zomato, and ONDC, while providing AI-powered recommendations.

## 🎯 Features (MVP)

- **Smart Recommendations**: Get intelligent food suggestions based on your mood
- **Multi-Platform Comparison**: Compare prices across ONDC, Swiggy, and Zomato
- **Best Deal Finding**: Automatically identifies the cheapest option with savings breakdown
- **Fast Delivery Options**: See which platform delivers fastest
- **Transparent Pricing**: See exactly why each option is recommended

## 🚀 Getting Started

### Prerequisites

- Node.js 18+ installed
- npm or yarn
- MongoDB Atlas account (free tier works)

### Installation

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Set up environment variables:**
   ```bash
   # Copy the example env file
   cp .env.example .env.local
   ```

3. **Configure MongoDB Atlas:**
   - Go to [MongoDB Atlas](https://cloud.mongodb.com) and create a free account
   - Create a new cluster (M0 free tier)
   - Create a database user and note the credentials
   - Get your connection string
   - Update `.env.local` with your connection string:
     ```
     MONGODB_URI=mongodb+srv://username:password@cluster0.xxxxx.mongodb.net/quickbite
     ```

4. **Set up the database:**
   - Follow the complete guide in `docs/mongodb-setup.md`
   - Insert sample data using MongoDB Atlas UI or Compass
   - Test connection at `/api/db-test`

5. **Run the development server:**
   ```bash
   npm run dev
   ```

6. **Open your browser:**
   Visit [http://localhost:3000](http://localhost:3000)

## 📁 Project Structure

```
quickbite/
├── app/
│   ├── page.tsx              # Main home page
│   ├── layout.tsx            # Root layout
│   └── api/                  # API routes
│       ├── recommendations/  # Smart recommendation engine
│       └── db-test/          # Database connection test
├── lib/
│   ├── mongodb.ts            # MongoDB connection
│   └── models.ts             # Mongoose models & schemas
├── components/ui/            # shadcn/ui components
├── docs/
│   ├── mongodb-setup.md      # MongoDB Atlas setup guide
│   └── ...                   # Project documentation
├── .env.local                # Environment variables (not in git)
└── package.json
```

## 🗄️ Database Schema

The app uses 4 main MongoDB collections:

- **restaurants**: Restaurant details (name, cuisine, location, rating)
- **platforms**: Delivery platforms (ONDC, Swiggy, Zomato)
- **restaurantprices**: Pricing across different platforms with compound indexes
- **userorders**: Order history for learning and analytics

See `docs/mongodb-setup.md` for the complete setup guide and sample data.

## 🎨 Tech Stack

- **Framework**: Next.js 15 (App Router)
- **Language**: TypeScript
- **Styling**: Tailwind CSS v4 + shadcn/ui
- **Database**: MongoDB Atlas with Mongoose ODM
- **State Management**: Zustand
- **Icons**: Lucide React

## 🛣️ Roadmap

### Week 1 (Current - Feb 11, 2026)
- [x] Project setup with Next.js 15 + TypeScript
- [x] shadcn/ui component library integration
- [x] Professional UI with category selection
- [x] MongoDB Atlas connection setup
- [x] Mongoose models and schemas
- [x] API route for recommendations with smart algorithm
- [x] Database test endpoint
- [ ] Insert sample data in MongoDB
- [ ] Connect frontend to API

### Week 2
- [ ] ONDC integration
- [ ] Price estimation engine for Swiggy/Zomato
- [ ] User location detection
- [ ] Actual deep linking to platforms

### Week 3
- [ ] "Report actual price" feature
- [ ] User order tracking
- [ ] Basic analytics dashboard

### Week 4
- [ ] Deploy to Vercel
- [ ] Get first 50 beta users
- [ ] Collect feedback and iterate

## 📝 Development Commands

```bash
# Start development server
npm run dev

# Build for production
npm run build

# Start production server
npm start

# Run linter
npm run lint
```

## 🤝 Contributing

This is a startup MVP in active development. If you're interested in contributing or have feedback, please reach out!

## 🔗 Useful Links

- [MongoDB Atlas Dashboard](https://cloud.mongodb.com)
- [Next.js Docs](https://nextjs.org/docs)
- [Tailwind CSS](https://tailwindcss.com/docs)
- [shadcn/ui Components](https://ui.shadcn.com)
- [Mongoose Documentation](https://mongoosejs.com/docs)
- [Lucide Icons](https://lucide.dev)

---

**Built with ❤️ for smarter food ordering**
