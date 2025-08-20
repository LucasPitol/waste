import { WalletSP } from "../db/sp/wallet-sp";
import { ResponseDto } from "../models/dtos/response-dto";
import { Wallet } from "../models/wallet";

export class WalletService {
  walletSP: WalletSP;

  constructor() {
    this.walletSP = new WalletSP();
  }

  async createNewWalletRes(userId: string, walletName: string) {
    let ret = new ResponseDto();

    var wallet = await this.walletSP.getWalletByNameAndOwnerId(
      walletName,
      userId
    );

    if (wallet != null) {
      ret.success = false;
      ret.errorMsg = "Já existe uma carteira com este nome";

      return ret;
    }

    var walletId = await this.createNewWallet(userId, walletName);

    ret.success = true;
    ret.data = walletId;

    return ret;
  }

  async addMemberToWallet(memberId: string, wallet: Wallet) {
    await this.walletSP.addMemberToWallet(memberId, wallet.id);
  }

  async createNewWallet(userId: string, walletName: string) {
    return await this.walletSP.createNewWallet(userId, walletName);
  }

  async getWalletById(walletId: string): Promise<Wallet | null> {
    return await this.walletSP.getById(walletId);
  }

  async removeMemberFromWalletResOld(
    memberId: string,
    walletId: string
  ): Promise<ResponseDto> {
    let ret = new ResponseDto();

    await this.walletSP.removeMemberFromWallet(memberId, walletId);

    ret.success = true;
    return ret;
  }

  async getWalletsByUserId(userId: string): Promise<Wallet[]> {
    let walletList = await this.walletSP.getWalletsByUserId(userId);

    if (walletList.length > 0) {
      let sortered = walletList.sort((n1: Wallet, n2: Wallet) => {
        if (n1.name > n2.name) {
          return 1;
        }

        if (n1.name < n2.name) {
          return -1;
        }

        return 0;
      });

      walletList = sortered;
    }

    return walletList;
  }

  async isWalletOwner(walletId: string, userId: string): Promise<boolean> {
    const wallet = await this.getWalletById(walletId);
    return wallet ? wallet.ownerId === userId : false;
  }

  async addMemberToWalletRes(
    memberId: string,
    walletId: string,
    ownerId: string
  ): Promise<ResponseDto> {
    let ret = new ResponseDto();

    // Check if the requester is the wallet owner
    const isOwner = await this.isWalletOwner(walletId, ownerId);
    if (!isOwner) {
      ret.success = false;
      ret.errorMsg = "Apenas o proprietário da carteira pode adicionar membros";
      return ret;
    }

    const wallet = await this.getWalletById(walletId);
    if (!wallet) {
      ret.success = false;
      ret.errorMsg = "Carteira não encontrada";
      return ret;
    }

    await this.addMemberToWallet(memberId, wallet);

    ret.success = true;
    return ret;
  }

  async removeMemberFromWalletRes(
    memberId: string,
    walletId: string,
    ownerId: string
  ): Promise<ResponseDto> {
    let ret = new ResponseDto();

    // Check if the requester is the wallet owner
    const isOwner = await this.isWalletOwner(walletId, ownerId);
    if (!isOwner) {
      ret.success = false;
      ret.errorMsg = "Apenas o proprietário da carteira pode remover membros";
      return ret;
    }

    // Don't allow owner to remove themselves
    if (memberId === ownerId) {
      ret.success = false;
      ret.errorMsg = "O proprietário da carteira não pode se remover";
      return ret;
    }

    await this.walletSP.removeMemberFromWallet(memberId, walletId);

    ret.success = true;
    return ret;
  }

  async getWalletMembersRes(
    walletId: string,
    requesterId: string
  ): Promise<ResponseDto> {
    let ret = new ResponseDto();

    const wallet = await this.getWalletById(walletId);
    if (!wallet) {
      ret.success = false;
      ret.errorMsg = "Carteira não encontrada";
      return ret;
    }

    // Check if requester is owner or member of the wallet
    const isOwner = wallet.ownerId === requesterId;
    const isMember = wallet.membersIds.includes(requesterId);

    if (!isOwner && !isMember) {
      ret.success = false;
      ret.errorMsg =
        "Acesso negado: você não tem permissão para ver os membros desta carteira";
      return ret;
    }

    ret.success = true;
    ret.data = wallet.membersIds;
    return ret;
  }
}
