import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Styles {
  static Color mainBackgroundColor = Colors.black;

  static ThemeData mainTheme = ThemeData(
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: primaryColor,
      selectionHandleColor: primaryColor,
      selectionColor: primaryColor,
    ),
    primaryColor: primaryColor,
    accentColor: darkColor,
    textTheme: GoogleFonts.montserratTextTheme(),
    backgroundColor: mainBackgroundColor,
  );

  static TextStyle dateAndSpendStyle = TextStyle(
    color: Styles.mainBackgroundColor,
    fontWeight: FontWeight.w700,
    fontSize: 18.0,
  );

  static Color primaryColor = Colors.deepPurple;
  static Color secondaryColor = Colors.deepPurple.shade300;
  static Color darkColor = Colors.deepPurple.shade700;

  static Color boxColor = Color(0xFF171717);

  static TextStyle poppinsText = TextStyle(
      color: Colors.grey.shade100, fontWeight: FontWeight.w500, fontSize: 16);

  static TextStyle poppinsTextLight =
      TextStyle(color: Colors.grey.shade100, fontWeight: FontWeight.w500);

  static TextStyle poppinsTextGrey =
      TextStyle(color: Colors.grey, fontWeight: FontWeight.w500);

  static BorderRadius defaultBorderRadius =
      BorderRadius.all(Radius.circular(20));
  static BorderRadius circularBorderRadius =
      BorderRadius.all(Radius.circular(200));

  static BoxDecoration contentBox = BoxDecoration(
    color: boxColor,
    borderRadius: defaultBorderRadius,
  );

  static BoxDecoration contentBox2 = BoxDecoration(
    color: boxColor,
    borderRadius: BorderRadius.all(Radius.circular(12)),
  );

  static BoxDecoration loginBox = BoxDecoration(
    color: mainBackgroundColor,
    borderRadius: defaultBorderRadius,
    // boxShadow: [
    //   BoxShadow(
    //     color: Colors.grey.shade400,
    //     offset: Offset(0, 0),
    //     blurRadius: 2,
    //   ),
    // ],
  );

  static BoxDecoration spendCard = BoxDecoration(
      color: mainBackgroundColor,
      borderRadius: defaultBorderRadius,
      border: Border.all(color: Colors.grey.shade900)
      // boxShadow: [
      //   BoxShadow(
      //     color: Colors.grey.shade400,
      //     offset: Offset(0, 0),
      //     blurRadius: 2,
      //   ),
      // ],
      );

  static BoxDecoration circleBox = BoxDecoration(
    color: mainBackgroundColor,
    shape: BoxShape.circle,
    boxShadow: [
      BoxShadow(
        color: Colors.grey.shade400,
        offset: Offset(0, 0),
        blurRadius: 2,
      ),
    ],
  );

  static BorderRadius defaultTextFieldBorderRadius =
      BorderRadius.all(Radius.circular(50.0));

  static BoxDecoration containerDecoration = BoxDecoration(
    color: Styles.mainBackgroundColor,
    borderRadius: defaultBorderRadius,
  );

  static ThemeData calendarThemeData = ThemeData.dark().copyWith(
    primaryColor: Colors.deepPurple,
    accentColor: Colors.deepPurple.shade900,
    colorScheme: ColorScheme.dark(
      primary: Colors.deepPurple,
      background: mainBackgroundColor,
    ),
    buttonTheme: ButtonThemeData(
      textTheme: ButtonTextTheme.primary,
    ),
  );

  static getTextFieldDecoration(String value) {
    return InputDecoration(
        border: OutlineInputBorder(
          borderRadius: defaultTextFieldBorderRadius,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: defaultTextFieldBorderRadius,
          borderSide: BorderSide(color: Colors.grey.shade900),
        ),
        labelText: value,
        labelStyle: TextStyle(color: Colors.grey));
  }

  static getTextFieldDecorationUnderline(String value) {
    return InputDecoration(
      border: UnderlineInputBorder(),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade900),
      ),
      labelText: value,
      labelStyle: TextStyle(color: Colors.grey),
    );
  }
}
