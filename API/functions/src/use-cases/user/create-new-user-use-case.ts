import { VerificationCodeService } from "../../services/verification-code-service";
import { WalletService } from "../../services/wallet-service";
import { ResponseDto } from "../../models/dtos/response-dto";
import { NewUserDto } from "../../models/dtos/new-user-dto";
import { Constants } from "../../utils/constants";
import { UserDao } from "../../db/user-dao";

export class CreateNewUserUseCase {
  userDao: UserDao
  walletService: WalletService
  verificationCodeService: VerificationCodeService

  constructor() {
    this.userDao = new UserDao()
    this.walletService = new WalletService()
    this.verificationCodeService = new VerificationCodeService()
  }

  async execute(newUserDto: NewUserDto): Promise<ResponseDto> {
    let ret = new ResponseDto()

    let userMail: string | undefined = newUserDto.email
    if (userMail == null || userMail == '') {
      ret.success = false
      ret.errorMsg = 'Email Inválido'

      return ret
    }

    let user = await this.userDao.getUserByEmail(userMail)

    if (user != null) {
      ret.success = false;
      ret.errorMsg = 'Email já cadastrado'

      return ret
    }

    const verificationCode = await this.verificationCodeService.getByUserMail(userMail)
    if (verificationCode?.verified == false) {
      ret.success = false;
      ret.errorMsg = 'Email não validado'

      return ret
    }

    let name = newUserDto.name!
    let password = newUserDto.password!

    let uid = await this.userDao.createNewUser(name, userMail, password)

    // create standard wallet
    let standardWalletName = Constants.standardWalletName

    await this.walletService.createNewWallet(uid, standardWalletName)

    ret.success = true
    ret.data = true

    return ret
  }
}
