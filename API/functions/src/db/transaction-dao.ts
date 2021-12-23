import { Transaction } from "../models/transaction";
import { db } from "../index";

export class TransactionDao {
    transactionCollectionName = Transaction.collectionName

    async getTransactionsByWalletIdAndDateIntervalRes(walletId: string, startDate: Date, endDate: Date): Promise<Transaction[]> {
        var transactionList: Transaction[] = []

        var snapshot = await db
            .collection(this.transactionCollectionName)
            .where('walletId', '==', walletId)
            .where('transactionDate', '>=', startDate)
            .where('transactionDate', '<=', endDate)
            .get()

        if (snapshot.empty) {
            return transactionList
        } else {
            var transaction

            for (const doc of snapshot.docs) {
                transaction = new Transaction(doc)

                transactionList.push(transaction)
            }
        }

        return transactionList
    }
}