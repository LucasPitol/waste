import { DocumentSnapshot } from "firebase-functions/v2/firestore"
import { AbstractModel } from "./abstract-model";

export class Wallet extends AbstractModel {
  static collectionName = 'wallets'

  membersIds: string[]
  name: string
  ownerId: string

  constructor(doc: DocumentSnapshot) {
    var docMap = doc.data()

    super(docMap)

    let membersIdDynamic = docMap?.membersIds as string[]

    this.id = doc.id
    this.name = docMap?.name
    this.ownerId = docMap?.ownerId
    this.membersIds = membersIdDynamic
  }
}
