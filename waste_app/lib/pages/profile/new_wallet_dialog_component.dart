import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waste_app/utils/styles.dart';

class NewWalletDialogComponent extends StatefulWidget {
  @override
  _NewWalletDialogComponentState createState() =>
      _NewWalletDialogComponentState();
}

class _NewWalletDialogComponentState extends State<NewWalletDialogComponent> {
    TextEditingController walletNameController = TextEditingController();


  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => this._showDialog());
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
                    borderRadius: BorderRadius.circular(16.0)),
                title: Text(
                  'Nova carteira',
                  style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
                ),
                content: Theme(
                  data: Styles.mainTheme,
                  child: TextFormField(
                    cursorColor: Colors.deepPurple,
                      controller: walletNameController,
                      textCapitalization: TextCapitalization.sentences,
                      // validator: (value) {
                      //   if (value.isEmpty) {
                      //     return Constants.getDefaultEmptyFieldMsg(
                      //         userDto.language);
                      //   }
                      //   return null;
                      // },
                      decoration: Styles.getTextFieldDecorationUnderline(
                          'Nome da carteira')),
                ),
                actions: <Widget>[
                  FlatButton(
                    textColor: Colors.black,
                    onPressed: () {
                      closeDialog(false);
                    },
                    child: Text(
                      'Cancelar',
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
                    ),
                  ),
                  FlatButton(
                    textColor: Colors.deepPurple,
                    onPressed: () {
                      closeDialog(true);
                    },
                    child: Text(
                      'Criar',
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
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
