import { AbstractModel } from "./abstract-model"

interface SupabaseUserRow {
    id: string; // UUID from table
    display_name?: string;
    email?: string;
    password?: string;
    created_at?: string;
    last_update?: string;
}

export class User extends AbstractModel {
    static collectionName = 'users'

    displayName?: string
    email?: string
    password?: string

    constructor(row: SupabaseUserRow) {
        super({
            creationDate: row.created_at ? new Date(row.created_at) : new Date(),
            lastUpdate: row.last_update ? new Date(row.last_update) : new Date()
        });

        this.id = row.id; // Already a string (UUID)
        this.displayName = row.display_name;
        this.email = row.email;
        this.password = row.password; // Note: storing passwords like this is not recommended
    }
}
