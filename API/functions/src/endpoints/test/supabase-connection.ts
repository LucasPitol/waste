import * as functions from "firebase-functions";
import { supabase, getSupabaseConfigForDebugging } from "../../db/supabase";

export const testSupabaseConnection = functions.https.onRequest(async (req, res) => {
  try {
    console.log("Testing Supabase connection...");
    
    const configResult = getSupabaseConfigForDebugging();
    
    if ('error' in configResult) {
      res.status(500).send({
        success: false,
        error: "Configuration error",
        details: configResult.error
      });
      return;
    }

    console.log("Config:", { 
      url: configResult.url, 
      keyPrefix: configResult.key?.substring(0, 20) + "..." 
    });

    // Test basic connection
    const { data, error } = await supabase
      .from('users')
      .select('count(*)', { count: 'exact', head: true });

    if (error) {
      console.error("Supabase connection error:", error);
      res.status(500).send({
        success: false,
        error: error.message,
        details: error.details,
        hint: error.hint,
        config: {
          url: configResult.url,
          hasKey: !!configResult.key
        }
      });
      return;
    }

    console.log("Supabase connection successful!");
    res.send({
      success: true,
      message: "Supabase connection successful",
      userCount: data,
      config: {
        url: configResult.url,
        hasKey: !!configResult.key,
        keyLength: configResult.key?.length
      }
    });

  } catch (error) {
    console.error("Connection test failed:", error);
    res.status(500).send({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});
