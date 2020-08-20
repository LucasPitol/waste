import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waste_app/utils/styles.dart';

class ManageWalletsAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final BuildContext context;
  final String title;

  @override
  final Size preferredSize;

  ManageWalletsAppBar(this.context, this.title) : preferredSize = Size.fromHeight(60.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Styles.mainBackgroundColor,
      title: Text(
        this.title,
        style: GoogleFonts.poppins(
          textStyle: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black,
            fontSize: 18,
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
