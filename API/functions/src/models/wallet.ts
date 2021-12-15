import { DocumentSnapshot } from "firebase-functions/v1/firestore";
import { AbstractModel } from "./abstract-model";

export class Wallet extends AbstractModel {
    static collectionName = 'wallets'

    membersId: string[]
    name: string
    ownerId: string

    constructor(doc: DocumentSnapshot) {
        var docMap = doc.data()

        super(docMap)
  
        let membersIdDynamic = docMap?.membersId as string[]


        this.id = doc.id
        this.name = docMap?.name
        this.ownerId = docMap?.ownerId
        this.membersId = membersIdDynamic
    }
}
