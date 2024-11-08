import 'package:flutter/material.dart';
import 'joy_ui.dart';

class JoyText extends StatelessWidget {
  final String text;
  final Color textColor;
  final double size;
  final FontWeight fontWeight;
  final TextOverflow textOverflow;
  final TextAlign? textAlign;

  const JoyText(
    this.text, {
    this.textColor = Styles.primaryTextColor,
    this.size = 16,
    this.fontWeight = FontWeight.w600,
    this.textOverflow = TextOverflow.visible,
    this.textAlign = TextAlign.start,
    super.key,
  });

  factory JoyText.h1(
    String text, {
    Key? key,
    Color textColor = Styles.primaryTextColor,
    double size = 20,
    FontWeight fontWeight = FontWeight.bold,
  }) =>
      JoyText(
        text,
        textColor: textColor,
        size: size,
      );

    factory JoyText.secundaryText(
    String text, {
    Key? key,
    Color textColor = Styles.grey,
    double size = 14,
    FontWeight fontWeight = FontWeight.w500,
    TextAlign? textAlign = TextAlign.start,
    TextOverflow textOverflow = TextOverflow.ellipsis,
  }) =>
      JoyText(
        text,
        textColor: textColor,
        size: size,
        textAlign: textAlign,
        textOverflow: textOverflow,
      );

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: textColor,
        fontWeight: fontWeight,
        fontSize: size,
        overflow: textOverflow,
      ),
      textAlign: textAlign,
      softWrap: true,
    );
  }
}
