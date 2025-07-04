import { ResponseDto } from "../../models/dtos/response-dto";
import { WalletService } from "../../services/wallet-service";

export class GetUserWalletsUseCase {
  walletService: WalletService;

  constructor() {
    this.walletService = new WalletService();
  }

  async execute(userId: string): Promise<ResponseDto> {
    return await this.walletService.getWalletsByUserIdRes(userId);
  }
}
