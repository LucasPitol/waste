import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';

class ConfirmDialogComponent extends StatefulWidget {
  final String title;
  final String subtitle;

  ConfirmDialogComponent(this.title, this.subtitle);

  @override
  _ConfirmDialogComponentState createState() =>
      _ConfirmDialogComponentState(title, subtitle);
}

class _ConfirmDialogComponentState extends State<ConfirmDialogComponent> {
  final String title;
  final String subtitle;

  _ConfirmDialogComponentState(this.title, this.subtitle);

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
                backgroundColor: Colors.black,
                shape: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade900),
                    borderRadius: BorderRadius.circular(16.0)),
                title: Text(
                  this.title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade100,
                  ),
                ),
                content: Text(
                  this.subtitle,
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
                actions: <Widget>[
                  FlatButton(
                    textColor: Colors.deepPurple,
                    onPressed: () {
                      closeDialog(false);
                    },
                    child: Text(
                      'Cancelar',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                    ),
                  ),
                  FlatButton(
                    textColor: Colors.red,
                    onPressed: () {
                      closeDialog(true);
                    },
                    child: Text(
                      'Excluir',
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
