-- Add role and worker_type columns to profiles table
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'user',
ADD COLUMN IF NOT EXISTS worker_type TEXT;

-- Add expires_at column to ads table (fix the error)
ALTER TABLE ads 
ADD COLUMN IF NOT EXISTS expires_at TIMESTAMP DEFAULT (NOW() + INTERVAL '30 days');

-- Update existing ads with default expiry
UPDATE ads 
SET expires_at = NOW() + INTERVAL '30 days' 
WHERE expires_at IS NULL;

-- Create index for faster role queries
CREATE INDEX IF NOT EXISTS idx_profiles_role ON profiles(role);
CREATE INDEX IF NOT EXISTS idx_profiles_worker_type ON profiles(worker_type);

-- Update RLS policies to support new roles
-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Admin can view all profiles" ON profiles;

-- Create new policies
CREATE POLICY "Users can view own profile" 
ON profiles FOR SELECT 
USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" 
ON profiles FOR UPDATE 
USING (auth.uid() = id);

CREATE POLICY "Admin can view all profiles" 
ON profiles FOR SELECT 
USING (
  EXISTS (
    SELECT 1 FROM profiles 
    WHERE id = auth.uid() 
    AND role = 'admin'
  )
);

CREATE POLICY "Admin can update all profiles" 
ON profiles FOR UPDATE 
USING (
  EXISTS (
    SELECT 1 FROM profiles 
    WHERE id = auth.uid() 
    AND role = 'admin'
  )
);

-- Comments for documentation
COMMENT ON COLUMN profiles.role IS 'User role: guest, user, worker, admin';
COMMENT ON COLUMN profiles.worker_type IS 'Type of worker service: cleaner, plumber, electrician, etc.';
COMMENT ON COLUMN ads.expires_at IS 'Expiration timestamp for promotional ads';
