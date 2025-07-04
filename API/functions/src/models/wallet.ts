import { AbstractModel } from "./abstract-model";

export class Wallet extends AbstractModel {
    static collectionName = 'wallets'

    membersIds: string[]  // Array of member user IDs (populated from wallet_members table)
    name: string
    ownerId: string       // The owner user ID

    constructor(data: any) {
        // Handle both Firestore DocumentSnapshot and Supabase data
        if (data.data && typeof data.data === 'function') {
            // Firestore DocumentSnapshot
            const docMap = data.data();
            super(docMap);
            this.id = data.id;
            this.name = docMap?.name;
            this.ownerId = docMap?.ownerId;
            this.membersIds = docMap?.membersIds as string[] || [];
        } else {
            // Direct Supabase data object
            super({
                creationDate: data.creation_date ? new Date(data.creation_date) : new Date(),
                lastUpdate: data.last_update ? new Date(data.last_update) : new Date()
            });
            this.id = data.id;
            this.name = data.name;
            this.ownerId = data.owner_id?.toString() || data.ownerId; // Handle both formats
            this.membersIds = data.membersIds || [];
        }
    }
}
