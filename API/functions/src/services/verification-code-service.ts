import { VerificationCodeDao } from "../db/verification-code-dao"
import { VerificationCode } from "../models/verification-code"

export class VerificationCodeService {
  verificationCodeDao: VerificationCodeDao

  constructor() {
    this.verificationCodeDao = new VerificationCodeDao()
  }

  canRegenerateCode(verificationCode: VerificationCode, now?: Date): boolean {
    if (now == null) {
      now = new Date()
    }

    const lastTimeCodeGenerated = verificationCode.lastUpdate ?? verificationCode.creationDate

    var numberOfMlSeconds = lastTimeCodeGenerated.getTime()
    var addMlSeconds = 60 * 1000
    const canRegenerateAfterDate = new Date(numberOfMlSeconds + addMlSeconds)

    return now > canRegenerateAfterDate
  }

  async update(verificationCode: VerificationCode): Promise<string> {
    return await this.verificationCodeDao.update(verificationCode)
  }

  async save(userMail: string, code: string, expirationDate: Date): Promise<string> {
    return await this.verificationCodeDao.save(userMail, code, expirationDate)
  }

  async getByUserMail(userMail: string): Promise<VerificationCode | null> {
    return await this.verificationCodeDao.getByUserMail(userMail)
  }

  calculateExpirationDate(codeGeneratedDate: Date): Date {
    var numberOfMlSeconds = codeGeneratedDate.getTime()
    var addMlSeconds = 60 * 30 * 1000
    return new Date(numberOfMlSeconds + addMlSeconds)
  }
}