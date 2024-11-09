import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Styles {
  static const Color primaryColor = Color(0xffAC6CFF);
  static const Color primaryTextColor = Color(0xff212121);
  static const Color selectionTextColor = Color(0xFFE1F5FE);
  static const Color whiteColor = Colors.white;
  static const Color whiteConfortColor = Color(0xfffafafa);
  static const Color grey = Color(0xFFBDBDBD);
  static Color greyLighter = Colors.grey.shade200;
  static const Color greyDarker = Colors.grey;

  static ThemeData mainTheme = ThemeData(
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: primaryTextColor,
      selectionColor: selectionTextColor,
      selectionHandleColor: primaryTextColor,
    ),
    primaryColor: primaryColor,
    scaffoldBackgroundColor: whiteColor,
    textTheme: GoogleFonts.montserratTextTheme(),
    // colorSchemeSeed: primaryColor,
  );

  static BoxDecoration cardDecoration = BoxDecoration(
    color: whiteColor,
    boxShadow: [
      BoxShadow(
        color:  greyLighter,
        offset: Offset(0, 2),
        blurRadius: 2,
      ),
    ],
    borderRadius: const BorderRadius.all(Radius.circular(10)),
  );
}
