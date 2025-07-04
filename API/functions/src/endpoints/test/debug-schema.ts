import * as functions from "firebase-functions";
import { supabase } from "../../db/supabase";

export const debugDatabaseSchema = functions.https.onRequest(async (req, res) => {
  try {
    console.log("Debugging database schema...");

    // Test creating a simple user first
    const testUserResult = await supabase
      .from('users')
      .insert({
        display_name: 'Test User',
        email: 'test@example.com',
        password: 'hashed_password'
      })
      .select('id')
      .single();

    console.log('User creation test:', testUserResult);

    if (testUserResult.error) {
      res.status(500).send({
        success: false,
        step: 'user_creation',
        error: testUserResult.error,
        message: 'Failed to create test user'
      });
      return;
    }

    const userId = testUserResult.data.id;
    console.log('Test user created with ID:', userId, 'type:', typeof userId);
    
    // Check if the ID looks like a UUID
    const isUUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(userId);
    console.log('Is user ID a valid UUID?', isUUID);

    // Test creating a wallet with UUID
    const testWalletResult = await supabase
      .from('wallets')
      .insert({
        name: 'Test Wallet',
        owner_id: userId // Should be UUID string
      })
      .select('id')
      .single();

    console.log('Wallet creation test:', testWalletResult);

    if (testWalletResult.error) {
      res.status(500).send({
        success: false,
        step: 'wallet_creation',
        error: testWalletResult.error,
        message: 'Failed to create test wallet',
        userId: userId,
        userIdType: typeof userId
      });
      return;
    }

    const walletId = testWalletResult.data.id;
    console.log('Test wallet created with ID:', walletId, 'type:', typeof walletId);

    // Test adding member
    const testMemberResult = await supabase
      .from('wallet_members')
      .insert({
        wallet_id: walletId,
        user_id: userId // Should be UUID string
      });

    console.log('Member addition test:', testMemberResult);

    // Clean up test data
    await supabase.from('wallet_members').delete().eq('wallet_id', walletId);
    await supabase.from('wallets').delete().eq('id', walletId);
    await supabase.from('users').delete().eq('id', userId);

    if (testMemberResult.error) {
      res.status(500).send({
        success: false,
        step: 'member_creation',
        error: testMemberResult.error,
        message: 'Failed to create test member',
        userId: userId,
        userIdType: typeof userId,
        walletId: walletId,
        walletIdType: typeof walletId
      });
      return;
    }

    res.send({
      success: true,
      message: 'All database operations successful with UUIDs',
      results: {
        userId: { 
          value: userId, 
          type: typeof userId,
          isUUID: /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(userId)
        },
        walletId: { 
          value: walletId, 
          type: typeof walletId,
          isUUID: /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(walletId)
        }
      },
      note: 'If isUUID is false for either ID, you need to run the schema migration to use UUIDs'
    });

  } catch (error) {
    console.error("Schema debug failed:", error);
    res.status(500).send({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});
