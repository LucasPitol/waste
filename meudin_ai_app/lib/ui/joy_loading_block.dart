import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';

class JoyLoadingBlock extends StatelessWidget {
  final bool loading;

  const JoyLoadingBlock(this.loading, {super.key});

  @override
  Widget build(BuildContext context) {
    return loading
        ? ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(
                  color: Styles.primaryColor,
                ),
              ),
            ),
          )
        : Container();
  }
}
