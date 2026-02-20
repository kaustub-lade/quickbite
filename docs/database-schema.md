# QuickBite - Database Schema

Run this SQL in your Supabase SQL Editor to set up the database:

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Restaurants table
CREATE TABLE restaurants (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  cuisine TEXT,
  location TEXT,
  latitude DECIMAL,
  longitude DECIMAL,
  rating DECIMAL,
  image_url TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Platforms table  
CREATE TABLE platforms (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL, -- 'swiggy', 'zomato', 'ondc'
  display_name TEXT NOT NULL,
  logo_url TEXT,
  deep_link_template TEXT
);

-- Restaurant prices across platforms
CREATE TABLE restaurant_prices (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  restaurant_id UUID REFERENCES restaurants(id) ON DELETE CASCADE,
  platform_id UUID REFERENCES platforms(id) ON DELETE CASCADE,
  base_price DECIMAL,
  delivery_fee DECIMAL,
  platform_fee DECIMAL,
  estimated_total DECIMAL,
  delivery_time_min INTEGER,
  is_scraped BOOLEAN DEFAULT FALSE,
  last_updated TIMESTAMP DEFAULT NOW(),
  UNIQUE(restaurant_id, platform_id)
);

-- User orders (for learning and analytics)
CREATE TABLE user_orders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id TEXT, -- Anonymous ID for now
  restaurant_id UUID REFERENCES restaurants(id),
  platform_id UUID REFERENCES platforms(id),
  actual_price DECIMAL,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Create indexes for better query performance
CREATE INDEX idx_restaurants_cuisine ON restaurants(cuisine);
CREATE INDEX idx_restaurant_prices_restaurant ON restaurant_prices(restaurant_id);
CREATE INDEX idx_restaurant_prices_platform ON restaurant_prices(platform_id);
CREATE INDEX idx_user_orders_user ON user_orders(user_id);

-- Insert default platforms
INSERT INTO platforms (name, display_name, deep_link_template) VALUES
  ('ondc', 'ONDC', 'https://ondc.org/order?restaurant={restaurant_id}'),
  ('swiggy', 'Swiggy', 'swiggy://restaurant?id={restaurant_id}'),
  ('zomato', 'Zomato', 'zomato://restaurant/{restaurant_id}');

-- Sample data for testing (Bangalore restaurants)
INSERT INTO restaurants (name, cuisine, location, rating) VALUES
  ('Paradise Biryani', 'Biryani', 'Koramangala, Bangalore', 4.3),
  ('Meghana Foods', 'Biryani', 'Residency Road, Bangalore', 4.5),
  ('Truffles', 'Burger', 'Koramangala, Bangalore', 4.4),
  ('Bowl Company', 'Healthy', 'Indiranagar, Bangalore', 4.2),
  ('Biryani Blues', 'Biryani', 'HSR Layout, Bangalore', 4.6),
  ('Empire Restaurant', 'Biryani', 'Brigade Road, Bangalore', 4.4),
  ('Pizza Hut', 'Pizza', 'Koramangala, Bangalore', 4.1),
  ('Dominos', 'Pizza', 'Indiranagar, Bangalore', 4.0);

-- Add sample pricing for Paradise Biryani
INSERT INTO restaurant_prices (restaurant_id, platform_id, base_price, delivery_fee, platform_fee, estimated_total, delivery_time_min)
SELECT 
  r.id,
  p.id,
  CASE 
    WHEN p.name = 'ondc' THEN 250
    WHEN p.name = 'swiggy' THEN 300
    WHEN p.name = 'zomato' THEN 320
  END as base_price,
  CASE 
    WHEN p.name = 'ondc' THEN 30
    WHEN p.name = 'swiggy' THEN 40
    WHEN p.name = 'zomato' THEN 40
  END as delivery_fee,
  CASE 
    WHEN p.name = 'ondc' THEN 0
    WHEN p.name = 'swiggy' THEN 5
    WHEN p.name = 'zomato' THEN 5
  END as platform_fee,
  CASE 
    WHEN p.name = 'ondc' THEN 280
    WHEN p.name = 'swiggy' THEN 345
    WHEN p.name = 'zomato' THEN 365
  END as estimated_total,
  CASE 
    WHEN p.name = 'ondc' THEN 35
    WHEN p.name = 'swiggy' THEN 25
    WHEN p.name = 'zomato' THEN 28
  END as delivery_time_min
FROM restaurants r
CROSS JOIN platforms p
WHERE r.name = 'Paradise Biryani';

-- Add sample pricing for other restaurants
INSERT INTO restaurant_prices (restaurant_id, platform_id, base_price, delivery_fee, platform_fee, estimated_total, delivery_time_min)
SELECT 
  r.id,
  p.id,
  CASE 
    WHEN p.name = 'ondc' THEN 280
    WHEN p.name = 'swiggy' THEN 320
    WHEN p.name = 'zomato' THEN 340
  END as base_price,
  CASE 
    WHEN p.name = 'ondc' THEN 30
    WHEN p.name = 'swiggy' THEN 40
    WHEN p.name = 'zomato' THEN 40
  END as delivery_fee,
  CASE 
    WHEN p.name = 'ondc' THEN 0
    WHEN p.name = 'swiggy' THEN 5
    WHEN p.name = 'zomato' THEN 5
  END as platform_fee,
  CASE 
    WHEN p.name = 'ondc' THEN 310
    WHEN p.name = 'swiggy' THEN 365
    WHEN p.name = 'zomato' THEN 385
  END as estimated_total,
  CASE 
    WHEN p.name = 'ondc' THEN 32
    WHEN p.name = 'swiggy' THEN 22
    WHEN p.name = 'zomato' THEN 25
  END as delivery_time_min
FROM restaurants r
CROSS JOIN platforms p
WHERE r.name IN ('Meghana Foods', 'Biryani Blues', 'Empire Restaurant');
```

## Next Steps

1. Go to your Supabase project: https://supabase.com/dashboard
2. Navigate to SQL Editor
3. Copy and paste the entire SQL above
4. Run it to create all tables and sample data
5. Update `.env.local` with your Supabase credentials
