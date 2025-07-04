import { UserSP } from "../db/sp/user-sp";
import { MemberDto } from "../models/dtos/member-dto";
import { ResponseDto } from "../models/dtos/response-dto";
import { UserDto } from "../models/dtos/user-dto";
import { User } from "../models/user";
import { Wallet } from "../models/wallet";
import { Constants } from "../utils/constants";
import { WalletService } from "./wallet-service";
import { EncryptionService } from "./encryption-service";

export class UserService {
  userSP: UserSP
  walletService: WalletService
  encryptionService: EncryptionService

  constructor() {
    this.userSP = new UserSP()
    this.walletService = new WalletService()
    this.encryptionService = new EncryptionService()
  }

  async getUserByEmail(userMail: string): Promise<User | null> {
    return await this.userSP.getUserByEmail(userMail)
  }

  async createUser(name: string, email: string, password: string): Promise<string> {
    // Hash the password at service layer
    const hashedPassword = await this.encryptionService.hashString(password);
    const userId = await this.userSP.createUserWithHashedPassword(name, email, hashedPassword);
    return userId; // Return as string (UUID)
  }

  async loginUser(email: string, password: string): Promise<User | null> {
    // Use the direct login method from SP layer
    return await this.userSP.loginUser(email, password);
  }

  async updateUserPassword(uid: string, newPassword: string) {
    // Hash the password before updating (since service layer handles this logic)
    const hashedPassword = await this.encryptionService.hashString(newPassword);
    let uidN: string = await this.userSP.changePasswordWithHashedPassword(uid, hashedPassword)

    return uidN
  }

  async getWalletMembersRes(memberIdList: string[]): Promise<ResponseDto> {
    let ret = new ResponseDto()

    var walletMembers: MemberDto[] = []

    var usersFromWallet = await this.userSP.getUsersByIds(memberIdList)

    if (usersFromWallet.length > 0) {
      var walletMembersTemp: MemberDto[] = []

      for (const user of usersFromWallet) {

        var memberDto = new MemberDto()

        memberDto.email = user.email
        memberDto.id = user.id
        memberDto.name = user.displayName

        walletMembersTemp.push(memberDto)
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

      walletMembers = sortered
    }

    ret.success = true
    ret.data = walletMembers

    return ret
  }

  async addMemberToWalletRes(memberMail: string, walletId: string, ownerId: string): Promise<ResponseDto> {
    let ret = new ResponseDto()

    // Check if the requester is the wallet owner
    const isOwner = await this.walletService.isWalletOwner(walletId, ownerId)
    if (!isOwner) {
      ret.success = false
      ret.errorMsg = 'Apenas o proprietário da carteira pode adicionar membros'
      return ret
    }

    var wallet: Wallet | null = await this.walletService.getWalletById(walletId)

    if (wallet == null) {
      ret.success = false
      ret.errorMsg = 'Erro inesperado, tente novamente mais tarde'

      return ret
    }

    var walletMembersIds = wallet.membersIds

    var currentMembersCount: number = walletMembersIds.length

    if (currentMembersCount >= Constants.walletMembersLimitOnFreePlan) {
      var walletName: string = wallet.name

      ret.success = false
      ret.errorMsg = `Limite de membros atingido em ${walletName}, em breve o limite será estendido`

      return ret
    }

    var member: User | null = await this.userSP.getUserByEmail(memberMail);

    if (member == null) {
      ret.success = false
      ret.errorMsg = 'Membro não encontrado, verifique o email digitado'

      return ret
    }

    var memberId = member.id

    if (walletMembersIds.includes(memberId)) {
      ret.success = false
      ret.errorMsg = 'Membro jà adicionado'

      return ret
    }

    await this.walletService.addMemberToWallet(memberId, wallet)

    ret.success = true
    ret.data = member.displayName

    return ret
  }

  handleUserDto(user: User, walletList: Wallet[]) {
    let userDto: UserDto = new UserDto()

    let userId: string = user.id;

    userDto.creationDate = user.creationDate
    userDto.email = user.email
    userDto.id = userId
    userDto.displayName = user.displayName
    userDto.walletList = walletList

    userDto.currentWalletId = walletList[0].id
    return userDto
  }

  async logInByUidRes(userId: string): Promise<ResponseDto> {
    let ret = new ResponseDto()

    let user = await this.userSP.getUserById(userId) // Use as UUID string

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
