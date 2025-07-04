import { ResponseDto } from "../../models/dtos/response-dto";
import { WalletService } from "../../services/wallet-service";
import { UserService } from "../../services/user-service";

export class GetWalletMembersUseCase {
  walletService: WalletService;
  userService: UserService;

  constructor() {
    this.walletService = new WalletService();
    this.userService = new UserService();
  }

  async execute(walletId: string, requesterId: string): Promise<ResponseDto> {
    const walletMembersRes = await this.walletService.getWalletMembersRes(walletId, requesterId);
    
    if (!walletMembersRes.success) {
      return walletMembersRes;
    }

    const memberIdList = walletMembersRes.data as string[];
    
    // Now get the member details using the UserService  
    return await this.userService.getWalletMembersRes(memberIdList);
  }
}
