-- ============================================
-- KHDEMTI DATABASE SCHEMA - UPDATED
-- ============================================
-- Run this in your Supabase SQL Editor

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- DROP EXISTING TABLES
-- ============================================
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;

DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS ads CASCADE;
DROP TABLE IF EXISTS saved_addresses CASCADE;
DROP TABLE IF EXISTS ratings CASCADE;
DROP TABLE IF EXISTS bookings CASCADE;
DROP TABLE IF EXISTS provider_services CASCADE;
DROP TABLE IF EXISTS services CASCADE;
DROP TABLE IF EXISTS profiles CASCADE;

-- ============================================
-- CREATE TABLES
-- ============================================

-- 1. Profiles table
-- Removed REFERENCES auth.users(id) to allow creating manual provider profiles
CREATE TABLE profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone TEXT,
    full_name TEXT,
    email TEXT,
    avatar_url TEXT,
    age INTEGER, 
    manual_rating DECIMAL(3,1) DEFAULT 0.0,
    role TEXT DEFAULT 'customer' CHECK (role IN ('customer', 'provider', 'admin', 'super_admin')),
    bio TEXT,
    is_online BOOLEAN DEFAULT FALSE,
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Services catalog
CREATE TABLE services (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    base_price DECIMAL(10,2),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Provider services
CREATE TABLE provider_services (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    provider_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    service_id TEXT REFERENCES services(id) ON DELETE CASCADE,
    hourly_rate DECIMAL(10,2),
    is_available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(provider_id, service_id)
);

-- 4. Bookings
CREATE TABLE bookings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    provider_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    service_id TEXT REFERENCES services(id) ON DELETE SET NULL,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'in_progress', 'completed', 'cancelled', 'rejected')),
    scheduled_at TIMESTAMPTZ,
    address TEXT,
    notes TEXT,
    is_urgent BOOLEAN DEFAULT FALSE,
    price DECIMAL(10,2),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Ratings
CREATE TABLE ratings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id UUID REFERENCES bookings(id) ON DELETE CASCADE,
    rater_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    target_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. Saved addresses
CREATE TABLE saved_addresses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    label TEXT,
    address TEXT NOT NULL,
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. Ads
CREATE TABLE ads (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT,
    description TEXT,
    image_url TEXT,
    link_url TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    priority INTEGER DEFAULT 0,
    starts_at TIMESTAMPTZ,
    ends_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. Notifications
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    body TEXT,
    type TEXT DEFAULT 'general',
    data JSONB,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- ENABLE ROW LEVEL SECURITY
-- ============================================
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE services ENABLE ROW LEVEL SECURITY;
ALTER TABLE provider_services ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE ratings ENABLE ROW LEVEL SECURITY;
ALTER TABLE saved_addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE ads ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- ============================================
-- CREATE POLICIES
-- ============================================

-- Profiles
CREATE POLICY "profiles_select" ON profiles FOR SELECT USING (true);
-- Allow authenticated users to insert (for signup) and admins to insert (for manual add)
CREATE POLICY "profiles_insert" ON profiles FOR INSERT WITH CHECK (true);
CREATE POLICY "profiles_update" ON profiles FOR UPDATE USING (auth.uid() = id OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'super_admin')));
CREATE POLICY "profiles_delete" ON profiles FOR DELETE USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'super_admin')));

-- Services
CREATE POLICY "services_select" ON services FOR SELECT USING (true);

-- Provider services
CREATE POLICY "provider_services_select" ON provider_services FOR SELECT USING (true);
CREATE POLICY "provider_services_insert" ON provider_services FOR INSERT WITH CHECK (true);

-- Bookings
CREATE POLICY "bookings_select" ON bookings FOR SELECT 
    USING (auth.uid() = customer_id OR auth.uid() = provider_id OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'super_admin')));
CREATE POLICY "bookings_insert" ON bookings FOR INSERT WITH CHECK (auth.uid() = customer_id);
CREATE POLICY "bookings_update" ON bookings FOR UPDATE 
    USING (auth.uid() = customer_id OR auth.uid() = provider_id OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'super_admin')));

-- Ratings
CREATE POLICY "ratings_select" ON ratings FOR SELECT USING (true);

-- Saved addresses
CREATE POLICY "addresses_select" ON saved_addresses FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "addresses_insert" ON saved_addresses FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "addresses_update" ON saved_addresses FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "addresses_delete" ON saved_addresses FOR DELETE USING (auth.uid() = user_id);

-- Notifications
CREATE POLICY "notifications_select" ON notifications FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "notifications_update" ON notifications FOR UPDATE USING (auth.uid() = user_id);

-- Ads
CREATE POLICY "ads_select" ON ads FOR SELECT USING (is_active = true);

-- ============================================
-- AUTO-CREATE PROFILE ON SIGNUP
-- ============================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if it is the admin phone number
    IF NEW.phone = '+212691157363' THEN
        INSERT INTO public.profiles (id, phone, role, full_name)
        VALUES (NEW.id, NEW.phone, 'super_admin', 'Super Admin')
        ON CONFLICT (id) DO UPDATE SET role = 'super_admin';
    ELSE
        INSERT INTO public.profiles (id, phone, role)
        VALUES (NEW.id, NEW.phone, 'customer')
        ON CONFLICT (id) DO NOTHING;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- INSERT DEFAULT SERVICES
-- ============================================
INSERT INTO services (id, name, description, base_price) VALUES
    ('plumber', 'Plumber', 'Plumbing repairs', 100),
    ('electrician', 'Electrician', 'Electrical work', 120),
    ('carpenter', 'Carpenter', 'Wood and furniture', 100),
    ('ac', 'AC & Cooling', 'AC installation and repair', 150),
    ('painter', 'Painter', 'Interior and exterior painting', 80),
    ('cleaning', 'Cleaning', 'Home cleaning', 70),
    ('locksmith', 'Locksmith', 'Lock repairs', 90),
    ('handyman', 'Handyman', 'General repairs', 80),
    ('garden', 'Gardening', 'Garden maintenance', 60),
    ('mechanic', 'Car Mechanic', 'Vehicle repairs', 130),
    ('roofer', 'Roofer', 'Roof repairs', 150),
    ('window', 'Window Cleaning', 'Window cleaning', 50),
    ('laundry', 'Laundry', 'Laundry services', 40),
    ('computer', 'PC Repair', 'Computer repairs', 100),
    ('phone', 'Phone Repair', 'Phone repairs', 80),
    ('barber', 'Barber', 'Haircuts', 50),
    ('makeup', 'Makeup Artist', 'Makeup services', 100),
    ('tailor', 'Tailor', 'Clothing alterations', 60),
    ('moto', 'Moto Repair', 'Motorcycle repairs', 90),
    ('courier', 'Courier', 'Delivery services', 30)
ON CONFLICT (id) DO NOTHING;
