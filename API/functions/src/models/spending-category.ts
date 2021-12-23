import { DocumentSnapshot } from "firebase-functions/v1/firestore"
import { AbstractModel } from "./abstract-model"

export class SpendingCategory extends AbstractModel {
    static collectionName = 'spendingCategories'

    name: string
    value: string

    constructor(doc: DocumentSnapshot) {
        var docMap = doc.data()

        super(docMap)

        this.id = doc.id
        this.name = docMap?.displayNamePt
        this.value = docMap?.value
    }
}