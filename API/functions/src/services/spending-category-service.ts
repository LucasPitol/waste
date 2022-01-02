import { SpendingCategoryDao } from "../db/spending-category-dao"
import { ResponseDto } from "../models/dtos/response-dto"
import { SpendingCategory } from "../models/spending-category"

export class SpendingCategoryService {

    spendingCategoryDao: SpendingCategoryDao

    constructor() {
        this.spendingCategoryDao = new SpendingCategoryDao()
    }

    async createNewSpendingCategory(name: string, value: string) {
        var id = ''

        var spendingCategory = await this.getSpendingCategoryByValue(value)

        if (spendingCategory == null) {
            id = await this.spendingCategoryDao.createNewSpendingCategory(name, value)
        }

        return id
    }

    async getSpendingCategoryByValue(value: string) {
        return await this.spendingCategoryDao.getByValue(value)
    }

    async getSpendingCategoriesRes() {
        let ret = new ResponseDto()

        var spendingCategories: SpendingCategory[] = await this.spendingCategoryDao.getSpendingCategories()

        // sort
        if (spendingCategories.length > 0) {
            let sortered = spendingCategories.sort((n1, n2) => {
                if (n1.name! > n2.name!) {
                    return 1
                }

                if (n1.name! < n2.name!) {
                    return -1
                }

                return 0
            })

            spendingCategories = sortered
        }

        ret.success = true
        ret.data = spendingCategories

        return ret
    }
}
