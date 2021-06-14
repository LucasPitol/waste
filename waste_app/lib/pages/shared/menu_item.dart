import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:waste_app/utils/styles.dart';
import 'package:flutter/material.dart';

class MenuItem extends StatelessWidget {
  final IconData icon;
  final String name;

  MenuItem(this.icon, this.name);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Container(
            child: FaIcon(
              this.icon,
              color: Styles.primaryColor,
              size: 22,
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 20),
            child: Text(
              this.name,
              style: Styles.poppinsText,
            ),
          ),
        ],
      ),
    );
  }
}
