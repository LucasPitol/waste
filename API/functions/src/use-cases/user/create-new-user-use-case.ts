import { UserDao } from "../../db/user-dao";
import { Wallet } from "../../models/wallet";
import { Constants } from "../../utils/constants";
import { NewUserDto } from "../../models/dtos/new-user-dto";
import { ResponseDto } from "../../models/dtos/response-dto";
import { WalletService } from "../../services/wallet-service";
import { UserService } from "../../services/user-service";

export class CreateNewUserUseCase {
  userDao: UserDao
  walletService: WalletService
  userService: UserService

  constructor() {
    this.userDao = new UserDao()
    this.walletService = new WalletService()
    this.userService = new UserService();
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

    let name = newUserDto.name!
    let password = newUserDto.password!

    let uid = await this.userDao.createNewUser(name, userMail, password)

    // create standard wallet
    let standardWalletName = Constants.standardWalletName

    await this.walletService.createNewWallet(uid, standardWalletName)

    // auth
    user = await this.userDao.getUserById(uid)
    let walletList: Wallet[] = await this.walletService.getWalletsByUserId(uid)

    if (user != null) {
      let userDto = this.userService.handleUserDto(user, walletList)

      ret.success = true
      ret.data = userDto
    }

    return ret
  }

}