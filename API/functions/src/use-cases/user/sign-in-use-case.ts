import { UserDao } from "../../db/user-dao";
import { ResponseDto } from "../../models/dtos/response-dto";
import { Wallet } from "../../models/wallet";
import { UserService } from "../../services/user-service";
import { WalletService } from "../../services/wallet-service";

export class SignInUseCase {
  userDao: UserDao
  walletService: WalletService
  userService: UserService

  constructor() {
    this.userDao = new UserDao()
    this.walletService = new WalletService()
    this.userService = new UserService();
  }
  
  async execute(userMail: string, password: string): Promise<ResponseDto> {
    let ret = new ResponseDto()

    let user = await this.userDao.auth(userMail, password)

    if (user != null) {

      let userId = user.id

      let walletList: Wallet[] = await this.walletService.getWalletsByUserId(userId)

      let userDto = this.userService.handleUserDto(user, walletList)

      ret.success = true;
      ret.data = userDto;

    } else {
      ret.success = false;
      ret.errorMsg = 'Usuário não encontrado';
    }

    return ret
  }
}