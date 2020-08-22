import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waste_app/services/auth_service.dart';
import 'package:waste_app/utils/constants.dart';
import 'package:waste_app/utils/styles.dart';

class ChangeLanguageDialogComponent extends StatefulWidget {
  @override
  _ChangeLanguageDialogComponentState createState() =>
      _ChangeLanguageDialogComponentState();
}

class _ChangeLanguageDialogComponentState
    extends State<ChangeLanguageDialogComponent> {
  AuthService authService;
  String currentLanguageCode = AuthService.currentUser.language;

  _ChangeLanguageDialogComponentState() {
    this.authService = AuthService();
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => this._showDialog());
    this.authService.userExists(context);
  }

  _showDialog() {
    return showGeneralDialog(
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
                this.currentLanguageCode == Constants.languages[0]
                    ? 'Alterar idioma'
                    : 'Change language',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w400),
              ),
              content: Theme(
                data: Styles.mainTheme,
                child: Container(),
              ),
              actions: <Widget>[
                FlatButton(
                  textColor: Colors.black,
                  onPressed: () {
                    closeDialog(false);
                  },
                  child: Text(
                    this.currentLanguageCode == Constants.languages[0]
                        ? 'Cancelar'
                        : 'Cancel',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w400),
                  ),
                ),
                FlatButton(
                  textColor: Colors.deepPurple,
                  onPressed: () async {
                    closeDialog(true);
                  },
                  child: Text(
                    'Ok',
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
      pageBuilder: (context, animation1, animation2) {},
    );
  }

  closeDialog(bool action) {
    String newLanguage = 'abc';

    Navigator.pop(context, [action, newLanguage]);
    Navigator.pop(context, [action, newLanguage]);
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
