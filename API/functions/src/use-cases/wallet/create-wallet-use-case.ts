import { ResponseDto } from "../../models/dtos/response-dto";
import { WalletService } from "../../services/wallet-service";

export class CreateWalletUseCase {
  walletService: WalletService;

  constructor() {
    this.walletService = new WalletService();
  }

  async execute(userId: string, walletName: string): Promise<ResponseDto> {
    return await this.walletService.createNewWalletRes(userId, walletName);
  }
}
