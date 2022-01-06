import { UserDao } from "../db/user-dao";
import { MemberDto } from "../models/dtos/member-dto";
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

    async changePasswordRes(uid: string, password: string): Promise<ResponseDto> {
        let ret = new ResponseDto()

        let uidN: string = await this.userDao.changePassword(uid, password)

        if (uidN == null) {
            ret.success = false
            ret.errorMsg =
                'Não foi possível alterar a senha, tente novamente mais tarde'
        } else {
            ret.success = true
            ret.data = true
        }

        return ret
    }

    async getWalletMembersRes(memberIdList: string[]): Promise<ResponseDto> {
        let ret = new ResponseDto()

        var walletMembers: MemberDto[] = []

        var usersFromWallet = await this.userDao.getUsersByIds(memberIdList)

        if (usersFromWallet.length > 0) {
            var walletMembersTemp: MemberDto[] = []

            for (const user of usersFromWallet) {

                var memberDto = new MemberDto()

                memberDto.email = user.email
                memberDto.id = user.id
                memberDto.name = user.name

                walletMembersTemp.push()
            }

            let sortered = walletMembersTemp.sort((n1, n2) => {
                if (n1.name! > n2.name!) {
                    return 1
                }

                if (n1.name! < n2.name!) {
                    return -1
                }

                return 0
            })

            walletMembersTemp = sortered
        }

        ret.success = true
        ret.data = walletMembers

        return ret
    }

    async addMemberToWalletRes(memberMail: string, walletId: string): Promise<ResponseDto> {
        let ret = new ResponseDto()

        var wallet: Wallet | null = await this.walletService.getWalletById(walletId)
        console.log(wallet)
        if (wallet == null) {
            ret.success = false
            ret.errorMsg = 'Erro inesperado, tente novamente mais tarde'

            return ret
        }

        var walletMembersIds = wallet.membersId

        var currentMembersCount: number = walletMembersIds.length

        if (currentMembersCount >= Constants.walletMembersLimitOnFreePlan) {
            var walletName: string = wallet.name

            ret.success = false
            ret.errorMsg = `Limite de membros atingido em ${walletName}, em breve o limite será estendido`

            return ret
        }

        var member: User | null = await this.userDao.getUserByEmail(memberMail);

        if (member == null) {
          ret.success = false
          ret.errorMsg = 'Membro não encontrado, verifique o email digitado'

          return ret
        }

        // ResponseDto walletServiceRes =
        //     await _walletService.addMemberToWallet(member.id, wallet);

        // if (walletServiceRes.success) {
        //   res.success = true;
        //   res.data = member.name;
        // } else {
        //   res.success = false;
        //   res.errorMsg = walletServiceRes.errorMsg;
        // }

        return ret
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
        user = await this.userDao.getUserById(uid)
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
