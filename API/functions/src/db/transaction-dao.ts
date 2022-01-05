import { Transaction } from "../models/transaction";
import { db } from "../index";
import { NewWasteDto } from "../models/dtos/new-waste-dto";
import { NewRevenueDto } from "../models/dtos/new-revenue-dto";

export class TransactionDao {
    transactionCollectionName = Transaction.collectionName

    async saveNewWaste(newWasteDto: NewWasteDto) {

        const batch = db.batch()

        const transactionDocRef = db.collection(this.transactionCollectionName).doc()

        var id = transactionDocRef.id

        let now = new Date()

        batch.set(transactionDocRef, {
            'id': id,
            'userId': newWasteDto.uid,
            'reason': newWasteDto.reason,
            'transactionDate': newWasteDto.spendDate,
            'walletId': newWasteDto.walletId,
            'amount': newWasteDto.waste,
            'categoryId': newWasteDto.categoryId,
            'type': 'WASTE',
            'creationDate': now,
        })

        await batch.commit()

        return id
    }

    async saveNewRevenue(newRevenueDto: NewRevenueDto) {

        const batch = db.batch()

        const transactionDocRef = db.collection(this.transactionCollectionName).doc()

        var id = transactionDocRef.id

        let now = new Date()

        batch.set(transactionDocRef, {
            'id': id,
            'userId': newRevenueDto.uid,
            'reason': newRevenueDto.reason,
            'transactionDate': newRevenueDto.payDay,
            'walletId': newRevenueDto.walletId,
            'amount': newRevenueDto.amount,
            'type': 'REVENUE',
            'creationDate': now,
        })

        await batch.commit()

        return id
    }

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