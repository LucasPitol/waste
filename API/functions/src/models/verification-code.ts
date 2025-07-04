import { DocumentSnapshot } from "firebase-functions/v2/firestore"
import { AbstractModel } from "./abstract-model"

export class VerificationCode extends AbstractModel {
  static collectionName = 'verificationCode'

  userMail: string
  code: string
  verified: boolean
  expirationDate: Date

  constructor(docOrData: DocumentSnapshot | any) {
    // Handle both Firestore DocumentSnapshot and Supabase data
    if (docOrData.data && typeof docOrData.data === 'function') {
      // Firestore DocumentSnapshot
      const docMap = docOrData.data();
      super(docMap);
      this.id = docOrData.id;
      this.userMail = docMap?.userMail;
      this.code = docMap?.code;
      this.verified = docMap?.verified;
      this.expirationDate = (docMap?.expirationDate).toDate();
    } else {
      // Direct data object (from Supabase SP conversion)
      const docMap = docOrData.data ? docOrData.data() : docOrData;
      super(docMap);
      this.id = docOrData.id;
      this.userMail = docMap?.userMail;
      this.code = docMap?.code;
      this.verified = docMap?.verified;
      this.expirationDate = docMap?.expirationDate?.toDate ? docMap.expirationDate.toDate() : new Date(docMap?.expirationDate);
    }
  }
}