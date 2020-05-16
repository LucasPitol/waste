import 'package:flutter/material.dart';

class DrawerMenuItem extends StatelessWidget {
  final String displayName;
  final IconData iconData;

  DrawerMenuItem(this.displayName, this.iconData);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 20, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 20),
            child: Text(
              this.displayName,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Icon(
            this.iconData,
            color: Colors.deepPurple,
            size: 20,
          ),
        ],
      ),
    );
  }
}
