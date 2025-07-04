// User endpoints
export { logIn } from "./endpoints/user/login";
export { createNewUser } from "./endpoints/user/create-user";
export { updatePassword } from "./endpoints/user/update-password";
export { sendVerificationCode } from "./endpoints/user/send-verification-code";
export { validateVerificationCode } from "./endpoints/user/validate-verification-code";
export { loginByUid } from "./endpoints/user/login-by-uid";

// Wallet endpoints
export { getUserWallets } from "./endpoints/wallet/get-user-wallets";
export { createNewWallet } from "./endpoints/wallet/create-wallet";
export { removeMemberFromWallet } from "./endpoints/wallet/remove-member";
export { getMembersByMemberIds } from "./endpoints/wallet/get-members";
export { addMemberToWallet } from "./endpoints/wallet/add-member";

// Transaction endpoints
export { getTransactionsByWalletIdAndDateInterval } from "./endpoints/transaction/get-transactions";
export { saveTransaction } from "./endpoints/transaction/save-transaction";
export { getOverviewPageData } from "./endpoints/transaction/get-overview";

// Spending categories
export { getSpendingCategories } from "./endpoints/spending-categories";

// Test endpoints
export { test } from "./endpoints/test";
export { testSupabaseConnection } from "./endpoints/test/supabase-connection";
export { debugDatabaseSchema } from "./endpoints/test/debug-schema";

// Legacy Firebase setup (if still needed for other parts)
import * as admin from "firebase-admin";
admin.initializeApp();
export const db = admin.firestore();
