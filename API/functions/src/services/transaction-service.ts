import { TransactionDao } from "../db/transaction-dao"
import { NewRevenueDto } from "../models/dtos/new-revenue-dto"
import { NewWasteDto } from "../models/dtos/new-waste-dto"
import { OverviewPageDto } from "../models/dtos/overview-page-dto"
import { ResponseDto } from "../models/dtos/response-dto"
import { TransactionDto } from "../models/dtos/transaction-dto"
import { SpendingCategory } from "../models/spending-category"
import { Transaction } from "../models/transaction"
import { Tuple } from "../models/tuple"
import { Utils } from "../utils/utils"
import { SpendingCategoryService } from "./spending-category-service"

export class TransactionService {

    spendingCategoryService: SpendingCategoryService
    transactionDao: TransactionDao

    constructor() {
        this.spendingCategoryService = new SpendingCategoryService()
        this.transactionDao = new TransactionDao()
    }

    async saveNewWasteRes(newWasteDtoMap: any): Promise<ResponseDto> {
        let ret = new ResponseDto()

        var newWasteDto = new NewWasteDto()

        newWasteDto.categoryId = newWasteDtoMap.categoryId
        newWasteDto.reason = newWasteDtoMap.reason
        newWasteDto.spendDate = new Date(newWasteDtoMap.spendDate)
        newWasteDto.uid = newWasteDtoMap.uid
        newWasteDto.walletId = newWasteDtoMap.walletId
        newWasteDto.waste = newWasteDtoMap.waste

        var id = await this.transactionDao.saveNewWaste(newWasteDto)

        ret.success = true
        ret.data = id

        return ret
    }

    async saveNewRevenueRes(newRevenueDtoMap: any): Promise<ResponseDto> {
        let ret = new ResponseDto()

        var newRevenueDto = new NewRevenueDto()

        newRevenueDto.reason = newRevenueDtoMap.reason
        newRevenueDto.payDay = new Date(newRevenueDtoMap.payDay)
        newRevenueDto.uid = newRevenueDtoMap.uid
        newRevenueDto.walletId = newRevenueDtoMap.walletId
        newRevenueDto.amount = newRevenueDtoMap.amount

        var id = await this.transactionDao.saveNewRevenue(newRevenueDto)

        ret.success = true
        ret.data = id

        return ret
    }

    async getOverviewPageDataRes(walletId: string, startDate: Date, endDate: Date): Promise<ResponseDto> {
        let ret = new ResponseDto()

        if (startDate > endDate) {
            ret.success = false
            ret.errorMsg = 'Data inicial posterior a data final, verifique a data selecionada e tente novamente'

            return ret
        }

        var transactions: Transaction[] = await this.transactionDao.getTransactionsByWalletIdAndDateInterval(walletId, startDate, endDate)

        // for (var element of transactions) {!!!!!!!!!!!!!


        var spendingCategoriesRes =
            await this.spendingCategoryService.getSpendingCategoriesRes()

        if (spendingCategoriesRes.success) {
            var overViewPageDto = new OverviewPageDto()

            var categories: SpendingCategory[] = spendingCategoriesRes.data

            var income = 0.0
            var spends = 0.0

            var transactionDtoList: TransactionDto[] = []

            var spendsByCategoryIdMap = new Map<string, number>()

            for (var element of transactions) {
                var transactionDto = new TransactionDto()

                var amount = element.amount

                transactionDto.amount = amount
                transactionDto.categoryId = element.categoryId
                transactionDto.reason = element.reason
                transactionDto.transactionDate = element.transactionDate
                transactionDto.transactionId = element.id

                transactionDtoList.push(transactionDto)

                if (amount >= 0) {
                    income = income + amount
                } else {
                    spends = spends + amount
                }

                var categoryId = element.categoryId

                //     // var category = categories
                //     //     .singleWhere((element) => categoryId == transactionDto.categoryId);

                if (categoryId != null && amount < 0) {
                    if (spendsByCategoryIdMap.has(categoryId)) {
                        var mapValue = spendsByCategoryIdMap.get(categoryId)

                        mapValue = mapValue! + amount

                        spendsByCategoryIdMap.delete(categoryId)

                        spendsByCategoryIdMap.set(categoryId, mapValue!)
                    } else {
                        spendsByCategoryIdMap.set(categoryId, amount)
                    }
                }
            }

            var spendsByCategoryMap = new Map<string, number>()

            spendsByCategoryIdMap.forEach((value: number, key: string) => {
                var categoryName = categories.find(element => element.id == key)?.name

                spendsByCategoryMap.set(categoryName!, value)
            })

            var mapAsc = new Map([...spendsByCategoryMap.entries()].sort())
            var sortedMapReduced = mapAsc

            var totalOthers = 0.0
            var i = 0
            mapAsc.forEach((value: number, key: string) => {

                if (i >= 3) {

                    totalOthers = totalOthers + value

                    sortedMapReduced.delete(key)

                    if (i == (mapAsc.size - 1)) {
                        var key = 'Demais';
                        sortedMapReduced.set(key, totalOthers)
                    }
                }
                i++
            })

            //map to list<tuple>
            var mapAscList: Tuple[] = []
            var sortedMapReducedList: Tuple[] = []

            mapAsc.forEach((value: number, key: string) => {
                var tuple = new Tuple()
                tuple.a = key
                tuple.b = value

                mapAscList.push(tuple)
            })

            mapAscList = Utils.sortTupleByB(mapAscList)

            sortedMapReduced.forEach((value: number, key: string) => {
                var tuple = new Tuple()
                tuple.a = key
                tuple.b = value

                sortedMapReducedList.push(tuple)
            })

            sortedMapReducedList = Utils.sortTupleByB(sortedMapReducedList)

            overViewPageDto.income = income
            overViewPageDto.spends = spends
            overViewPageDto.balance = (income + spends)
            overViewPageDto.spendsByCategory = mapAscList
            overViewPageDto.pieChartData = sortedMapReducedList

            ret.success = true
            ret.data = overViewPageDto
        }

        return ret
    }

    async getTransactionsByWalletIdAndDateIntervalRes(walletId: string, startDate: Date, endDate: Date): Promise<ResponseDto> {
        let ret = new ResponseDto()

        if (startDate > endDate) {
            ret.success = false
            ret.errorMsg = 'Data inicial posterior a data final, verifique a data selecionada e tente novamente'

            return ret
        }

        var transactionDtoList: TransactionDto[] = []

        var transactions: Transaction[] = await this.transactionDao.getTransactionsByWalletIdAndDateInterval(walletId, startDate, endDate)

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