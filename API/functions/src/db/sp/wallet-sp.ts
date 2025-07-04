import { Wallet } from "../../models/wallet";
import { supabase } from "../supabase";

interface SupabaseWalletRow {
    id: string;
    name: string;
    owner_id: string;
    creation_date?: string;
    last_update?: string;
}

export class WalletSP {
    tableName = "wallets";
    membersTableName = "wallet_members";

    async getWalletsByUserId(userId: string): Promise<Wallet[]> {
        // Get wallets where user is either owner or member
        const { data: memberData, error: memberError } = await supabase
            .from(this.membersTableName)
            .select(`
                wallet_id,
                wallets!inner (
                    id,
                    name,
                    owner_id,
                    creation_date,
                    last_update
                )
            `)
            .eq('user_id', userId); // Use userId as UUID string

        if (memberError) {
            throw new Error(`Error fetching wallets by user ID: ${memberError.message}`);
        }

        // Also get wallets where user is the owner (might not be in members table)
        const { data: ownedWallets, error: ownedError } = await supabase
            .from(this.tableName)
            .select('*')
            .eq('owner_id', userId); // Use userId as UUID string

        if (ownedError) {
            throw new Error(`Error fetching owned wallets: ${ownedError.message}`);
        }

        // Combine and deduplicate wallets
        const allWallets = new Map<string, SupabaseWalletRow>();
        
        // Add member wallets
        if (memberData) {
            memberData.forEach(member => {
                const wallet = (member as any).wallets;
                if (wallet) {
                    allWallets.set(wallet.id, wallet);
                }
            });
        }

        // Add owned wallets
        if (ownedWallets) {
            ownedWallets.forEach(wallet => {
                allWallets.set(wallet.id, wallet);
            });
        }

        // Get members for each wallet and convert to Wallet objects
        const wallets: Wallet[] = [];
        for (const walletData of allWallets.values()) {
            const members = await this.getWalletMembers(walletData.id);
            const wallet = await this.convertToWalletModel(walletData, members);
            wallets.push(wallet);
        }

        return wallets;
    }

    async getById(walletId: string): Promise<Wallet | null> {
        const { data, error } = await supabase
            .from(this.tableName)
            .select('*')
            .eq('id', walletId)
            .single();

        if (error) {
            if (error.code === 'PGRST116') return null; // Not found
            throw new Error(`Error fetching wallet: ${error.message}`);
        }

        const members = await this.getWalletMembers(walletId);
        return await this.convertToWalletModel(data, members);
    }

    async getWalletByNameAndOwnerId(walletName: string, userId: string): Promise<Wallet | null> {
        const { data, error } = await supabase
            .from(this.tableName)
            .select('*')
            .eq('owner_id', userId) // Use userId as UUID string
            .eq('name', walletName)
            .single();

        if (error) {
            if (error.code === 'PGRST116') return null; // Not found
            throw new Error(`Error fetching wallet by name and owner: ${error.message}`);
        }

        const members = await this.getWalletMembers(data.id);
        return await this.convertToWalletModel(data, members);
    }

    async updateMemberIdList(members: string[], wallet: Wallet) {
        // First, remove all existing members
        const { error: deleteError } = await supabase
            .from(this.membersTableName)
            .delete()
            .eq('wallet_id', wallet.id);

        if (deleteError) {
            throw new Error(`Error removing existing members: ${deleteError.message}`);
        }

        // Add new members
        if (members.length > 0) {
            const memberInserts = members.map(userId => ({
                wallet_id: wallet.id,
                user_id: userId, // Use as UUID string
                role: 'viewer'
            }));

            const { error: insertError } = await supabase
                .from(this.membersTableName)
                .insert(memberInserts);

            if (insertError) {
                throw new Error(`Error adding new members: ${insertError.message}`);
            }
        }

        // Update wallet last_update
        const { error: updateError } = await supabase
            .from(this.tableName)
            .update({ last_update: new Date().toISOString() })
            .eq('id', wallet.id);

        if (updateError) {
            throw new Error(`Error updating wallet: ${updateError.message}`);
        }

        return wallet.id;
    }

    async createNewWallet(userId: string, walletName: string): Promise<string> {
        try {
            // Create the wallet (let Supabase auto-generate the UUID)
            const { data: walletData, error: walletError } = await supabase
                .from(this.tableName)
                .insert({
                    name: walletName,
                    owner_id: userId, // Use userId as UUID string
                })
                .select('id')
                .single();

            if (walletError) {
                console.error('Wallet creation error:', walletError);
                throw new Error(`Error creating wallet: ${walletError.message}`);
            }

            const walletId = walletData.id;

            // Add the owner as a member (use UUID strings)
            const memberInsertData = {
                wallet_id: walletId, // UUID string from wallets table
                user_id: userId, // UUID string for user_id
                role: 'admin'
            };
            
            const { error: memberError } = await supabase
                .from(this.membersTableName)
                .insert(memberInsertData);

            if (memberError) {
                console.error('Member addition error:', memberError);
                // If member addition fails, clean up the wallet
                await supabase.from(this.tableName).delete().eq('id', walletId);
                throw new Error(`Error adding owner as member: ${memberError.message}`);
            }

            console.log('Owner added as member successfully');
            
            // Return as string (already a UUID string)
            return walletId;
            
        } catch (error) {
            console.error('Full wallet creation error:', error);
            throw error;
        }
    }

    async addMemberToWallet(memberId: string, walletId: string): Promise<void> {
        // Check if member already exists
        const { data: existingMember, error: checkError } = await supabase
            .from(this.membersTableName)
            .select('id')
            .eq('wallet_id', walletId) // Use walletId as UUID string
            .eq('user_id', memberId) // Use memberId as UUID string
            .single();

        if (checkError && checkError.code !== 'PGRST116') {
            throw new Error(`Error checking existing member: ${checkError.message}`);
        }

        // If member doesn't exist, add them
        if (!existingMember) {
            const { error: insertError } = await supabase
                .from(this.membersTableName)
                .insert({
                    wallet_id: walletId, // Use as UUID string
                    user_id: memberId, // Use as UUID string
                    role: 'viewer'
                });

            if (insertError) {
                throw new Error(`Error adding member to wallet: ${insertError.message}`);
            }
        }

        // Update wallet last_update
        const { error: updateError } = await supabase
            .from(this.tableName)
            .update({ last_update: new Date().toISOString() })
            .eq('id', walletId);

        if (updateError) {
            throw new Error(`Error updating wallet: ${updateError.message}`);
        }
    }

    async removeMemberFromWallet(memberId: string, walletId: string): Promise<void> {
        const { error: deleteError } = await supabase
            .from(this.membersTableName)
            .delete()
            .eq('wallet_id', walletId) // Use as UUID string
            .eq('user_id', memberId); // Use as UUID string

        if (deleteError) {
            throw new Error(`Error removing member from wallet: ${deleteError.message}`);
        }

        // Update wallet last_update
        const { error: updateError } = await supabase
            .from(this.tableName)
            .update({ last_update: new Date().toISOString() })
            .eq('id', walletId);

        if (updateError) {
            throw new Error(`Error updating wallet: ${updateError.message}`);
        }
    }

    // Helper method to get wallet members
    private async getWalletMembers(walletId: string): Promise<string[]> {
        const { data, error } = await supabase
            .from(this.membersTableName)
            .select('user_id')
            .eq('wallet_id', walletId);

        if (error) {
            throw new Error(`Error fetching wallet members: ${error.message}`);
        }

        return data ? data.map(member => member.user_id.toString()) : [];
    }

    // Helper method to convert Supabase data to Wallet model
    private async convertToWalletModel(walletData: SupabaseWalletRow, members: string[]): Promise<Wallet> {
        // Create a mock DocumentSnapshot-like object for the existing Wallet constructor
        const mockDoc = {
            id: walletData.id,
            data: () => ({
                name: walletData.name,
                ownerId: walletData.owner_id.toString(),
                membersIds: members,
                creationDate: walletData.creation_date ? new Date(walletData.creation_date) : new Date(),
                lastUpdate: walletData.last_update ? new Date(walletData.last_update) : new Date()
            })
        };

        return new Wallet(mockDoc as any);
    }
}
