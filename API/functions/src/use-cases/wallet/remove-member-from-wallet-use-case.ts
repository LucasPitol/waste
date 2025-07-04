import { ResponseDto } from "../../models/dtos/response-dto";
import { WalletService } from "../../services/wallet-service";

export class RemoveMemberFromWalletUseCase {
  walletService: WalletService;

  constructor() {
    this.walletService = new WalletService();
  }

  async execute(memberId: string, walletId: string, ownerId: string): Promise<ResponseDto> {
    return await this.walletService.removeMemberFromWalletRes(memberId, walletId, ownerId);
  }
}
