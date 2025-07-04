import { ResponseDto } from "../../models/dtos/response-dto";
import { Wallet } from "../../models/wallet";
import { UserService } from "../../services/user-service";
import { WalletService } from "../../services/wallet-service";

export class SignInUseCase {
  userService: UserService;
  walletService: WalletService;

  constructor() {
    this.userService = new UserService();
    this.walletService = new WalletService();
  }

  async execute(userMail: string, password: string): Promise<ResponseDto> {
    let ret = new ResponseDto();

    // Use UserService login method which handles password verification
    let user = await this.userService.loginUser(userMail, password);

    if (user == null) {
      ret.success = false;
      ret.errorMsg = "Usuário não encontrado";
      return ret;
    }

    let userId = user.id;
    user.password = ""; // Clear password from response

    let walletList: Wallet[] = await this.walletService.getWalletsByUserId(
      userId
    );

    let userDto = this.userService.handleUserDto(user, walletList);

    ret.success = true;
    ret.data = userDto;
    return ret;
  }
}
