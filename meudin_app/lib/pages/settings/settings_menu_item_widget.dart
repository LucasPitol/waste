import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meudin_app/utils/styles.dart';

class SettingsMenuItemWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final Function handlerFunction;

  SettingsMenuItemWidget(
      {required this.icon, required this.label, required this.handlerFunction});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await handlerFunction();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            FaIcon(
              icon,
              size: 20,
              color: Styles.mainTextColor,
            ),
            const SizedBox(
              width: 20,
            ),
            Text(
              label,
              style: Styles.montText,
            ),
          ],
        ),
      ),
    );
  }
}
