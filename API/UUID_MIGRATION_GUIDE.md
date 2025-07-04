# UUID Migration Guide

## Problem
The current Supabase database is using integer IDs (int8/serial) for the users table, but the application code expects UUIDs everywhere. This causes errors like:

```
invalid input syntax for type uuid: "2"
```

## Solution

You need to migrate your Supabase database to use UUIDs for all ID columns. You have two options:

### Option 1: Fresh Schema (Recommended for Development)

If you're in development and can lose existing data:

1. Go to your Supabase SQL Editor
2. Run the script in `SUPABASE_SCHEMA_WITH_UUID.sql`
3. This will create fresh tables with proper UUID columns

### Option 2: Migrate Existing Data

If you have existing data you need to preserve:

1. Go to your Supabase SQL Editor  
2. Run the script in `MIGRATE_USERS_TO_UUID.sql`
3. This will convert your existing tables to use UUIDs while preserving data

## Testing

After running either migration:

1. Deploy your functions: `npm run deploy`
2. Test the debug endpoint: `GET /debugDatabaseSchema`
3. The response should show `isUUID: true` for both userId and walletId
4. Test user creation: `POST /createNewUser`
5. Test wallet creation: `POST /createWallet`

## Expected Schema After Migration

All tables should have UUID primary keys:

- `users.id` → UUID
- `wallets.id` → UUID  
- `wallets.owner_id` → UUID (references users.id)
- `wallet_members.id` → UUID
- `wallet_members.wallet_id` → UUID (references wallets.id)
- `wallet_members.user_id` → UUID (references users.id)
- `transactions.id` → UUID
- `transactions.wallet_id` → UUID (references wallets.id)
- `transactions.user_id` → UUID (references users.id)
- `spending_categories.id` → UUID

## Code Changes Already Made

The application code has been updated to:
- Remove all `parseInt()` calls for IDs
- Use UUID strings throughout all SP files
- Handle UUIDs in all service methods
- Expect UUIDs in all API endpoints

## Verification

After migration, these should work without errors:

1. User registration creates a user with UUID and default wallet
2. Login returns user with UUID
3. Wallet creation uses UUID owner_id
4. Wallet member management uses UUID user_id
5. Transaction creation uses UUID wallet_id and user_id

## If You Still See Integer IDs

If the debug endpoint shows integer IDs after migration:
1. Double-check the migration was successful
2. Verify the `id` column type in each table: `SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'id';`
3. The `data_type` should be `uuid`, not `bigint` or `integer`
