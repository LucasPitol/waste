# Waste API

## Overview

Waste API is a modular, serverless backend for a collaborative personal finance app. It is designed to support multiple users, wallets, and transactions, with a focus on sharing, security, and extensibility. The backend is built using Firebase Functions for the API layer, Supabase (PostgreSQL) for the main business data, and Firestore for temporary/verification data.

## Features
- **User Management:** Registration, login, password reset, and email verification (with Firestore for codes)
- **Wallets:** Multiple wallets per user, owner/member roles, add/remove members, default wallet on registration
- **Transactions:** Add/view transactions, income/expense types, spending categories, per-wallet and per-user queries
- **Spending Categories:** Custom and default categories, per-transaction assignment
- **Security:** Passwords hashed with bcrypt, all IDs are UUIDs, access checks for all wallet/transaction actions
- **API:** Modular endpoints for cold start optimization, clear separation of use-cases, services, and data access
- **Database:**
  - **Supabase:** Main data (users, wallets, wallet_members, transactions, spending_categories)
  - **Firestore:** Temporary/verification codes only

## Tech Stack
- **API:** Firebase Functions (Node.js, TypeScript)
- **Database:** Supabase (PostgreSQL, UUIDs for all IDs)
- **Temporary Data:** Firestore (for verification codes)
- **Auth:** Custom (bcrypt), but can be extended to Supabase Auth

## Folder Structure
- `src/endpoints/` — Modular HTTP endpoints for each feature
- `src/use-cases/` — Business logic for each operation
- `src/services/` — Service layer for business rules and orchestration
- `src/db/sp/` — Supabase data access (SP = Service/Proxy)
- `src/models/` — Data models and DTOs
- `src/utils/` — Utility functions and constants

## How It Works
- **User registration:**
  1. User requests verification code (Firestore)
  2. User submits code, then registers (Supabase `users`)
  3. Default wallet is created, user is owner/member
- **Login:**
  - Email/password checked against Supabase, bcrypt for password
- **Wallets:**
  - Users can create wallets; only wallet owners can add/remove members
  - Leave wallet functionality will be implemented later
- **Transactions:**
  - Users can add/view transactions in wallets they own or are members of
  - Transactions are saved with a business date (`transaction_date`)
- **Spending Categories:**
  - Used for transaction classification and reporting

## API Endpoints (Examples)
- `POST /createNewUser` — Register new user
- `POST /signIn` — Login
- `POST /wallet/create` — Create wallet
- `POST /wallet/addMember` — Add member to wallet
- `POST /wallet/getUserWallets` — Get all wallets for a user
- `POST /transaction/save` — Save new transaction
- `POST /transaction/get` — Get transactions by wallet/date

## Database Schema (Supabase)
- **users:** id (uuid), display_name, email, password, created_at, last_update
- **wallets:** id (uuid), name, owner_id (uuid), creation_date, last_update
- **wallet_members:** id (uuid), wallet_id (uuid), user_id (uuid), role, added_at
- **transactions:** id (uuid), wallet_id (uuid), user_id (uuid), amount, type, reason, spending_category_id (uuid), creation_date, last_update, transaction_date
- **spending_categories:** id (uuid), name, ...

## Security & Best Practices
- All IDs are UUIDs (no integer IDs)
- Passwords are always hashed with bcrypt
- All access to wallets/transactions is checked (owner/member)
- Modular endpoints for fast cold starts
- Environment variables for all secrets/keys

## How to Deploy/Run
1. Clone the repo
2. Set up `.env` with Supabase and Firebase credentials
3. Deploy with `firebase deploy --only functions`
4. Use the API endpoints from your frontend or tools like Postman

## Extending
- Add more endpoints by creating new files in `src/endpoints/`
- Add new business logic in `src/use-cases/`
- Add new data access logic in `src/db/sp/`

## License
MIT
