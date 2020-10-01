import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waste_app/models/user_dto.dart';
import 'package:waste_app/models/wallet.dart';
import 'package:waste_app/services/auth_service.dart';
import 'package:waste_app/services/wallet_service.dart';
import 'package:waste_app/utils/constants.dart';
import 'package:waste_app/utils/styles.dart';

class HomeComponent extends StatefulWidget {
  // HomeComponent({Key key}) : super(key: key);
  @override
  HomeComponentState createState() => HomeComponentState();
}

class HomeComponentState extends State<HomeComponent> {
  UserDto userDto = AuthService.currentUser;

  WalletService walletService;
  AuthService authService;

  bool isWalletOwner = false;
  bool isPtLanguage;
  List<Wallet> wallets;
  String dropdownWalletValue;

  HomeComponentState() {
    this.isPtLanguage = userDto.language == Constants.languages[0];
    this.walletService = WalletService();
    this.authService = AuthService();
  }

  void initState() {
    super.initState();
    this.authService.userExists(context);
    this._getUserWallets();
    // this._getTotalProfileData();
    this._updatePermission();
  }

  void _updatePermission() {
    String walletId = this.userDto.currentWalletId;
    String uid = this.userDto.uid;
    setState(() {
      this.isWalletOwner = this.walletService.isOwner(walletId, uid);
    });
  }

  Future<void> _getUserWallets() async {
    setState(() {
      wallets = this.walletService.getUserWalletsLocal();
    });

    this.dropdownWalletValue = this.walletService.getCurrentWalletId();

    String uid = this.userDto.uid;
    List<Wallet> walletsTemp = await this.walletService.getWalletsByUserId(uid);

    setState(() {
      wallets = walletsTemp;
    });
  }

  void switchWallets(String walletId) {
    setState(() {
      this.dropdownWalletValue = walletId;
    });

    this.walletService.switchWallet(walletId);

    // this._getTotalProfileData();
    this._updatePermission();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Styles.mainBackgroundColor,
      statusBarIconBrightness: Brightness.light,
    ));
    return Scaffold(
      backgroundColor: Styles.mainBackgroundColor,
      resizeToAvoidBottomPadding: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                Container(
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Container(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Rombado',
                              style: TextStyle(
                                color: Colors.grey.shade100,
                                fontWeight: FontWeight.w700,
                                fontSize: 24,
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Plano básico',
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                          onTap: () {
                            print('settings');
                          },
                          child: Icon(
                            Icons.settings,
                            color: Colors.grey.shade100,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.only(top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        child: DropdownButton<String>(
                          dropdownColor: Styles.mainBackgroundColor,
                          value: dropdownWalletValue,
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            // color: Colors.grey,
                          ),
                          iconSize: 24,
                          elevation: 16,
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade100,
                              fontSize: 14,
                            ),
                          ),
                          underline: Container(
                            height: 1,
                            color: Styles.mainBackgroundColor,
                          ),
                          onChanged: (String newValue) {
                            switchWallets(newValue);
                          },
                          items: wallets
                              .map<DropdownMenuItem<String>>((Wallet item) {
                            return DropdownMenuItem<String>(
                              value: item.id,
                              child: Text(
                                item.name,
                                style: Styles.poppinsTextLight,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      isWalletOwner
                          ? Container(
                              alignment: Alignment.topRight,
                              child: FlatButton(
                                onPressed: () {
                                  // _goToEditWalletPage();
                                  print('edit wallet');
                                },
                                child: Text(
                                  isPtLanguage ? 'Editar' : 'Edit',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14.0,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
