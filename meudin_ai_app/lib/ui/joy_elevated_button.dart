import 'package:flutter/material.dart';

import 'joy_ui.dart';

class JoyElevatedButton extends StatelessWidget {
  final String text;
  final function;
  final Color backgroundColor;
  final Color textColor;

  const JoyElevatedButton({
    required this.text,
    required this.function,
    this.backgroundColor = Styles.primaryTextColor,
    this.textColor = Styles.whiteColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      // width: isMobile ? double.infinity : 400,
      height: 50,
      child: ElevatedButton(
        onPressed: () => function(),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: Styles.rectangularBorderRadius,
          ),
        ),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
