import { ResponseDto } from "../../models/dtos/response-dto";
import { TransactionService } from "../../services/transaction-service";
import { NewTransactionDto } from "../../models/dtos/new-transaction-dto";

export class SaveTransactionUseCase {
  transactionService: TransactionService;

  constructor() {
    this.transactionService = new TransactionService();
  }

  async execute(newTransactionDto: NewTransactionDto): Promise<ResponseDto> {
    // Use the unified saveTransactionRes method
    return await this.transactionService.saveTransactionRes(newTransactionDto);
  }
}
