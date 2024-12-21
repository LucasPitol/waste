import { ResponseDto } from "../../models/dtos/response-dto";
import { UserService } from "../../services/user-service";
import { VerificationCodeService } from "../../services/verification-code-service";

export class UpdatePasswordUseCase {
  userService: UserService
  verificationCodeService: VerificationCodeService

  constructor() {
    this.userService = new UserService();
    this.verificationCodeService = new VerificationCodeService()
  }

  async execute(userMail: string, newPassword: string): Promise<ResponseDto> {
    let ret = new ResponseDto()

    if (userMail == null || userMail == "") {
      ret.success = false;
      ret.errorMsg = "Email Inválido";

      return ret;
    }

    const verificationCode = await this.verificationCodeService.getByUserMail(userMail)
    if (verificationCode?.verified == false) {
      ret.success = false;
      ret.errorMsg = 'Código de verificação não validado'

      return ret
    }

    const user = await this.userService.getUserByEmail(userMail);

    if (user == null) {
      ret.success = false;
      ret.errorMsg = 'Não foi possível localizar o usuário com este email'

      return ret
    }

    const uidN = await this.userService.updateUserPassword(user.id, newPassword)

    if (uidN == null) {
      ret.success = false
      ret.errorMsg =
        'Não foi possível alterar a senha, tente novamente mais tarde'
    } else {
      ret.success = true
      ret.data = true
    }

    return ret
  }
}