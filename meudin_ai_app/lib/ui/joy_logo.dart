import 'package:flutter/material.dart';
import 'package:meudin_ai_app/ui/app_typography.dart';
import 'package:meudin_ai_app/ui/styles.dart';

class JoyLogo extends StatelessWidget {
  const JoyLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Dark: keep full purple for most of the word, then fade only the tail
    // toward a dark purple near the background — never the background itself.
    final colors = isDark
        ? [
            Styles.primaryColor,
            Styles.primaryColor,
            Color.lerp(
              theme.scaffoldBackgroundColor,
              Styles.primaryColor,
              0.42,
            )!,
          ]
        : [
            Styles.primaryColor,
            Styles.primaryColorLight,
          ];

    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: colors,
        stops: isDark ? const [0.0, 0.72, 1.0] : null,
      ).createShader(bounds),
      child: Text(
        'Meudin',
        style: AppTypography.textStyle(
          fontSize: 40,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: -1.2,
          height: 1,
        ),
      ),
    );
  }
}
