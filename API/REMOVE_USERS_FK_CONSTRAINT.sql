-- Remove all problematic foreign key constraints
-- Run this in your Supabase SQL Editor

-- Drop foreign key constraints that reference auth.users
ALTER TABLE users DROP CONSTRAINT IF EXISTS users_id_fkey;
ALTER TABLE wallets DROP CONSTRAINT IF EXISTS wallets_owner_id_fkey;
ALTER TABLE wallet_members DROP CONSTRAINT IF EXISTS wallet_members_user_id_fkey;
ALTER TABLE transactions DROP CONSTRAINT IF EXISTS transactions_user_id_fkey;

-- Recreate proper foreign key constraints within our custom tables
-- wallets.owner_id should reference users.id (our custom users table)
ALTER TABLE wallets ADD CONSTRAINT wallets_owner_id_fkey 
    FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE CASCADE;

-- wallet_members.user_id should reference users.id (our custom users table)  
ALTER TABLE wallet_members ADD CONSTRAINT wallet_members_user_id_fkey
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- transactions.user_id should reference users.id (our custom users table)
ALTER TABLE transactions ADD CONSTRAINT transactions_user_id_fkey
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- Keep other foreign key constraints that are correct
-- wallet_members.wallet_id -> wallets.id
-- transactions.wallet_id -> wallets.id  
-- transactions.spending_category_id -> spending_categories.id

-- Verify the constraints
SELECT 
    tc.constraint_name,
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc 
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
    AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY' 
    AND tc.table_name IN ('users', 'wallets', 'wallet_members', 'transactions')
ORDER BY tc.table_name, tc.constraint_name;
