import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waste_app/models/user_dto.dart';
import 'package:waste_app/models/wallet.dart';
import 'package:waste_app/services/auth_service.dart';
import 'package:waste_app/utils/constants.dart';
import 'package:waste_app/utils/styles.dart';

class LeaveWalletDialogComponent extends StatefulWidget {
  final Wallet wallet;

  LeaveWalletDialogComponent(this.wallet);
  @override
  _LeaveWalletDialogComponentState createState() =>
      _LeaveWalletDialogComponentState(wallet);
}

class _LeaveWalletDialogComponentState
    extends State<LeaveWalletDialogComponent> {
  UserDto userDto = AuthService.currentUser;
  Wallet wallet;
  bool isPtLanguage;

  AuthService authService;

  _LeaveWalletDialogComponentState(Wallet wallet) {
    this.isPtLanguage = userDto.language == Constants.languages[0];
    this.wallet = wallet;
    this.authService = AuthService();
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => this._showDialog());
    this.authService.userExists(context);
  }

  _showDialog() {
    String title = isPtLanguage ? 'Deixar carteira?' : 'Leave wallet?';

    String content = isPtLanguage
        ? 'Tem certeza que deseja deixar a carteira ' +
            wallet.name +
            '? Você não terá mais acesso a essa carteira.'
        : 'Are you sure you want to leave the wallet ' +
            wallet.name +
            '? You will no longer have access to that wallet.';

    return showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
          return Transform(
            transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
            child: Opacity(
              opacity: a1.value,
              child: AlertDialog(
                backgroundColor: Colors.black,
                shape: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade900),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                title: Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade100,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                content: Theme(
                  data: Styles.mainTheme,
                  child: Container(
                    child: Text(
                      content,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                actions: <Widget>[
                  FlatButton(
                    textColor: Colors.grey,
                    onPressed: () {
                      closeDialog(false);
                    },
                    child: Text(
                      isPtLanguage ? 'Cancelar' : 'Cancel',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                    ),
                  ),
                  FlatButton(
                    textColor: Colors.deepPurple,
                    onPressed: () {
                      closeDialog(true);
                    },
                    child: Text(
                      isPtLanguage ? 'Deixar carteira' : 'Leave wallet',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
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
    Navigator.pop(context, action);
    Navigator.pop(context, action);
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
