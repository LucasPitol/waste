import { supabase } from "../supabase";
import * as dotenv from "dotenv";
dotenv.config();

const {
  SUPABASE_USER_MAIL,
  SUPABASE_USER_PW,
} = process.env;

export class AuthSp {
  async authSP() {
    const { data, error } = await supabase.auth.signInWithPassword({
      email: SUPABASE_USER_MAIL!,
      password: SUPABASE_USER_PW!,
    });

    if (error) {
      console.error("Login failed:", error.message);
    } else {
      console.log("User logged in:", data.user);
    }
  }
}
