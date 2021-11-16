import 'package:meudin_app/db/wallet_dao.dart';
import 'package:meudin_app/models/dtos/response_dto.dart';
import 'package:meudin_app/models/wallet.dart';

class WalletService {
  late WalletDao _walletDao;

  WalletService() {
    _walletDao = WalletDao();
  }

  Future<ResponseDto> getWalletsByUserId(String uid) async {
    ResponseDto res = ResponseDto();

    List<Wallet> wallets = await _walletDao.getWalletsByUserId(uid);

    if (wallets.isEmpty) {
      await createPersonalWallet(uid);

      wallets = await _walletDao.getWalletsByUserId(uid);
    }

    res.success = true;
    res.data = wallets;

    return res;
  }

  Future<ResponseDto> removeMember(String memberId, Wallet wallet) async {
    ResponseDto res = ResponseDto();

    List<String> membersIds = wallet.membersId;

    membersIds.remove(memberId);

    wallet.membersId = membersIds;

    String walletId = wallet.id;

    await _walletDao.updateMemberList(membersIds, walletId);

    return res;
  }

  Future<ResponseDto> addMemberToWallet(String memberId, Wallet wallet) async {
    ResponseDto res = ResponseDto();

    String walletId = wallet.id;

    List<String> members = wallet.membersId;

    members.add(memberId);

    await _walletDao.updateMemberList(members, walletId);

    res.success = true;
    res.data = true;

    return res;
  }

  Future<ResponseDto> createNewWallet(String walletName, String userId) async {
    ResponseDto res = ResponseDto();

    String walletId = await _walletDao.createNewWallet(walletName, userId);

    if (walletId != null && walletId.isNotEmpty) {
      res.success = true;
      res.data = walletId;
    } else {
      res.success = false;
      res.errorMsg =
          'Não foi possível criar a carteira, revise o formulário e tente novamente';
    }

    return res;
  }

  Future<String> createPersonalWallet(String uid) async {
    return await _walletDao.createNewWallet('Carteira pessoal', uid);
  }
}
