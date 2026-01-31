-- ============================================
-- KHDEMTI SCHEMA - CHAT UPDATE
-- ============================================

-- 9. Messages Table
CREATE TABLE IF NOT EXISTS messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id UUID REFERENCES bookings(id) ON DELETE CASCADE,
    sender_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    is_read BOOLEAN DEFAULT FALSE
);

-- Enable RLS
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "messages_select" ON messages FOR SELECT 
    USING (auth.uid() = sender_id OR EXISTS (
        SELECT 1 FROM bookings b 
        WHERE b.id = messages.booking_id 
        AND (b.customer_id = auth.uid() OR b.provider_id = auth.uid())
    ));

CREATE POLICY "messages_insert" ON messages FOR INSERT 
    WITH CHECK (auth.uid() = sender_id);

-- Update existing tables if needed (optional)
-- We might want to ensure 'bookings' exists as referenced above.
