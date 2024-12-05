import { VerificationCodeService } from "../../services/verification-code-service";
import { ResponseDto } from "../../models/dtos/response-dto";
import { UserService } from "../../services/user-service";
import { Utils } from "../../utils/utils";

export class SendVerificationCodeUseCase {

  userService: UserService
  verificationCodeService: VerificationCodeService

  constructor() {
    this.userService = new UserService()
    this.verificationCodeService = new VerificationCodeService()
  }

  async execute(userMail: string, verificationType: string): Promise<ResponseDto> {
    let ret = new ResponseDto()

    if (userMail == null || userMail == '') {
      ret.success = false
      ret.errorMsg = 'Email Inválido'

      return ret
    }

    const user = await this.userService.getUserByEmail(userMail)

    if (user != null) {
      ret.success = false
      ret.errorMsg = 'Email já cadastrado.'

      return ret
    }

    const code = Utils.generateRandomNumberString();

    var verificationCode = await this.verificationCodeService.getByUserMail(userMail)

    const now = new Date()
    const expirationDate = this.verificationCodeService.calculateExpirationDate(now)


    if (verificationCode == null) {
      this.verificationCodeService.save(userMail, code, expirationDate)
    } else if (this.verificationCodeService.canRegenerateCode(verificationCode, now)) {
      verificationCode.code = code
      verificationCode.verified = false
      verificationCode.expirationDate = expirationDate

      this.verificationCodeService.update(verificationCode)
    }

    // const verificationTypeEnum =
    //   verificationType != null &&
    //     verificationType != '' &&
    //     verificationType == VerificationCodeType.changePassword ?
    //     VerificationCodeType.changePassword :
    //     VerificationCodeType.newUser

    //await this.mailSenderService.sendVerificationCode(userMail, code, verificationTypeEnum);

    ret.success = true
    ret.data = true

    return ret
  }
}