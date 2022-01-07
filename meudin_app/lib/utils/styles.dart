import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Styles {
  static bool isDarkMode = false;

  static ThemeData mainTheme = ThemeData(
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: primaryColor,
      selectionHandleColor: primaryColor,
      selectionColor: primaryColor,
    ),
    colorScheme: ColorScheme.fromSwatch(
      accentColor: darkColor,
    ),
    primaryColor: primaryColor,
    hintColor: darkColor,
    scaffoldBackgroundColor: mainBackgroundColor,
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: mainBackgroundColor,
    ),
    textTheme: GoogleFonts.montserratTextTheme(),
    // textTheme: GoogleFonts.varelaTextTheme(),
    backgroundColor: mainBackgroundColor,
  );

  static Color primaryColor = Colors.deepPurple;
  static Color darkColor = Colors.deepPurple.shade800;
  static Color mainBackgroundColor = Colors.black;
  static Color cardColor = const Color(0xff171717);

  static Color mainTextColor = Colors.grey.shade100;

  static List<Color> pieChartColorList = [
    Colors.deepPurple.shade900,
    Colors.deepPurple,
    Colors.deepPurple.shade300,
    Colors.deepPurple.shade100,
  ];

  static TextStyle montText = TextStyle(
    color: mainTextColor,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static TextStyle montTextTitle = TextStyle(
    color: mainTextColor,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static TextStyle montTextGrey = TextStyle(
    color: Colors.grey.shade600,
    fontWeight: FontWeight.w500,
    fontSize: 16,
  );

  static TextStyle montSubText = TextStyle(
    color: Colors.grey.shade600,
    fontWeight: FontWeight.w500,
    fontSize: 14,
  );

  static TextStyle textButtonTextStyle = TextStyle(
    color: primaryColor,
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );

  static TextStyle buttonTextStyle = TextStyle(
    color: mainBackgroundColor,
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );

  static BorderRadius defaultBorderRadius = BorderRadius.circular(8.0);

  static BorderRadius circularBorderRadius = BorderRadius.circular(200.0);

  static BoxDecoration cardDecoration = BoxDecoration(
    color: cardColor,
    borderRadius: const BorderRadius.all(Radius.circular(10)),
  );

  static BoxDecoration cardDecoration2 = BoxDecoration(
    color: primaryColor.withOpacity(.10),
    borderRadius: const BorderRadius.all(Radius.circular(10)),
  );

  static ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
    shape: RoundedRectangleBorder(
      borderRadius: defaultBorderRadius,
    ),
    primary: Styles.primaryColor,
  );

  static getAppLogo() {
    return Text(
      'Meudin',
      style: GoogleFonts.lobster(
        fontSize: 28,
        color: primaryColor,
      ),
    );
  }

  static getTextFieldDecorationUnderline(String value) {
    return InputDecoration(
      border: const UnderlineInputBorder(),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade600),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: primaryColor),
      ),
      labelText: value,
      labelStyle: const TextStyle(color: Colors.grey),
    );
  }
}
