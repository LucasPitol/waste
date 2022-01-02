import { WalletService } from "./wallet-service"
import { UserService } from "./user-service"
import { NewUserDto } from "../models/dtos/new-user-dto"
import { SpendingCategoryService } from "./spending-category-service"

export class MockService {
    userService: UserService
    walletService: WalletService
    spendingCategoryService: SpendingCategoryService

    constructor() {
        this.userService = new UserService()
        this.walletService = new WalletService()
        this.spendingCategoryService = new SpendingCategoryService()
    }

    async mockData(): Promise<void> {
        let newUserDto: NewUserDto = new NewUserDto()

        newUserDto.name = 'Judas'
        newUserDto.email = 'judas@gmail.com'
        newUserDto.password = 'cXdlMTIz' //qwe123

        let userRes = await this.userService.createNewUserRes(newUserDto)

        if (userRes.success) {

            await this.spendingCategoryService.createNewSpendingCategory('Internet', 'internet')
            await this.spendingCategoryService.createNewSpendingCategory('Veículo', 'vehicle')
            await this.spendingCategoryService.createNewSpendingCategory('Outros', 'others')

            // var newWasteDto1 = new NewWasteDto()
            // newWasteDto1.categoryId = internetCategoryId
            // newWasteDto1.reason = 'Internet'
            // newWasteDto1.spendDate = new Date()
            // newWasteDto1.uid = ''
            // newWasteDto1.walletId = ''

            // await this.transactionService.saveNewWasteRes(newWasteDto1)
        }
    }
}