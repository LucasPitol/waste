import { DocumentSnapshot } from "firebase-functions/v2/firestore"
import { AbstractModel } from "./abstract-model"

export class VerificationCode  extends AbstractModel{
  static collectionName = 'verificationCode'

  userMail: string
  code: string
  verified: boolean
  expirationDate: Date

  constructor(doc: DocumentSnapshot) {
    var docMap = doc.data()

    super(docMap)

    this.id = doc.id
    this.userMail = docMap?.userMail
    this.code = docMap?.code
    this.verified = docMap?.verified
    this.expirationDate = (docMap?.expirationDate).toDate()
  }
}