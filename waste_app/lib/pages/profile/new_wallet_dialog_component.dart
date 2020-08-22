import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waste_app/models/user_dto.dart';
import 'package:waste_app/models/wallet.dart';
import 'package:waste_app/services/auth_service.dart';
import 'package:waste_app/utils/constants.dart';
import 'package:waste_app/utils/styles.dart';

class NewWalletDialogComponent extends StatefulWidget {
  @override
  _NewWalletDialogComponentState createState() =>
      _NewWalletDialogComponentState();
}

class _NewWalletDialogComponentState extends State<NewWalletDialogComponent> {
  TextEditingController walletNameController = TextEditingController();
  AuthService authService;
  UserDto userDto = AuthService.currentUser;
  String languageCode;
  List<Wallet> wallets;
  var _formKey;

  _NewWalletDialogComponentState() {
    this.languageCode = this.userDto.language;
    this.authService = AuthService();
    wallets = userDto.walletList;
    this._formKey = GlobalKey<FormState>();
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => this._showDialog());
    this.authService.userExists(context);
  }

  bool _isRepeated(String input) {
    Iterable<Wallet> containsList = wallets.where((w) => w.name == input);

    return containsList.isNotEmpty;
  }

  _showDialog() {
    return showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
          return Transform(
            transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
            child: Opacity(
              opacity: a1.value,
              child: AlertDialog(
                shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                title: Text(
                  this.languageCode == Constants.languages[0]
                      ? 'Nova carteira'
                      : 'New wallet',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w400),
                ),
                content: Theme(
                  data: Styles.mainTheme,
                  child: Form(
                    key: _formKey,
                    child: TextFormField(
                      cursorColor: Colors.deepPurple,
                      controller: walletNameController,
                      textCapitalization: TextCapitalization.sentences,
                      validator: (value) {
                        if (value.isEmpty) {
                          return Constants.getDefaultEmptyFieldMsg(
                              userDto.language);
                        }

                        if (_isRepeated(value)) {
                          return this.languageCode == Constants.languages[0]
                              ? 'Já tem uma carteira com esse nome'
                              : 'You already have a wallet with this name';
                        }
                        return null;
                      },
                      decoration: Styles.getTextFieldDecorationUnderline(
                          this.languageCode == Constants.languages[0]
                              ? 'Nome da carteira'
                              : 'Wallet name'),
                    ),
                  ),
                ),
                actions: <Widget>[
                  FlatButton(
                    textColor: Colors.black,
                    onPressed: () {
                      closeDialog(false);
                    },
                    child: Text(
                      this.languageCode == Constants.languages[0]
                          ? 'Cancelar'
                          : 'Cancel',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w400),
                    ),
                  ),
                  FlatButton(
                    textColor: Colors.deepPurple,
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        closeDialog(true);
                      }
                    },
                    child: Text(
                      this.languageCode == Constants.languages[0]
                          ? 'Criar'
                          : 'Create',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w400),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 200),
        barrierDismissible: false,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {});
  }

  closeDialog(bool action) {
    String walletName = walletNameController.text;

    Navigator.pop(context, [action, walletName]);
    Navigator.pop(context, [action, walletName]);
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
