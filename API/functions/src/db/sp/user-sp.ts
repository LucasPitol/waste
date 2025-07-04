import { supabase } from "../supabase";
import { User } from "../../models/user";
import { EncryptionService } from "../../services/encryption-service";

export class UserSP {
  tableName = "users";
  private encryptionService = new EncryptionService();

  async createUser(name: string, email: string, password: string) {
    // Hash the password before storing
    const hashedPassword = await this.encryptionService.hashString(password);
    
    const { data, error } = await supabase
      .from(this.tableName)
      .insert({
        display_name: name,
        email: email,
        password: hashedPassword, // Store hashed password
      })
      .select()
      .single();

    if (error) {
      throw new Error(`Error creating user: ${error.message}`);
    }

    return data.id; // Return the auto-generated ID
  }

  // Login method - verify email and password
  async loginUser(email: string, password: string): Promise<User | null> {
    // First, get the user by email
    const user = await this.getUserByEmail(email);
    
    if (!user || !user.password) {
      return null; // User not found or no password stored
    }

    // Verify the password
    const isPasswordValid = await this.encryptionService.verifyPassword(password, user.password);
    
    if (!isPasswordValid) {
      return null; // Invalid password
    }

    return user; // Return user if login successful
  }

  // Change password for a user
  async changePassword(uid: string, newPassword: string) {
    // Hash the new password before storing
    const hashedPassword = await this.encryptionService.hashString(newPassword);
    
    const { error } = await supabase
      .from(this.tableName)
      .update({ 
        password: hashedPassword, // Store hashed password
        last_update: new Date().toISOString()
      })
      .eq("id", parseInt(uid)); // Convert string ID to number

    if (error) {
      throw new Error(`Error changing password: ${error.message}`);
    }

    return uid;
  }

  // Method for DAO layer that accepts pre-hashed password
  async createUserWithHashedPassword(name: string, email: string, hashedPassword: string) {
    const { data, error } = await supabase
      .from(this.tableName)
      .insert({
        display_name: name,
        email: email,
        password: hashedPassword, // Already hashed password
      })
      .select()
      .single();

    if (error) {
      throw new Error(`Error creating user: ${error.message}`);
    }

    return data.id; // Return the auto-generated UUID as string
  }

  // Method for DAO layer that accepts pre-hashed password
  async changePasswordWithHashedPassword(uid: string, hashedPassword: string) {
    const { error } = await supabase
      .from(this.tableName)
      .update({ 
        password: hashedPassword, // Already hashed password
        last_update: new Date().toISOString()
      })
      .eq("id", uid); // Use uid as string (UUID)

    if (error) {
      throw new Error(`Error changing password: ${error.message}`);
    }

    return uid;
  }

  async getUsersByIds(ids: string[]): Promise<User[]> {
    const { data, error } = await supabase
      .from(this.tableName)
      .select("*")
      .in("id", ids); // Use UUID strings

    if (error) {
      throw new Error(`Error fetching users: ${error.message}`);
    }

    return data.map(row => new User(row));
  }

  async getUserById(id: string): Promise<User | null> {
    const { data, error } = await supabase
      .from(this.tableName)
      .select("*")
      .eq("id", id)
      .single();

    if (error) {
      if (error.code === 'PGRST116') return null; // Not found
      throw new Error(`Error fetching user: ${error.message}`);
    }

    return new User(data);
  }

  async getUserByEmail(email: string): Promise<User | null> {
    const { data, error } = await supabase
      .from(this.tableName)
      .select("*")
      .eq("email", email)
      .single();

    if (error) {
      if (error.code === 'PGRST116') return null; // Not found
      throw new Error(`Error fetching user by email: ${error.message}`);
    }

    return new User(data);
  }
}
