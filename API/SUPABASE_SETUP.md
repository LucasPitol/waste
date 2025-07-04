# Supabase Configuration Guide

## Environment Setup

### Local Development
1. Copy `.env.example` to `.env`
2. Fill in your Supabase project details:
   - `SUPABASE_URL`: Your Supabase project URL
   - `SUPABASE_SERVICE_KEY`: Your service role key (not anon key!)
   - `SUPABASE_ANON_KEY`: Your public anon key (optional)

### Firebase Functions Deployment
Set configuration using Firebase CLI:

```bash
# Set Supabase configuration
firebase functions:config:set supabase.url="https://your-project-id.supabase.co"
firebase functions:config:set supabase.service_key="your-service-role-key"

# Deploy functions
firebase deploy --only functions
```

## Important Notes

### Service Role Key vs Anon Key
- **Service Role Key**: Use for server-side operations (bypasses RLS)
- **Anon Key**: Use for client-side operations (respects RLS)

For this API, we need the **Service Role Key** because:
- We're running server-side code
- We need to bypass Row Level Security (RLS)
- We're handling our own authentication logic

### Row Level Security (RLS)
If you have RLS enabled on your Supabase tables, you have two options:

1. **Disable RLS** (simpler but less secure):
   ```sql
   ALTER TABLE wallets DISABLE ROW LEVEL SECURITY;
   ALTER TABLE wallet_members DISABLE ROW LEVEL SECURITY;
   ALTER TABLE transactions DISABLE ROW LEVEL SECURITY;
   ALTER TABLE users DISABLE ROW LEVEL SECURITY;
   ```

2. **Keep RLS and add policies** (more secure):
   - Create policies that allow service role access
   - Or use the service role key which bypasses RLS

### Testing Connection
You can test the connection by running:
```bash
cd functions
npm run build
npm run serve
```

Then make a test request to any endpoint to verify database connectivity.

## Database Schema and UUIDs

**CRITICAL:** The application requires UUID primary keys for all tables. If you see errors like:
```
invalid input syntax for type uuid: "2"
```

Your database is using integer IDs instead of UUIDs. 

**See `UUID_MIGRATION_GUIDE.md` for complete migration instructions.**

### Quick Setup (New Database)
Run the SQL script in `SUPABASE_SCHEMA_WITH_UUID.sql` in your Supabase SQL Editor.

### Migration (Existing Database) 
Run the migration script in `MIGRATE_USERS_TO_UUID.sql` to convert existing tables.

### Verification
Test the schema with the debug endpoint:
```bash
GET /debugDatabaseSchema
```
Should show `isUUID: true` for all IDs.
