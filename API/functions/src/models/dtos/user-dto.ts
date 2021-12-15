import { Wallet } from "../wallet"

export class UserDto {
    id?: string
    displayName?: string
    email?: string
    creationDate?: Date

    walletList?: Wallet[]
    currentWalletId?: string
}