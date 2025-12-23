import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:meudin_ai_app/ui/styles.dart';

class JoyLogo extends StatelessWidget {
  const JoyLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [
          Styles.primaryColor,
          Styles.primaryColorLight,
        ],
      ).createShader(bounds),
      child: Text(
        'Meudin',
        style: GoogleFonts.inter(
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
