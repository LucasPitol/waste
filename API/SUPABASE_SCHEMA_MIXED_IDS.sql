-- Schema correction for mixed ID types
-- This matches your current setup: users.id as int8, other tables with UUID

-- Update wallets table to use int8 for owner_id (to match users.id)
ALTER TABLE wallets ALTER COLUMN owner_id TYPE int8;

-- Update wallet_members table to use int8 for user_id (to match users.id)  
ALTER TABLE wallet_members ALTER COLUMN user_id TYPE int8;

-- Update transactions table to use int8 for user_id (to match users.id)
ALTER TABLE transactions ALTER COLUMN user_id TYPE int8;

-- Keep wallet_id and transaction IDs as UUID since those tables use UUID primary keys

-- Verify the schema
SELECT 
    table_name,
    column_name,
    data_type
FROM information_schema.columns 
WHERE table_schema = 'public' 
    AND table_name IN ('users', 'wallets', 'wallet_members', 'transactions')
    AND column_name LIKE '%id%'
ORDER BY table_name, ordinal_position;
