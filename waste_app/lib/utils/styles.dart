import 'package:flutter/material.dart';

class Styles {
  static Color mainBackgroundColor = Colors.grey.shade50;

  static ThemeData mainTheme = ThemeData(
    cursorColor: Colors.deepPurple,
    primaryColor: Colors.deepPurple,
    textSelectionHandleColor: Colors.deepPurple,
  );

  static TextStyle datehAndSpendStyle = TextStyle(
    color: Colors.deepPurple.shade50,
    fontWeight: FontWeight.w400,
    fontSize: 18.0,
  );

  static BoxDecoration loginBox = BoxDecoration(
    color: mainBackgroundColor,
    borderRadius: BorderRadius.all(Radius.circular(20)),
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

  static getTextFieldDecoration(String value) {
    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: defaultTextFieldBorderRadius,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: defaultTextFieldBorderRadius,
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      labelText: value,
    );
  }
}
