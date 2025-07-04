export class NewTransactionDto {
    reason?: string
    amount?: number
    transactionDate?: Date
    userId?: string
    walletId?: string
    type?: string  // "waste" or "revenue"
    categoryId?: string  // only for waste/expense transactions
}
