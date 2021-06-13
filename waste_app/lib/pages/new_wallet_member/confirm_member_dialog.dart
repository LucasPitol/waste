import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waste_app/utils/styles.dart';

class ConfirmMemberDialogComponent extends StatefulWidget {
  final String title;
  final String subtitle;
  final String cancelOption;
  final String confirmOption;

  ConfirmMemberDialogComponent(
      this.title, this.subtitle, this.cancelOption, this.confirmOption);

  @override
  _ConfirmMemberDialogComponentState createState() =>
      _ConfirmMemberDialogComponentState(
          title, subtitle, cancelOption, confirmOption);
}

class _ConfirmMemberDialogComponentState
    extends State<ConfirmMemberDialogComponent> {
  final String title;
  final String subtitle;
  final String cancelOption;
  final String confirmOption;

  _ConfirmMemberDialogComponentState(
      this.title, this.subtitle, this.cancelOption, this.confirmOption);

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
                  TextButton(
                    style: TextButton.styleFrom(
                      primary: Colors.grey.shade100,
                    ),
                    onPressed: () {
                      closeDialog(false);
                    },
                    child: Text(
                      this.cancelOption,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                    ),
                  ),
                  TextButton(
                    style: Styles.textButtonStyle,
                    onPressed: () {
                      closeDialog(true);
                    },
                    child: Text(
                      this.confirmOption,
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
