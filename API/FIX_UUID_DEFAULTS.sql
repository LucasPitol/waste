-- Fix UUID default values for all tables
-- Run this in your Supabase SQL Editor

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Set default UUID generation for users table
ALTER TABLE users ALTER COLUMN id SET DEFAULT gen_random_uuid();

-- Set default UUID generation for other tables if needed
ALTER TABLE wallets ALTER COLUMN id SET DEFAULT gen_random_uuid();
ALTER TABLE wallet_members ALTER COLUMN id SET DEFAULT gen_random_uuid();
ALTER TABLE transactions ALTER COLUMN id SET DEFAULT gen_random_uuid();
ALTER TABLE spending_categories ALTER COLUMN id SET DEFAULT gen_random_uuid();

-- Verify the changes
SELECT 
    table_name,
    column_name,
    column_default,
    data_type
FROM information_schema.columns 
WHERE table_schema = 'public' 
    AND table_name IN ('users', 'wallets', 'wallet_members', 'transactions', 'spending_categories')
    AND column_name = 'id'
ORDER BY table_name;
