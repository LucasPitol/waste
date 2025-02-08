import { DocumentSnapshot } from "firebase-functions/v2/firestore"
import { AbstractModel } from "./abstract-model"

export class User extends AbstractModel {
    static collectionName = 'user'

    name?: string
    email?: string
    password?: string

    constructor(doc: DocumentSnapshot) {
        var docMap = doc.data()

        super(docMap)

        this.id = doc.id
        this.email = docMap?.email
        this.name = docMap?.displayName
        this.password = docMap?.password

        return this
    }
}
