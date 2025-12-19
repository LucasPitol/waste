import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Styles {
  static const Color primaryColor = Color(0xffAC6CFF);
  static const Color primaryColorLight = Color.fromARGB(255, 214, 183, 255);
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
    scaffoldBackgroundColor: whiteConfortColor,
    textTheme: GoogleFonts.montserratTextTheme(),
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      surface: whiteColor,
      onSurface: primaryTextColor,
      onPrimary: whiteColor,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: whiteColor,
      selectionColor: primaryColor.withOpacity(0.3),
      selectionHandleColor: primaryColor,
    ),
    primaryColor: primaryColor,
    scaffoldBackgroundColor: const Color(0xFF121212),
    textTheme: GoogleFonts.montserratTextTheme(
      ThemeData.dark().textTheme.copyWith(
        bodyLarge: const TextStyle(color: Colors.white),
        bodyMedium: const TextStyle(color: Colors.white70),
        bodySmall: const TextStyle(color: Colors.white60),
        titleLarge: const TextStyle(color: Colors.white),
        titleMedium: const TextStyle(color: Colors.white),
        titleSmall: const TextStyle(color: Colors.white),
      ),
    ),
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      surface: Color(0xFF1E1E1E),
      onSurface: whiteColor,
      onPrimary: whiteColor,
    ),
  );

  static BoxDecoration cardDecoration = BoxDecoration(
    color: whiteColor,
    boxShadow: [
      BoxShadow(
        color: greyLighter,
        offset: Offset(0, 2),
        blurRadius: 2,
      ),
    ],
    borderRadius: const BorderRadius.all(Radius.circular(10)),
  );

  static BorderRadius sexyBorderRadius =
      const BorderRadius.all(Radius.circular(16.0));

  static BorderRadius rectangularBorderRadius =
      const BorderRadius.all(Radius.circular(5.0));
}
