import 'package:flutter/material.dart';

import 'joy_ui.dart';

class JoyTextButton extends StatelessWidget {
  final String text;
  final function;
  final Color textColor;
  final Color splashColor;
  final double fontSize;

  const JoyTextButton({
    required this.text,
    required this.function,
    this.textColor = Styles.primaryColor,
    this.fontSize = 14,
    this.splashColor = Styles.primaryColorLight,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => function(),
      style: ButtonStyle(
        overlayColor: WidgetStateColor.resolveWith((states) => splashColor),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
