import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Styles {
  static Color mainBackgroundColor = Colors.black;

  static ThemeData mainTheme = ThemeData(
    cursorColor: Colors.deepPurple,
    primaryColor: Colors.deepPurple,
    accentColor: Colors.deepPurple.shade900,
    textSelectionHandleColor: Colors.deepPurple,
    textTheme: GoogleFonts.poppinsTextTheme(),
    backgroundColor: mainBackgroundColor,
  );

  static TextStyle dateAndSpendStyle = TextStyle(
    color: Styles.mainBackgroundColor,
    fontWeight: FontWeight.w700,
    fontSize: 18.0,
  );

  static Color boxColor = Color(0xFFC8BDDB).withOpacity(0.1);

  static TextStyle poppinsText =
      TextStyle(color: Colors.grey.shade900, fontWeight: FontWeight.w500);

  static TextStyle poppinsTextLight =
      TextStyle(color: Colors.grey.shade100, fontWeight: FontWeight.w500);

  static TextStyle poppinsTextGrey =
      TextStyle(color: Colors.grey, fontWeight: FontWeight.w500);

  static BorderRadius defaultBorderRadius =
      BorderRadius.all(Radius.circular(20));
  static BorderRadius circularBorderRadius =
      BorderRadius.all(Radius.circular(200));

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
