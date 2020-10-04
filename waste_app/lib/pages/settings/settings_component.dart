import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waste_app/models/dtos/language_and_code_dto.dart';
import 'package:waste_app/models/user_dto.dart';
import 'package:waste_app/pages/profile/new_wallet_dialog_component.dart';
import 'package:waste_app/services/auth_service.dart';
import 'package:waste_app/services/wallet_service.dart';
import 'package:waste_app/utils/constants.dart';
import 'package:waste_app/utils/styles.dart';

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

  _SettingsComponentState() {
    this.isPtLanguage = userDto.language == Constants.languages[0];
    this.authService = AuthService();
    this.walletService = WalletService();
    this.options = List<LanguageAndCodeDto>();
    this.setOptions();
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

  TextStyle settingsItemStyle = TextStyle(
    color: Colors.grey.shade100,
    fontWeight: FontWeight.w500,
  );

  _getOut() {
    Navigator.pop(context, hasChanges);
  }

  Future<void> _createNewWallet() async {
    List res = await _openNewWalletDialog();

    if (res != null && res.isNotEmpty && res[0]) {

      var refresh = await this.walletService.createNewWallet(res[1]);

      this.hasChanges = true;
    }
  }

  Future<List> _openNewWalletDialog() async {
    return await showDialog<List>(
        context: context,
        builder: (builder) {
          return NewWalletDialogComponent();
        });
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
                      Container(
                        alignment: Alignment.topLeft,
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
                        margin: EdgeInsets.only(top: 10),
                        alignment: Alignment.topRight,
                        child: InkWell(
                          borderRadius: Styles.circularBorderRadius,
                          onTap: () {
                            _getOut();
                          },
                          child: Icon(
                            Icons.close,
                            color: Colors.grey.shade100,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 50,
                  margin: EdgeInsets.only(top: 40),
                  child: InkWell(
                    onTap: () {
                      _createNewWallet();
                    },
                    child: Stack(
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Icon(
                            Icons.account_balance_wallet,
                            color: Colors.deepPurple,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 40),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            isPtLanguage ? 'Nova carteira' : 'New wallet',
                            style: settingsItemStyle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 50,
                  margin: EdgeInsets.only(top: 10),
                  child: InkWell(
                    onTap: () {
                      print('Change password');
                    },
                    child: Stack(
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Icon(
                            Icons.lock_outline,
                            color: Colors.deepPurple,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 40),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            isPtLanguage ? 'Alterar senha' : 'Change password',
                            style: settingsItemStyle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 50,
                  margin: EdgeInsets.only(top: 10),
                  child: Container(
                    child: Stack(
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Icon(
                            Icons.language,
                            color: Colors.deepPurple,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 40),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            isPtLanguage ? 'Idioma' : 'Language',
                            style: settingsItemStyle,
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
                Container(
                  height: 50,
                  margin: EdgeInsets.only(top: 10),
                  child: InkWell(
                    onTap: () {
                      print('About');
                    },
                    child: Stack(
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Icon(
                            Icons.info_outline,
                            color: Colors.deepPurple,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 40),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            isPtLanguage ? 'Sobre' : 'About',
                            style: settingsItemStyle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 50,
                  margin: EdgeInsets.only(top: 10),
                  child: InkWell(
                    onTap: () {
                      print('Logout');
                    },
                    child: Stack(
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Icon(
                            Icons.exit_to_app,
                            color: Colors.deepPurple,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 40),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            isPtLanguage ? 'Sair' : 'Logout',
                            style: settingsItemStyle,
                          ),
                        ),
                      ],
                    ),
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
