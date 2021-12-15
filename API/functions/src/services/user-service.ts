import { UserDao } from "../db/user-dao";
import { NewUserDto } from "../models/dtos/new-user-dto";
import { ResponseDto } from "../models/dtos/response-dto";
import { UserDto } from "../models/dtos/user-dto";
import { User } from "../models/user";
import { Wallet } from "../models/wallet";
import { Constants } from "../utils/constants";
import { WalletService } from "./wallet-service";

export class UserService {

    userDao: UserDao
    walletService: WalletService

    constructor() {
        this.userDao = new UserDao()
        this.walletService = new WalletService()
    }

    async createNewUserRes(newUserDto: NewUserDto): Promise<ResponseDto> {
        let ret = new ResponseDto()

        let userMail: string = newUserDto.email!

        let user = await this.userDao.getUserByEmail(userMail)

        if (user != null) {
            ret.success = false;
            ret.errorMsg = 'Email já cadastrado';

            return ret;
        }

        let name = newUserDto.name!
        let password = newUserDto.password!

        let uid = await this.userDao.createNewUser(name, userMail, password)

        // create standard wallet
        let standardWalletName = Constants.standardWalletName

        await this.walletService.createNewWallet(uid, standardWalletName)

        // auth
        user = await this.userDao.getUserById(uid);
        let walletList: Wallet[] = await this.walletService.getWalletsByUserId(uid)

        if (user != null) {
            let userDto = this.handleUserDto(user, walletList)

            ret.success = true
            ret.data = userDto
        }

        return ret
    }

    handleUserDto(user: User, walletList: Wallet[]) {
        let userDto: UserDto = new UserDto()

        let userId: string = user.id;

        if (walletList.length > 0) {
            userDto.creationDate = user.creationDate
            userDto.email = user.email
            userDto.id = userId
            userDto.displayName = user.name
            userDto.walletList = walletList

            userDto.currentWalletId = walletList[0].id
        }

        return userDto
    }

    async logInByUidRes(userId: string): Promise<ResponseDto> {
        let ret = new ResponseDto()

        let user = await this.userDao.getUserById(userId)

        if (user != null) {

            let userId = user.id

            let walletList: Wallet[] = await this.walletService.getWalletsByUserId(userId)

            let userDto = this.handleUserDto(user, walletList)

            ret.success = true;
            ret.data = userDto;

        } else {
            ret.success = false;
            ret.errorMsg = 'Usuário não encontrado';
        }

        return ret
    }

    async logInByEmailAndPasswordRes(email: string, password: string): Promise<ResponseDto> {

        let ret = new ResponseDto()

        let user = await this.userDao.auth(email, password)

        if (user != null) {

            let userId = user.id

            let walletList: Wallet[] = await this.walletService.getWalletsByUserId(userId)

            let userDto = this.handleUserDto(user, walletList)

            ret.success = true;
            ret.data = userDto;

        } else {
            ret.success = false;
            ret.errorMsg = 'Usuário não encontrado';
        }

        return ret
    }
}
