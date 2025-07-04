-- Migration script to convert users table from integer ID to UUID
-- This must be run on your Supabase database via SQL Editor

-- Step 1: Create a new column for UUID
ALTER TABLE users ADD COLUMN id_uuid UUID DEFAULT gen_random_uuid();

-- Step 2: Update all existing records to have UUID values
UPDATE users SET id_uuid = gen_random_uuid() WHERE id_uuid IS NULL;

-- Step 3: Update wallet records to use the new UUIDs
-- First, add a temporary column in wallets table
ALTER TABLE wallets ADD COLUMN owner_id_uuid UUID;

-- Update wallet records to use the new UUID from users table
UPDATE wallets SET owner_id_uuid = users.id_uuid 
FROM users 
WHERE wallets.owner_id = users.id;

-- Step 4: Update wallet_members table as well
ALTER TABLE wallet_members ADD COLUMN user_id_uuid UUID;

UPDATE wallet_members SET user_id_uuid = users.id_uuid 
FROM users 
WHERE wallet_members.user_id = users.id;

-- Step 5: Update transactions table
ALTER TABLE transactions ADD COLUMN user_id_uuid UUID;

UPDATE transactions SET user_id_uuid = users.id_uuid 
FROM users 
WHERE transactions.user_id = users.id;

-- Step 6: Drop old columns and rename new ones
-- Drop foreign key constraints first
ALTER TABLE wallets DROP CONSTRAINT IF EXISTS wallets_owner_id_fkey;
ALTER TABLE wallet_members DROP CONSTRAINT IF EXISTS wallet_members_user_id_fkey;
ALTER TABLE transactions DROP CONSTRAINT IF EXISTS transactions_user_id_fkey;

-- Drop old columns
ALTER TABLE wallets DROP COLUMN owner_id;
ALTER TABLE wallet_members DROP COLUMN user_id;
ALTER TABLE transactions DROP COLUMN user_id;

-- Rename new columns
ALTER TABLE wallets RENAME COLUMN owner_id_uuid TO owner_id;
ALTER TABLE wallet_members RENAME COLUMN user_id_uuid TO user_id;
ALTER TABLE transactions RENAME COLUMN user_id_uuid TO user_id;

-- Drop the old integer id column and rename the UUID column
ALTER TABLE users DROP CONSTRAINT IF EXISTS users_pkey;
ALTER TABLE users DROP COLUMN id;
ALTER TABLE users RENAME COLUMN id_uuid TO id;

-- Add primary key constraint
ALTER TABLE users ADD PRIMARY KEY (id);

-- Add back foreign key constraints
ALTER TABLE wallets ADD CONSTRAINT wallets_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES users(id);
ALTER TABLE wallet_members ADD CONSTRAINT wallet_members_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE transactions ADD CONSTRAINT transactions_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);

-- Optional: Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_wallets_owner_id ON wallets(owner_id);
CREATE INDEX IF NOT EXISTS idx_wallet_members_user_id ON wallet_members(user_id);
CREATE INDEX IF NOT EXISTS idx_transactions_user_id ON transactions(user_id);

-- Verify the changes
SELECT 
    column_name, 
    data_type, 
    is_nullable, 
    column_default
FROM information_schema.columns 
WHERE table_name = 'users' AND column_name = 'id';
