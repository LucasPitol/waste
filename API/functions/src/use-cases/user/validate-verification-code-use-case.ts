import { ResponseDto } from "../../models/dtos/response-dto"
import { UserService } from "../../services/user-service"
import { VerificationCodeService } from "../../services/verification-code-service"

export class ValidateVerificationCodeUseCase {
  userService: UserService
  verificationCodeService: VerificationCodeService

  constructor() {
    this.userService = new UserService()
    this.verificationCodeService = new VerificationCodeService()
  }

  async execute(userMail: string, code: string): Promise<ResponseDto> {
    let ret = new ResponseDto()
    console.log(userMail)
    if (userMail == null || userMail == '') {
      ret.success = false
      ret.errorMsg = 'Email Inválido'

      return ret
    }

    if (code == null || code == '') {
      ret.success = false
      ret.errorMsg = 'Código Inválido'

      return ret
    }

    var verificationCode = await this.verificationCodeService.getByUserMail(userMail)

    const now = new Date()

    if (now > verificationCode?.expirationDate!) {
      ret.success = false
      ret.errorMsg = 'Código expirado'
      return ret
    }
    console.log(verificationCode)

    if (verificationCode?.code == code.trim()) {
      verificationCode.verified = true
      this.verificationCodeService.update(verificationCode)
    } else {
      ret.success = false
      ret.errorMsg = 'Código inválido'
      return ret
    }

    ret.success = true
    return ret
  }
}