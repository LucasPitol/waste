import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTypography {
  static bool get _useIosSystemFont =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  static TextTheme textTheme(TextTheme base) {
    if (_useIosSystemFont) {
      return base;
    }
    return GoogleFonts.interTextTheme(base);
  }

  static TextStyle textStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    final style = TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );

    if (_useIosSystemFont) {
      return style;
    }

    return GoogleFonts.inter(textStyle: style);
  }
}
