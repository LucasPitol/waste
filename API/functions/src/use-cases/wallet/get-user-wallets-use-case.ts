import { ResponseDto } from "../../models/dtos/response-dto";
import { WalletService } from "../../services/wallet-service";

export class GetUserWalletsUseCase {
  walletService: WalletService;

  constructor() {
    this.walletService = new WalletService();
  }

  async execute(userId: string): Promise<ResponseDto> {
    let ret = new ResponseDto();

    let wallets = await this.walletService.getWalletsByUserId(userId);

    ret.success = true;
    ret.data = wallets;

    return ret;
  }
}
