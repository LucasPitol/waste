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
    final theme = Theme.of(context);
    // Se textColor não foi especificado ou é a cor padrão hardcoded, usa a cor do tema
    // Mas mantém cinza escurecido no tema claro para subtítulos
    final effectiveColor = textColor == Styles.primaryTextColor 
        ? theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor
        : (textColor == Styles.grey 
            ? (theme.brightness == Brightness.dark 
                ? theme.textTheme.bodyMedium?.color ?? Styles.grey
                : Colors.grey.shade600) // Cinza mais escuro no tema claro
            : textColor);
    
    return Text(
      text,
      style: TextStyle(
        color: effectiveColor,
        fontWeight: fontWeight,
        fontSize: size,
        overflow: textOverflow,
      ),
      textAlign: textAlign,
      softWrap: true,
    );
  }
}
