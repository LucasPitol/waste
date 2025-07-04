import { ResponseDto } from "../../models/dtos/response-dto";
import { UserService } from "../../services/user-service";

export class AddMemberToWalletUseCase {
  userService: UserService;

  constructor() {
    this.userService = new UserService();
  }

  async execute(memberMail: string, walletId: string, ownerId: string): Promise<ResponseDto> {
    return await this.userService.addMemberToWalletRes(memberMail, walletId, ownerId);
  }
}
