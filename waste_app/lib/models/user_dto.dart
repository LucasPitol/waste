import 'package:waste_app/models/wallet.dart';

class UserDto {
  String uid;
  String name;
  String email;
  String imageUrl;
  String theme;
  String language;
  String currentWalletId;
  List<Wallet> walletList;
}