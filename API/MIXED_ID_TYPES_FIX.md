# Mixed ID Types Fix

## Problem
Your database has mixed ID types:
- `users.id` = int8 (integer)
- `wallets.id` = uuid 
- `wallets.owner_id` = uuid (but should be int8 to reference users.id)
- `wallet_members.user_id` = uuid (but should be int8 to reference users.id)

## Solution

**Step 1: Run the SQL script to fix foreign key types**

Go to your Supabase SQL Editor and run:

```sql
-- Fix wallets table: owner_id should be int8 to match users.id
ALTER TABLE wallets ALTER COLUMN owner_id TYPE int8;

-- Fix wallet_members table: user_id should be int8 to match users.id  
ALTER TABLE wallet_members ALTER COLUMN user_id TYPE int8;

-- Fix transactions table: user_id should be int8 to match users.id
ALTER TABLE transactions ALTER COLUMN user_id TYPE int8;

-- Verify the changes
SELECT 
    table_name,
    column_name,
    data_type
FROM information_schema.columns 
WHERE table_schema = 'public' 
    AND table_name IN ('users', 'wallets', 'wallet_members', 'transactions')
    AND column_name LIKE '%id%'
ORDER BY table_name, ordinal_position;
```

**Step 2: Test the fix**

After running the SQL, test your user creation:

1. Build and serve: `npm run build && npm run serve`
2. Test user creation: `POST /createNewUser`
3. Should work without the UUID error

## Expected Result

After the fix, your schema should be:
- `users.id` → int8 (primary key)
- `wallets.id` → uuid (primary key)  
- `wallets.owner_id` → int8 (references users.id)
- `wallet_members.id` → uuid (primary key)
- `wallet_members.wallet_id` → uuid (references wallets.id)
- `wallet_members.user_id` → int8 (references users.id)
- `transactions.id` → uuid (primary key)
- `transactions.wallet_id` → uuid (references wallets.id)
- `transactions.user_id` → int8 (references users.id)

## Code Changes Made

The TypeScript code has been updated to:
- Convert user IDs to integers before database operations
- Keep wallet IDs and transaction IDs as UUID strings
- Handle mixed ID types correctly in all SP methods
