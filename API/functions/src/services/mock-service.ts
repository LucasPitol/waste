import { WalletService } from "./wallet-service"
import { UserService } from "./user-service"
import { NewUserDto } from "../models/dtos/new-user-dto"

export class MockService {
    userService: UserService
    walletService: WalletService

    constructor() {
        this.userService = new UserService()
        this.walletService = new WalletService()
    }

    async mockData(): Promise<void> {
        let newUserDto: NewUserDto = new NewUserDto()

        newUserDto.name = 'Judas'
        newUserDto.email = 'judas@gmail.com'
        newUserDto.password = 'cXdlMTIz' //qwe123

        let userRes = await this.userService.createNewUserRes(newUserDto)

        if (userRes.success) {
            // save transactions
        }
    }
}