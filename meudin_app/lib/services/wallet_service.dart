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

  Future<String> createPersonalWallet(String uid) async {
    return await _walletDao.createNewWallet('Carteira pessoal', uid);
  }
}
