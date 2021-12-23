import { DocumentSnapshot } from "firebase-functions/v1/firestore";
import { AbstractModel } from "./abstract-model";

export class Transaction extends AbstractModel {
    static collectionName = 'transactions'

    amount: number
    categoryId: string
    reason: string
    transactionDate: Date
    type: string
    userId: string
    walletId: string

    constructor(doc: DocumentSnapshot) {
        var docMap = doc.data()

        super(docMap)

        this.id = doc.id
        this.amount = docMap?.amount
        this.categoryId = docMap?.categoryId
        this.reason = docMap?.reason
        this.type = docMap?.type
        this.userId = docMap?.userId
        this.walletId = docMap?.walletId
        this.transactionDate = (docMap?.transactionDate).toDate()
    }
}