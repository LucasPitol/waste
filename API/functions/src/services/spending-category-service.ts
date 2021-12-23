import { SpendingCategoryDao } from "../db/spending-category-dao"

export class SpendingCategoryService {

    spendingCategoryDao: SpendingCategoryDao

    constructor() {
        this.spendingCategoryDao = new SpendingCategoryDao()
    }

    async createNewSpendingCategory(name: string, value: string) {
        var spendingCategory = await this.getSpendingCategoryByValue(value)

        if (spendingCategory == null) {
            await this.spendingCategoryDao.createNewSpendingCategory(name, value)
        }
    }

    async getSpendingCategoryByValue(value: string) {
        return await this.spendingCategoryDao.getByValue(value)
    }
 }
