import 'package:flutter/material.dart';
import 'package:meudin_ai_app/ui/app_typography.dart';
import 'package:meudin_ai_app/ui/styles.dart';

class JoyLogo extends StatelessWidget {
  const JoyLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark
        ? const [
            Color(0xFFC084FC),
            Color(0xFFF5EEFF),
          ]
        : [
            Styles.primaryColor,
            Styles.primaryColorLight,
          ];

    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => LinearGradient(
        colors: colors,
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
