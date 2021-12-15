import { DocumentSnapshot } from "firebase-functions/lib/providers/firestore"
import { AbstractModel } from "./abstract-model"

export class User extends AbstractModel {
    static collectionName = 'user'

    name?: string
    email?: string

    constructor(doc: DocumentSnapshot) {
        var docMap = doc.data()

        super(docMap)

        this.id = doc.id
        this.email = docMap?.email
        this.name = docMap?.displayName

        return this
    }
}
