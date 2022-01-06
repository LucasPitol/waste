import { WalletDao } from "../db/wallet-dao"
import { ResponseDto } from "../models/dtos/response-dto"
import { Wallet } from "../models/wallet"

export class WalletService {

    walletDao: WalletDao

    constructor() {
        this.walletDao = new WalletDao()
    }

    async createNewWalletRes(userId: string, walletName: string) {
        let ret = new ResponseDto()
        
        var wallet = await this.walletDao.getWalletByNameAndOwnerId(walletName, userId)

        if (wallet != null) {
            ret.success = false
            ret.errorMsg = 'Já existe uma carteira com este nome'

            return ret
        }

        var walletId = await this.createNewWallet(userId, walletName)

        ret.success = true
        ret.data = walletId

        return ret
    }

    async createNewWallet(userId: string, walletName: string) {
        return await this.walletDao.createNewWallet(userId, walletName)
    }

    async getWalletsByUserIdRes(userId: string): Promise<ResponseDto> {
        let ret = new ResponseDto()

        let wallets = await this.getWalletsByUserId(userId)

        ret.success = true
        ret.data = wallets
    
        return ret
    }

    async getWalletsByUserId(userId: string): Promise<Wallet[]> {
        let walletList = await this.walletDao.getWalletsByUserId(userId)

        if (walletList.length > 0) {
            let sortered = walletList.sort((n1, n2) => {
                if (n1.name > n2.name) {
                    return 1
                }

                if (n1.name < n2.name) {
                    return -1
                }

                return 0
            })

            walletList = sortered
        }

        return walletList
    }
}