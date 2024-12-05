import { db } from "../index";
import { VerificationCode } from "../models/verification-code";

export class VerificationCodeDao {
  verificationCodeCollectionName = VerificationCode.collectionName

  async getByUserMail(userMail: string): Promise<VerificationCode | null> {
    var verificationCode = null

    const verificationCodeRef = db.collection(this.verificationCodeCollectionName)

    const snapShot = await verificationCodeRef.where('userMail', '==', userMail).get()

    if (!snapShot.empty) {
      snapShot.forEach(doc => {
        const verificationCode = new VerificationCode(doc)

        return verificationCode
      })
    }

    return verificationCode

  }

  async update(verificationCode: VerificationCode): Promise<string> {
    const verificationCodeId = verificationCode.id
    const batch = db.batch()
    const docRef = db.collection(this.verificationCodeCollectionName).doc(verificationCodeId)

    batch.set(docRef, {
      id: docRef.id,
      userMail: verificationCode.userMail,
      code: verificationCode.code,
      verified: verificationCode.verified,
      expirationDate: verificationCode.expirationDate,
      lastUpdateDate: new Date(),
    }, { merge: true })

    await batch.commit();

    return docRef.id
  }

  async save(userMail: string, code: string, expirationDate: Date): Promise<string> {
    const batch = db.batch()

    const docRef = db.collection(this.verificationCodeCollectionName).doc()

    batch.set(docRef, {
      id: docRef.id,
      userMail: userMail,
      code: code,
      verified: false,
      expirationDate: expirationDate,
      creationDate: new Date(),
    })

    await batch.commit();

    return docRef.id
  }
}