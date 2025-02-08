import { UserDao } from "../../db/user-dao";
import { ResponseDto } from "../../models/dtos/response-dto";
import { Wallet } from "../../models/wallet";
import { EncryptionService } from "../../services/encryption-service";
import { UserService } from "../../services/user-service";
import { WalletService } from "../../services/wallet-service";
const bcrypt = require("bcrypt");

export class SignInUseCase {
  userDao: UserDao;
  encryptionService: EncryptionService;
  walletService: WalletService;
  userService: UserService;

  constructor() {
    this.userDao = new UserDao();
    this.encryptionService = new EncryptionService();
    this.walletService = new WalletService();
    this.userService = new UserService();
  }

  async execute(userMail: string, password: string): Promise<ResponseDto> {
    let ret = new ResponseDto();

    let user = await this.userDao.getUserByEmail(userMail);

    if (user == null) {
      ret.success = false;
      ret.errorMsg = "Usuário não encontrado";
      return ret;
    }
    console.log("Stored Hashed Password:", user.password);

    if (await bcrypt.compare(password, user.password)) {
      let userId = user.id;
      user.password = "";

      let walletList: Wallet[] = await this.walletService.getWalletsByUserId(
        userId
      );

      let userDto = this.userService.handleUserDto(user, walletList);

      ret.success = true;
      ret.data = userDto;
      return ret;
    } else {
      ret.success = false;
      ret.errorMsg = "Usuário não encontrado";
      return ret;
    }
  }
}
