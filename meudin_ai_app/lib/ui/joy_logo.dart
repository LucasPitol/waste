import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:meudin_ai_app/ui/styles.dart';

class JoyLogo extends StatelessWidget {
  const JoyLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Meudin',
      style: GoogleFonts.lobster(
        fontSize: 28,
        color: Styles.primaryColor,
      ),
    );
  }
}
