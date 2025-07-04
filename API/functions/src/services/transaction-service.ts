import { TransactionSP } from "../db/sp/transaction-sp";
import { NewTransactionDto } from "../models/dtos/new-transaction-dto";
import { OverviewPageDto } from "../models/dtos/overview-page-dto";
import { ResponseDto } from "../models/dtos/response-dto";
import { TransactionDto } from "../models/dtos/transaction-dto";
import { SpendingCategory } from "../models/spending-category";
import { Transaction } from "../models/transaction";
import { Tuple } from "../models/tuple";
import { Utils } from "../utils/utils";
import { SpendingCategoryService } from "./spending-category-service";
import { WalletService } from "./wallet-service";

export class TransactionService {
  spendingCategoryService: SpendingCategoryService;
  transactionSP: TransactionSP;
  walletService: WalletService;

  constructor() {
    this.spendingCategoryService = new SpendingCategoryService();
    this.transactionSP = new TransactionSP();
    this.walletService = new WalletService();
  }

  async getOverviewPageDataRes(
    walletId: string,
    startDate: Date,
    endDate: Date,
    userId: string
  ): Promise<ResponseDto> {
    let ret = new ResponseDto();

    if (startDate > endDate) {
      ret.success = false;
      ret.errorMsg =
        "Data inicial posterior a data final, verifique a data selecionada e tente novamente";

      return ret;
    }

    // Check if user has access to this wallet (owner or member)
    const wallet = await this.walletService.getWalletById(walletId);
    if (!wallet) {
      ret.success = false;
      ret.errorMsg = "Carteira não encontrada";
      return ret;
    }

    const isOwner = wallet.ownerId === userId;
    const isMember = wallet.membersIds.includes(userId);

    if (!isOwner && !isMember) {
      ret.success = false;
      ret.errorMsg =
        "Acesso negado: você não tem permissão para ver os dados desta carteira";
      return ret;
    }

    var transactions: Transaction[] =
      await this.transactionSP.getTransactionsByWalletIdAndDateInterval(
        walletId,
        startDate,
        endDate
      );

    // for (var element of transactions) {!!!!!!!!!!!!!

    var spendingCategoriesRes =
      await this.spendingCategoryService.getSpendingCategoriesRes();

    if (spendingCategoriesRes.success) {
      var overViewPageDto = new OverviewPageDto();

      var categories: SpendingCategory[] = spendingCategoriesRes.data;

      var income = 0.0;
      var spends = 0.0;

      var transactionDtoList: TransactionDto[] = [];

      var spendsByCategoryIdMap = new Map<string, number>();

      for (var element of transactions) {
        var transactionDto = new TransactionDto();

        var amount = element.amount;

        transactionDto.amount = amount;
        transactionDto.categoryId = element.categoryId;
        transactionDto.reason = element.reason;
        transactionDto.transactionDate = element.transactionDate;
        transactionDto.transactionId = element.id;

        transactionDtoList.push(transactionDto);

        if (amount >= 0) {
          income = income + amount;
        } else {
          spends = spends + amount;
        }

        var categoryId = element.categoryId;

        //     // var category = categories
        //     //     .singleWhere((element) => categoryId == transactionDto.categoryId);

        if (categoryId != null && amount < 0) {
          if (spendsByCategoryIdMap.has(categoryId)) {
            var mapValue = spendsByCategoryIdMap.get(categoryId);

            mapValue = mapValue! + amount;

            spendsByCategoryIdMap.delete(categoryId);

            spendsByCategoryIdMap.set(categoryId, mapValue!);
          } else {
            spendsByCategoryIdMap.set(categoryId, amount);
          }
        }
      }

      var spendsByCategoryMap = new Map<string, number>();

      spendsByCategoryIdMap.forEach((value: number, key: string) => {
        var categoryName = categories.find(
          (element) => element.id == key
        )?.name;

        spendsByCategoryMap.set(categoryName!, value);
      });

      var mapAsc = new Map([...spendsByCategoryMap.entries()].sort());
      var sortedMapReduced = mapAsc;

      var totalOthers = 0.0;
      var i = 0;
      mapAsc.forEach((value: number, key: string) => {
        if (i >= 3) {
          totalOthers = totalOthers + value;

          sortedMapReduced.delete(key);

          if (i == mapAsc.size - 1) {
            var key = "Demais";
            sortedMapReduced.set(key, totalOthers);
          }
        }
        i++;
      });

      //map to list<tuple>
      var mapAscList: Tuple[] = [];
      var sortedMapReducedList: Tuple[] = [];

      mapAsc.forEach((value: number, key: string) => {
        var tuple = new Tuple();
        tuple.a = key;
        tuple.b = value;

        mapAscList.push(tuple);
      });

      mapAscList = Utils.sortTupleByB(mapAscList);

      sortedMapReduced.forEach((value: number, key: string) => {
        var tuple = new Tuple();
        tuple.a = key;
        tuple.b = value;

        sortedMapReducedList.push(tuple);
      });

      sortedMapReducedList = Utils.sortTupleByB(sortedMapReducedList);

      overViewPageDto.income = income;
      overViewPageDto.spends = spends;
      overViewPageDto.balance = income + spends;
      overViewPageDto.spendsByCategory = mapAscList;
      overViewPageDto.pieChartData = sortedMapReducedList;

      ret.success = true;
      ret.data = overViewPageDto;
    }

    return ret;
  }

  async getTransactionsByWalletIdAndDateIntervalRes(
    walletId: string,
    startDate: Date,
    endDate: Date,
    userId: string
  ): Promise<ResponseDto> {
    let ret = new ResponseDto();

    if (startDate > endDate) {
      ret.success = false;
      ret.errorMsg =
        "Data inicial posterior a data final, verifique a data selecionada e tente novamente";

      return ret;
    }

    // Check if user has access to this wallet (owner or member)
    const wallet = await this.walletService.getWalletById(walletId);
    if (!wallet) {
      ret.success = false;
      ret.errorMsg = "Carteira não encontrada";
      return ret;
    }

    const isOwner = wallet.ownerId === userId;
    const isMember = wallet.membersIds.includes(userId);

    if (!isOwner && !isMember) {
      ret.success = false;
      ret.errorMsg =
        "Acesso negado: você não tem permissão para ver as transações desta carteira";
      return ret;
    }

    var transactionDtoList: TransactionDto[] = [];

    var transactions: Transaction[] =
      await this.transactionSP.getTransactionsByWalletIdAndDateInterval(
        walletId,
        startDate,
        endDate
      );

    for (var element of transactions) {
      var transactionDto = new TransactionDto();

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
          return 1;
        }

        if (n1.transactionDate! < n2.transactionDate!) {
          return -1;
        }

        return 0;
      });

      transactionDtoList = sortered;
    }

    ret.data = transactionDtoList;
    ret.success = true;

    return ret;
  }

  async saveTransactionRes(
    newTransactionDto: NewTransactionDto
  ): Promise<ResponseDto> {
    let ret = new ResponseDto();
    console.log(newTransactionDto);
    // Validate required fields
    if (
      !newTransactionDto.userId ||
      !newTransactionDto.walletId ||
      !newTransactionDto.type ||
      typeof newTransactionDto.amount !== "number"
    ) {
      ret.success = false;
      ret.errorMsg =
        "User ID, wallet ID, transaction type, and amount are required";
      return ret;
    }

    // Validate transaction type
    if (
      newTransactionDto.type !== "waste" &&
      newTransactionDto.type !== "revenue"
    ) {
      ret.success = false;
      ret.errorMsg = 'Transaction type must be either "waste" or "revenue"';
      return ret;
    }

    // Check if user has access to this wallet (owner or member)
    const wallet = await this.walletService.getWalletById(
      newTransactionDto.walletId
    );
    if (!wallet) {
      ret.success = false;
      ret.errorMsg = "Carteira não encontrada";
      return ret;
    }

    const isOwner = wallet.ownerId === newTransactionDto.userId;
    const isMember = wallet.membersIds.includes(newTransactionDto.userId);

    if (!isOwner && !isMember) {
      ret.success = false;
      ret.errorMsg =
        "Acesso negado: você não tem permissão para adicionar transações a esta carteira";
      return ret;
    }

    try {
      const id = await this.transactionSP.saveTransaction(newTransactionDto);
      ret.success = true;
      ret.data = id;
    } catch (error) {
      ret.success = false;
      ret.errorMsg = "Failed to save transaction";
    }

    return ret;
  }
}
