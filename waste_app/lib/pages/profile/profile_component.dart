import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waste_app/models/user_dto.dart';
import 'package:waste_app/models/wallet.dart';
import 'package:waste_app/pages/manage-wallets/edit_wallet.dart';
import 'package:waste_app/services/auth_service.dart';
import 'package:waste_app/services/spends-service.dart';
import 'package:waste_app/services/wallet-service.dart';
import 'package:waste_app/utils/constants.dart';
import 'package:waste_app/utils/styles.dart';

class ProfileComponent extends StatefulWidget {
  ProfileComponent({Key key}) : super(key: key);
  @override
  ProfileComponentState createState() => ProfileComponentState();
}

class ProfileComponentState extends State<ProfileComponent> {
  UserDto userDto = AuthService.currentUser;
  double totalWasteThisYear = 0.0;
  bool totalWasteThisYearLoading = true;
  bool isWalletOwner = false;

  SpendsService spendService;
  WalletService walletService;

  ProfileComponentState() {
    this.spendService = SpendsService();
    this.walletService = WalletService();
  }

  List<Wallet> wallets;

  String dropdownWalletValue;

  void initState() {
    super.initState();
    this._getUserWallets();
    this._updatePermission();
    this._getTotalWasteThisYear();
  }

  void _getUserWallets() {
    wallets = this.walletService.getUserWallets();

    this.dropdownWalletValue = this.walletService.getCurrentWalletId();
  }

  void switchWallets(String walletId) {
    setState(() {
      this.dropdownWalletValue = walletId;
    });

    this.walletService.switchWallet(walletId);

    this._getTotalWasteThisYear();
    this._updatePermission();
  }

  void _goToEditWalletPage() async {
    var refresh = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => EditWallet()));

    if (refresh != null && refresh) {
      _updatePageContent();
    }
  }

  void _updatePermission() {
    String walletId = this.userDto.currentWalletId;
    String uid = this.userDto.uid;
    setState(() {
      this.isWalletOwner =
          this.walletService.isOwner(walletId, uid);
    });
  }

  _updatePageContent() {
    this._getUserWallets();
    this._updatePermission();
    this._getTotalWasteThisYear();
  }

  Future<void> _getTotalWasteThisYear() async {
    setState(() {
      totalWasteThisYearLoading = true;
    });

    DateTime now = DateTime.now();

    double total = await this.spendService.getTotalWasteByYear(now);

    this.totalWasteThisYear = total;

    setState(() {
      this.totalWasteThisYearLoading = false;
    });
  }

  void refreshData() {
    this._updatePageContent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Container(
              width: double.infinity,
              height: 100,
              color: Colors.deepPurple,
              child: Stack(
                children: <Widget>[
                  Container(
                    alignment: Alignment.topLeft,
                    margin: EdgeInsets.only(left: 20, top: 10),
                    child: Text(
                      'Waste',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.topRight,
                    margin: EdgeInsets.only(right: 20, top: 10),
                    child: GestureDetector(
                      onTap: () {},
                      child: Icon(
                        Icons.menu,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 50),
              decoration: Styles.containerDecoration,
              child: Column(
                children: <Widget>[
                  Container(
                    child: Stack(
                      children: <Widget>[
                        Container(
                          alignment: Alignment.topLeft,
                          margin: EdgeInsets.only(left: 10),
                          child: DropdownButton<String>(
                            value: dropdownWalletValue,
                            icon: Icon(Icons.keyboard_arrow_down),
                            iconSize: 24,
                            elevation: 16,
                            style: GoogleFonts.quicksand(
                              textStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 14,
                              ),
                            ),
                            underline: Container(
                              height: 1,
                              color: Colors.white10,
                            ),
                            onChanged: (String newValue) {
                              switchWallets(newValue);
                            },
                            items: wallets
                                .map<DropdownMenuItem<String>>((Wallet item) {
                              return DropdownMenuItem<String>(
                                value: item.id,
                                child: Text(item.name),
                              );
                            }).toList(),
                          ),
                        ),
                        isWalletOwner
                            ? Container(
                                alignment: Alignment.topRight,
                                child: FlatButton(
                                  onPressed: _goToEditWalletPage,
                                  child: Text(
                                    this.userDto.language ==
                                            Constants.languages[0]
                                        ? 'Editar'
                                        : 'Edit',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
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
                  Container(
                    alignment: Alignment.topCenter,
                    margin: EdgeInsets.only(top: 20),
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade50,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(top: 10, bottom: 5),
                          child: Text(
                            'Gastos em 2020',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 10),
                          child: totalWasteThisYearLoading
                              ? Container(
                                  width: double.infinity,
                                  alignment: Alignment.center,
                                  child: Theme(
                                    data: Theme.of(context).copyWith(
                                        accentColor: Colors.deepPurple),
                                    child: new CircularProgressIndicator(),
                                  ),
                                )
                              : Text(
                                  '-' +
                                      Constants.getAmountFormated(
                                          totalWasteThisYear),
                                  style: TextStyle(
                                    color: Colors.deepPurple,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
