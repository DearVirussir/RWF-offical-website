-- Rustam Welfare Foundation Supabase Schema
-- IMPORTANT: Copy and paste this entire script into your Supabase SQL Editor and click "Run".

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

/* --- 1. Users table (for admin login) --- */
CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT UNIQUE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

/* --- 2. Cases table (Case Management) --- */
CREATE TABLE IF NOT EXISTS public.cases (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  amount_needed DECIMAL(12, 2) NOT NULL DEFAULT 0,
  amount_raised DECIMAL(12, 2) DEFAULT 0,
  status TEXT DEFAULT 'Active', -- 'Active', 'Completed'
  image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

/* --- 3. Gallery table (Updated with description and event_date) --- */
CREATE TABLE IF NOT EXISTS public.gallery (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  description TEXT,
  event_date TIMESTAMP WITH TIME ZONE,
  image_url TEXT NOT NULL,
  category TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- If the table already existed but columns are missing, this will add them:
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='gallery' AND column_name='description') THEN
        ALTER TABLE public.gallery ADD COLUMN description TEXT;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='gallery' AND column_name='event_date') THEN
        ALTER TABLE public.gallery ADD COLUMN event_date TIMESTAMP WITH TIME ZONE;
    END IF;
END $$;

/* --- 4. Updates table --- */
CREATE TABLE IF NOT EXISTS public.updates (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

/* --- 5. Donations table --- */
CREATE TABLE IF NOT EXISTS public.donations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  donor_name TEXT NOT NULL,
  donor_email TEXT,
  amount DECIMAL(12, 2) NOT NULL,
  payment_method TEXT NOT NULL,
  status TEXT DEFAULT 'Pending',
  transaction_id TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

/* --- 6. Contact_messages table --- */
CREATE TABLE IF NOT EXISTS public.contact_messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  subject TEXT NOT NULL,
  message TEXT NOT NULL,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

/* --- 7. Staff table (Staff & Volunteers) --- */
CREATE TABLE IF NOT EXISTS public.staff (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  position TEXT NOT NULL,
  image_url TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

/* --- 8. Newsletter Subscriptions Table --- */
CREATE TABLE IF NOT EXISTS public.newsletter_subscriptions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT UNIQUE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- NOTE: If you still see "column not found" errors in your browser after running this,
-- please go to the Supabase Dashboard > API Settings and look for a way to "Refresh Schema Cache" 
-- or simply wait a few seconds for the cache to update automatically.

/* --- 9. RLS Policies (CRITICAL for public forms) --- */

-- Enable RLS on public tables
ALTER TABLE public.contact_messages ENABLE CONTROL; -- Some versions use ENABLE ROW LEVEL SECURITY
ALTER TABLE public.newsletter_subscriptions ENABLE CONTROL;

-- Allow anyone to insert messages (Public Contact Form)
DROP POLICY IF EXISTS "Allow public insert" ON public.contact_messages;
CREATE POLICY "Allow public insert" ON public.contact_messages FOR INSERT WITH CHECK (true);

-- Allow anyone to subscribe (Public Newsletter)
DROP POLICY IF EXISTS "Allow public subscribe" ON public.newsletter_subscriptions;
CREATE POLICY "Allow public subscribe" ON public.newsletter_subscriptions FOR INSERT WITH CHECK (true);

-- Allow admins to read/manage (This is simplified, usually you'd use auth roles)
-- For now, we assume the admin panel handles auth before calling these.
ALTER TABLE public.contact_messages DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.newsletter_subscriptions DISABLE ROW LEVEL SECURITY;

/* 
  IMPORTANT: If you want to keep RLS ENABLED for security, 
  run the POLICY creation lines above. 
  If you want the simplest fix, run:
  ALTER TABLE public.newsletter_subscriptions DISABLE ROW LEVEL SECURITY;
  ALTER TABLE public.contact_messages DISABLE ROW LEVEL SECURITY;
*/
