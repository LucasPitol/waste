import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info/package_info.dart';
import 'package:waste_app/models/dtos/language_and_code_dto.dart';
import 'package:waste_app/models/user_dto.dart';
import 'package:waste_app/pages/dialogs/alert_dialog_component.dart';
import 'package:waste_app/pages/profile/new_wallet_dialog_component.dart';
import 'package:waste_app/pages/shared/menu_item.dart';
import 'package:waste_app/services/auth_service.dart';
import 'package:waste_app/services/wallet_service.dart';
import 'package:waste_app/utils/constants.dart';
import 'package:waste_app/utils/styles.dart';

import 'change_password_component.dart';

class SettingsComponent extends StatefulWidget {
  @override
  _SettingsComponentState createState() => _SettingsComponentState();
}

class _SettingsComponentState extends State<SettingsComponent> {
  UserDto userDto = AuthService.currentUser;
  AuthService authService;
  WalletService walletService;

  bool isPtLanguage;
  bool hasChanges = false;
  String dropdownLanguageValue;
  List<LanguageAndCodeDto> options;
  String currentLanguageCode = AuthService.currentUser.language;
  String appVersion = '2.0.0';

  _SettingsComponentState() {
    this.isPtLanguage = userDto.language == Constants.languages[0];
    this.authService = AuthService();
    this.walletService = WalletService();
    this.options = <LanguageAndCodeDto>[];
    this.setOptions();
    this.getAppVersion();
  }

  Future<void> getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    if (packageInfo.version != '1.0.0') {
      this.appVersion = packageInfo.version;
    }
  }

  setOptions() {
    this.dropdownLanguageValue = currentLanguageCode;

    String autoCode = 'auto';
    this.options.add(LanguageAndCodeDto('Auto', autoCode));

    String enCode = Constants.languages[1];
    this.options.add(LanguageAndCodeDto('English', enCode));

    String ptCode = Constants.languages[0];
    this.options.add(LanguageAndCodeDto('Português', ptCode));
  }

  void switchLanguage(String languageCode) {
    setState(() {
      this.dropdownLanguageValue = languageCode;
    });

    this.authService.changeLanguage(languageCode);

    userDto = AuthService.currentUser;

    this.hasChanges = true;

    setState(() {
      this.isPtLanguage = userDto.language == Constants.languages[0];
    });
  }

  _getOut() {
    Navigator.pop(context, hasChanges);
  }

  void _logout() {
    this.authService.signOut();
    Phoenix.rebirth(context);
  }

  void _openAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Meudin',
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
            isPtLanguage
                ? 'Seu parceiro Meudin te ajuda a desperdiçar menos seu suado dinheiro'
                : 'Your partner Meudin helps you waste less of your hard-earned money',
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ),
      ],
    );
  }

  Future<void> _createNewWallet() async {
    int walletLimit = Constants.numberOfWalletsLimit;
    int walletsOwnedCount = this.walletService.getNumberOfWalletsOwned();

    if (walletsOwnedCount >= walletLimit) {
      String title = 'Ops...';
      String content = isPtLanguage
          ? 'Limite de carteiras excedido, em breve o limite será estendido'
          : 'Wallet limit exceeded, the limit will soon be extended';

      _openInfoDialog(title, content);
    } else {
      List res = await _openNewWalletDialog();

      if (res != null && res.isNotEmpty && res[0]) {
        var refresh = await this.walletService.createNewWallet(res[1]);

        this.hasChanges = true;
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

  _goToChangePasswordPage() async {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => ChangePasswordComponent()));
  }

  Future<void> _openInfoDialog(String title, String content) async {
    await showDialog<String>(
        context: context,
        builder: (builder) {
          return AlertDialogComponent(title, content);
        });
  }

  _getAppBar() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Text(
              isPtLanguage ? 'Ajustes' : 'Settings',
              style: TextStyle(
                color: Colors.grey.shade100,
                fontWeight: FontWeight.w600,
                fontSize: 24,
              ),
            ),
          ),
          Container(
            child: InkWell(
              borderRadius: Styles.circularBorderRadius,
              onTap: () {
                _getOut();
              },
              child: Container(
                padding: EdgeInsets.all(5),
                child: FaIcon(
                  FontAwesomeIcons.times,
                  size: 22,
                  color: Colors.grey.shade100,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Styles.mainBackgroundColor,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: Styles.mainBackgroundColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                _getAppBar(),
                Container(
                  margin: EdgeInsets.only(top: 20),
                  child: InkWell(
                    borderRadius: Styles.defaultBorderRadius,
                    // splashColor: Styles.brightColor,
                    child: MenuItem(
                        FontAwesomeIcons.wallet,
                        isPtLanguage
                            ? 'Adicionar nova carteira'
                            : 'Add new wallet'),
                    onTap: () {
                      _createNewWallet();
                    },
                  ),
                ),
                Divider(),
                Container(
                  child: InkWell(
                    borderRadius: Styles.defaultBorderRadius,
                    child: MenuItem(
                      FontAwesomeIcons.lock,
                      isPtLanguage ? 'Alterar senha' : 'Change password',
                    ),
                    onTap: () {
                      _goToChangePasswordPage();
                    },
                  ),
                ),
                Container(
                  height: 40,
                  margin: EdgeInsets.only(top: 10, left: 20, right: 20),
                  child: Container(
                    child: Stack(
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          child: FaIcon(
                            FontAwesomeIcons.language,
                            size: 22,
                            color: Colors.deepPurple,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 40),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            isPtLanguage ? 'Idioma' : 'Language',
                            style: Styles.poppinsText,
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          child: DropdownButton<String>(
                            value: dropdownLanguageValue,
                            icon: Icon(Icons.keyboard_arrow_down),
                            iconSize: 24,
                            elevation: 16,
                            dropdownColor: Colors.black,
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade100,
                                fontSize: 14,
                              ),
                            ),
                            underline: Container(
                              height: 1,
                              color: Colors.black,
                            ),
                            onChanged: (String newValue) {
                              switchLanguage(newValue);
                            },
                            items: options.map<DropdownMenuItem<String>>(
                                (LanguageAndCodeDto item) {
                              return DropdownMenuItem<String>(
                                value: item.code,
                                child: Text(item.displayName),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(),
                Container(
                  child: InkWell(
                    borderRadius: Styles.defaultBorderRadius,
                    child: MenuItem(
                      FontAwesomeIcons.infoCircle,
                      isPtLanguage ? 'Sobre' : 'About',
                    ),
                    onTap: () {
                      _openAboutDialog();
                    },
                  ),
                ),
                Divider(),
                Container(
                  child: InkWell(
                    borderRadius: Styles.defaultBorderRadius,
                    child: MenuItem(
                      FontAwesomeIcons.signOutAlt,
                      isPtLanguage ? 'Sair' : 'Logout',
                    ),
                    onTap: () {
                      _logout();
                    },
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
