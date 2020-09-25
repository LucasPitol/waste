import 'package:package_info/package_info.dart';
import 'package:waste_app/models/dtos/profile_dto.dart';
import 'package:waste_app/pages/dialogs/alert_dialog_component.dart';
import 'package:waste_app/pages/profile/new_wallet_dialog_component.dart';
import 'package:waste_app/pages/manage_wallets/edit_wallet.dart';
import 'package:waste_app/pages/profile/drawer_menu_item.dart';
import 'package:waste_app/pages/profile/pire_chart_profile.dart';
import 'package:waste_app/pages/shared/loading_block.dart';
import 'package:waste_app/services/spends_service.dart';
import 'package:waste_app/services/wallet_service.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:waste_app/services/auth_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waste_app/utils/constants.dart';
import 'package:waste_app/models/user_dto.dart';
import 'package:waste_app/models/wallet.dart';
import 'package:waste_app/utils/styles.dart';
import 'package:flutter/material.dart';

import 'change_language_dialog_component.dart';

class ProfileComponent extends StatefulWidget {
  ProfileComponent({Key key}) : super(key: key);
  @override
  ProfileComponentState createState() => ProfileComponentState();
}

class ProfileComponentState extends State<ProfileComponent> {
  UserDto userDto = AuthService.currentUser;
  String languageCode;
  bool totalWasteThisYearLoading = true;
  bool isWalletOwner = false;
  bool loading = false;
  String appVersion = '1.0.4';
  DateTime startDate = null;
  DateTime endDate = null;
  ProfileDto profileDto;
  var scaffoldKey = GlobalKey<ScaffoldState>();

  SpendsService spendService;
  WalletService walletService;
  AuthService authService;

  ProfileComponentState() {
    this.languageCode = this.userDto.language;
    this.spendService = SpendsService();
    this.walletService = WalletService();
    this.authService = AuthService();
    this.profileDto = ProfileDto();
    this.getAppVersion();
  }

  Future<void> getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    if (packageInfo.version != '1.0.0') {
      this.appVersion = packageInfo.version;
    }
  }

  List<Wallet> wallets;

  String dropdownWalletValue;

  void initState() {
    super.initState();
    this.authService.userExists(context);
    this._getUserWallets();
    this._updatePermission();
    this._getTotalProfileData();
  }

  bool isEndDrawerOpen() {
    return (scaffoldKey.currentState.isEndDrawerOpen);
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

    this._getTotalProfileData();
    this._updatePermission();
  }

  void _goToEditWalletPage() async {
    String walletId = this.userDto.currentWalletId;
    var refresh = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => EditWallet(walletId)));

    if (refresh != null && refresh) {
      _updatePageContent();
    }
  }

  Future<void> _changeLanguage() async {
    List res = await _openChangeLanguageDialod();

    if (res != null && res.isNotEmpty && res[0]) {
      Navigator.pop(context);

      setState(() {
        this.languageCode = res[1];
      });
    }
  }

  Future<List> _openChangeLanguageDialod() async {
    return await showDialog<List>(
        context: context,
        builder: (builder) {
          return ChangeLanguageDialogComponent();
        });
  }

  Future<void> _createNewWallet() async {
    List res = await _openNewWalletDialog();

    if (res != null && res.isNotEmpty && res[0]) {
      Navigator.pop(context);

      setState(() {
        this.loading = true;
      });

      var refresh = await this.walletService.createNewWallet(res[1]);

      setState(() {
        this.loading = false;
      });

      if (refresh) {
        _updatePageContent();
      }
    }
  }

  Future<List> _openNewWalletDialog() async {
    return await showDialog<List>(
        context: context,
        builder: (builder) {
          return NewWalletDialogComponent();
        });
  }

  void _updatePermission() {
    String walletId = this.userDto.currentWalletId;
    String uid = this.userDto.uid;
    setState(() {
      this.isWalletOwner = this.walletService.isOwner(walletId, uid);
    });
  }

  _updatePageContent() {
    this._getUserWallets();
    this._updatePermission();
    this._getTotalProfileData();
  }

  Future<void> _getTotalProfileData() async {
    setState(() {
      totalWasteThisYearLoading = true;
    });

    ProfileDto profileDtoTemp =
        await this.spendService.getProfileData(this.startDate, this.endDate);

    this.profileDto = profileDtoTemp;

    setState(() {
      this.totalWasteThisYearLoading = false;
    });
  }

  void refreshData() {
    this._updatePageContent();
  }

  void _openAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Waste',
      applicationVersion: this.appVersion,
      applicationIcon: Container(
        child: Image.asset(
          'assets/images/ic_launcher_circle.png',
          width: 50,
        ),
      ),
      children: [
        Container(
          child: Text(
            this.languageCode == Constants.languages[0]
                ? 'Seu parceiro Waste te ajuda a desperdiçar menos seu suado dinheiro'
                : 'Your partner Waste helps you waste less of your hard-earned money',
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ),
      ],
    );
  }

  void _logout() {
    this.authService.signOut();
    Phoenix.rebirth(context);
  }

  Future<void> _openInfoDialog(String title, String content) async {
    await showDialog<String>(
        context: context,
        builder: (builder) {
          return AlertDialogComponent(title, content);
        });
  }

  _sendChangePasswordEmail() async {
    String userMail = AuthService.currentUser.email;

    this.authService.sendResetPasswordEmail(userMail);

    String text = this.languageCode == Constants.languages[0]
        ? 'Enviamos um link para escolher uma nova senha'
        : 'We sent a link to recover your password';

    String title = this.languageCode == Constants.languages[0]
        ? 'Verifique seu email'
        : 'Check your email';

    await _openInfoDialog(title, text);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomPadding: true,
      endDrawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: <Widget>[
              Container(
                color: Colors.deepPurple,
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 10, right: 20),
                      alignment: Alignment.topRight,
                      child: Icon(
                        Icons.account_circle,
                        color: Colors.deepPurple.shade300,
                        size: 40,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10, right: 20, bottom: 10),
                      alignment: Alignment.topRight,
                      child: Text(
                        this.userDto.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _createNewWallet,
                child: DrawerMenuItem(
                    this.languageCode == Constants.languages[0]
                        ? 'Nova carteira'
                        : 'New wallet',
                    Icons.account_balance_wallet),
              ),
              GestureDetector(
                onTap: _sendChangePasswordEmail,
                child: DrawerMenuItem(
                    this.languageCode == Constants.languages[0]
                        ? 'Alterar senha'
                        : 'Change password',
                    Icons.lock_outline),
              ),
              GestureDetector(
                onTap: _changeLanguage,
                child: DrawerMenuItem(
                    this.languageCode == Constants.languages[0]
                        ? 'Idioma'
                        : 'language',
                    Icons.language),
              ),
              GestureDetector(
                onTap: _openAboutDialog,
                child: DrawerMenuItem(
                    this.languageCode == Constants.languages[0]
                        ? 'Sobre'
                        : 'About',
                    Icons.info_outline),
              ),
              GestureDetector(
                onTap: _logout,
                child: DrawerMenuItem(
                    this.languageCode == Constants.languages[0]
                        ? 'Sair'
                        : 'Logout',
                    Icons.exit_to_app),
              ),
            ],
          ),
        ),
      ),
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
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.topRight,
                    margin: EdgeInsets.only(right: 20, top: 10),
                    child: GestureDetector(
                      onTap: () {
                        scaffoldKey.currentState.openEndDrawer();
                      },
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        margin: EdgeInsets.only(left: 20),
                        child: DropdownButton<String>(
                          value: dropdownWalletValue,
                          icon: Icon(Icons.keyboard_arrow_down),
                          iconSize: 24,
                          elevation: 16,
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontWeight: FontWeight.w500,
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
                                  this.languageCode == Constants.languages[0]
                                      ? 'Editar'
                                      : 'Edit',
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
                  Container(
                    child: Container(
                      child: totalWasteThisYearLoading
                          ? Container(
                              width: double.infinity,
                              alignment: Alignment.center,
                              child: Theme(
                                data: Theme.of(context)
                                    .copyWith(accentColor: Colors.deepPurple),
                                child: new CircularProgressIndicator(),
                              ),
                            )
                          : Text(
                              '-' +
                                  Constants.getAmountFormated(
                                      this.profileDto.totalWaste),
                              style: TextStyle(
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                              ),
                            ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: totalWasteThisYearLoading
                        ? Container(
                            width: double.infinity,
                            alignment: Alignment.center,
                            child: Theme(
                              data: Theme.of(context)
                                  .copyWith(accentColor: Colors.deepPurple),
                              child: new CircularProgressIndicator(),
                            ),
                          )
                        : PieChartProfileComponent(
                            profileDto.spendsByCategoryMap),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          width: 45,
                          height: 45,
                        ),
                        Text(
                          '01/01/2020',
                          style: Styles.poppinsText,
                        ),
                        Text(
                          'até',
                          style: Styles.poppinsTextGrey,
                        ),
                        Text(
                          '20/08/2020',
                          style: Styles.poppinsText,
                        ),
                        Container(
                          width: 45,
                          height: 45,
                          decoration: Styles.circleBox,
                          child: Material(
                            borderRadius: Styles.circularBorderRadius,
                            child: InkWell(
                              onTap: () {},
                              borderRadius: Styles.circularBorderRadius,
                              child: Icon(
                                Icons.calendar_today,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            LoadingBlock(loading),
          ],
        ),
      ),
    );
  }
}
