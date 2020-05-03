import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waste_app/utils/styles.dart';

class ManageWalletsAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final BuildContext context;

  @override
  final Size preferredSize;

  ManageWalletsAppBar(this.context) : preferredSize = Size.fromHeight(60.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Styles.mainBackgroundColor,
      title: Text(
        'Gerenciar carteiras',
        style: GoogleFonts.quicksand(
          textStyle: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      leading: GestureDetector(
        onTap: () {
          Navigator.pop(context, false);
        },
        child: Icon(
          Icons.keyboard_backspace,
          color: Colors.grey,
        ),
      ),
    );
  }
}
