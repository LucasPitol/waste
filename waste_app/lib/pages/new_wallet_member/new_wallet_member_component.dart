import 'package:waste_app/services/auth_service.dart';
import 'package:waste_app/models/user_dto.dart';
import 'package:waste_app/utils/constants.dart';
import 'package:waste_app/models/wallet.dart';
import 'package:waste_app/utils/styles.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'new_member_info_component.dart';

class NewWalletMemberComponent extends StatefulWidget {
  final Wallet currentWallet;

  NewWalletMemberComponent(this.currentWallet);

  @override
  _NewWalletMemberComponentComponenState createState() =>
      _NewWalletMemberComponentComponenState(currentWallet);
}

class _NewWalletMemberComponentComponenState
    extends State<NewWalletMemberComponent> {
  UserDto userDto = AuthService.currentUser;

  bool isPtLanguage;
  Wallet currentWallet;
  TextEditingController memberMailController;
  var _formKey;
  bool refresh = false;

  _NewWalletMemberComponentComponenState(Wallet wallet) {
    this.currentWallet = wallet;
    this.isPtLanguage = userDto.language == Constants.languages[0];
    this.memberMailController = TextEditingController();
    this._formKey = GlobalKey<FormState>();
  }

  @override
  void initState() {
    super.initState();
    this.updateAppBar();
  }

  updateAppBar() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Styles.mainBackgroundColor,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  void _infoBottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return NewMemebrInfoSheetComponent(isPtLanguage);
        });
  }

  _getOut() {
    Navigator.pop(context, refresh);
  }

  bool _isUserMail(String input) {
    return input == this.userDto.email;
  }

  _getUser() {
    print('procurou');
  }

  @override
  Widget build(BuildContext context) {
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
                        // margin: EdgeInsets.only(top: 10),
                        alignment: Alignment.topLeft,
                        child: InkWell(
                          borderRadius: Styles.circularBorderRadius,
                          onTap: () {
                            _getOut();
                          },
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.grey.shade100,
                          ),
                        ),
                      ),
                      Container(
                        // margin: EdgeInsets.only(top: 10),
                        alignment: Alignment.topRight,
                        child: InkWell(
                          borderRadius: Styles.circularBorderRadius,
                          onTap: () {
                            this._infoBottomSheet();
                          },
                          child: Icon(
                            Icons.help_outline,
                            color: Colors.grey.shade100,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 15),
                  alignment: Alignment.topLeft,
                  child: Text(
                    isPtLanguage ? 'Novo membro' : 'New member',
                    style: TextStyle(
                      color: Colors.grey.shade100,
                      fontWeight: FontWeight.w600,
                      fontSize: 21,
                    ),
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 15),
                        child: TextFormField(
                          style: TextStyle(color: Colors.grey.shade100),
                          controller: memberMailController,
                          textCapitalization: TextCapitalization.none,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value.isEmpty) {
                              return Constants.getDefaultEmptyFieldMsg(
                                  isPtLanguage);
                            }

                            if (_isUserMail(value)) {
                              return isPtLanguage
                                  ? 'Digite o email de outro usuário'
                                  : 'Enter another user\'s email';
                            }

                            return null;
                          },
                          decoration: isPtLanguage
                              ? Styles.getTextFieldDecorationUnderline(
                                  'Email do membro')
                              : Styles.getTextFieldDecorationUnderline(
                                  'Member email'),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 40, left: 20, right: 20),
                        child: ButtonTheme(
                          minWidth: double.infinity,
                          height: 50,
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: Styles.defaultTextFieldBorderRadius,
                            ),
                            onPressed: () async {
                              if (_formKey.currentState.validate()) {
                                _getUser();
                              }
                            },
                            color: Colors.deepPurple,
                            child: Text(
                              isPtLanguage ? 'Adicionar' : 'Add',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
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
        ),
      ),
    );
  }
}
