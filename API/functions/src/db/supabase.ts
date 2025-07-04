import { createClient } from "@supabase/supabase-js";
import * as functions from "firebase-functions";
import { SupabaseClient } from "@supabase/supabase-js";

// Load environment variables for local development
if (process.env.NODE_ENV !== 'production') {
  try {
    require('dotenv').config();
  } catch (error) {
    // dotenv might not be available in all environments, that's okay
  }
}

// Lazy-loaded configuration
let _supabaseClient: SupabaseClient | null = null;
let _config: { url: string; key: string } | null = null;

// Get configuration from Firebase Functions config or environment variables
const getSupabaseConfig = () => {
  if (_config) {
    return _config;
  }

  // Try Firebase Functions config first (for deployed functions)
  try {
    const functionsConfig = functions.config();
    
    if (functionsConfig?.supabase?.url && (functionsConfig?.supabase?.service_key || functionsConfig?.supabase?.key)) {
      _config = {
        url: functionsConfig.supabase.url,
        key: functionsConfig.supabase.service_key || functionsConfig.supabase.key
      };
      return _config;
    }
  } catch (error) {
    // Firebase config might not be available in emulator
    console.log('Firebase config not available, falling back to environment variables');
  }
  
  // Fallback to environment variables (for local development)
  const {
    SUPABASE_URL,
    SUPABASE_SERVICE_KEY,
    SUPABASE_ANON_KEY,
    DATABASE_URL,
    SUPABASE_KEY,
  } = process.env;

  const url = SUPABASE_URL || DATABASE_URL;
  const key = SUPABASE_SERVICE_KEY || SUPABASE_KEY || SUPABASE_ANON_KEY;

  if (!url || !key) {
    throw new Error(`Supabase configuration is missing. Please set SUPABASE_URL and SUPABASE_SERVICE_KEY environment variables or Firebase Functions config.
    
Current environment variables:
    - SUPABASE_URL: ${url ? 'SET' : 'MISSING'}
    - SUPABASE_SERVICE_KEY: ${SUPABASE_SERVICE_KEY ? 'SET' : 'MISSING'}
    - DATABASE_URL: ${DATABASE_URL ? 'SET' : 'MISSING'}
    - SUPABASE_KEY: ${SUPABASE_KEY ? 'SET' : 'MISSING'}
    
For local development, create a .env file in the functions directory with:
    SUPABASE_URL=https://your-project-id.supabase.co
    SUPABASE_SERVICE_KEY=your-service-role-key
    `);
  }

  _config = { url, key };
  return _config;
};

// Lazy-loaded Supabase client
const getSupabaseClient = () => {
  if (_supabaseClient) {
    return _supabaseClient;
  }

  const config = getSupabaseConfig();
  
  // Create Supabase client with service role key for server-side operations
  _supabaseClient = createClient(config.url, config.key, {
    auth: {
      autoRefreshToken: false,
      persistSession: false
    }
  });

  return _supabaseClient;
};

// Export lazy-loaded client
export const supabase = new Proxy({} as SupabaseClient, {
  get(target, prop) {
    const client = getSupabaseClient();
    const value = (client as any)[prop];
    return typeof value === 'function' ? value.bind(client) : value;
  }
});

// Export config getter for debugging
export const getSupabaseConfigForDebugging = () => {
  try {
    return getSupabaseConfig();
  } catch (error) {
    return { error: error instanceof Error ? error.message : 'Unknown error' };
  }
};

