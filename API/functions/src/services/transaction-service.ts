import { TransactionDao } from "../db/transaction-dao"
import { ResponseDto } from "../models/dtos/response-dto"
import { TransactionDto } from "../models/dtos/transaction-dto"
import { Transaction } from "../models/transaction"

export class TransactionService {

    transactionDao: TransactionDao

    constructor() {
        this.transactionDao = new TransactionDao()
    }

    async getTransactionsByWalletIdAndDateIntervalRes(walletId: string, startDate: Date, endDate: Date): Promise<ResponseDto> {
        let ret = new ResponseDto()

        if (startDate > endDate) {
            ret.success = false
            ret.errorMsg = 'Data inicial posterior a data final, verifique a data selecionada e tente novamente'

            return ret
        }

        var transactionDtoList: TransactionDto[] = []

        var transactions: Transaction[] = await this.transactionDao.getTransactionsByWalletIdAndDateIntervalRes(walletId, startDate, endDate)

        for (var element of transactions) {
            var transactionDto = new TransactionDto

            transactionDto.amount = element.amount;
            transactionDto.categoryId = element.categoryId;
            transactionDto.reason = element.reason;
            transactionDto.transactionDate = element.transactionDate;
            transactionDto.transactionId = element.id;

            transactionDtoList.push(transactionDto);
        }

        // sort
        if (transactionDtoList.length > 0) {
            let sortered = transactionDtoList.sort((n1, n2) => {
                if (n1.transactionDate! > n2.transactionDate!) {
                    return 1
                }

                if (n1.transactionDate! < n2.transactionDate!) {
                    return -1
                }

                return 0
            })

            transactionDtoList = sortered
        }

        ret.data = transactionDtoList
        ret.success = true

        return ret
    }

}