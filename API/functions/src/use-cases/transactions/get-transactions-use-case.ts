import { ResponseDto } from "../../models/dtos/response-dto";
import { TransactionService } from "../../services/transaction-service";

export class GetTransactionsUseCase {
  transactionService: TransactionService;

  constructor() {
    this.transactionService = new TransactionService();
  }

  async execute(walletId: string, startDate: Date, endDate: Date, userId: string): Promise<ResponseDto> {
    return await this.transactionService.getTransactionsByWalletIdAndDateIntervalRes(
      walletId, 
      startDate, 
      endDate,
      userId
    );
  }
}
