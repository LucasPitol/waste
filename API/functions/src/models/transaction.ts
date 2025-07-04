import { AbstractModel } from "./abstract-model";

interface SupabaseTransactionRow {
    id: string;
    wallet_id: string;
    user_id: string;
    amount: number;
    type: string;
    reason?: string;
    spending_category_id?: string;
    creation_date?: string;
    last_update?: string;
    transaction_date?: string;
}

export class Transaction extends AbstractModel {
    amount: number
    categoryId: string
    reason: string
    transactionDate: Date
    type: string
    userId: string
    walletId: string

    constructor(row: SupabaseTransactionRow) {
        super({
            creationDate: row.creation_date ? new Date(row.creation_date) : new Date(),
            lastUpdate: row.last_update ? new Date(row.last_update) : new Date()
        });

        this.id = row.id;
        this.amount = row.amount;
        this.categoryId = row.spending_category_id || '';
        this.reason = row.reason || '';
        this.type = row.type;
        this.userId = row.user_id;
        this.walletId = row.wallet_id;
        this.transactionDate = row.transaction_date ? new Date(row.transaction_date) : new Date();
    }
}