import 'package:flutter/material.dart';
import 'package:waste_app/utils/styles.dart';

class InfoBottomSheetComponent extends StatelessWidget {
  final String info;

  InfoBottomSheetComponent(this.info);

  String _getcontentText() {
    return this.info;
  }

  _closeDialog(BuildContext context) {
    Navigator.pop(context, 'Ok');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Styles.mainBackgroundColor,
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 10),
            child: Icon(
              Icons.maximize,
              color: Colors.grey.shade800,
              size: 50,
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              _getcontentText(),
              style: TextStyle(
                color: Colors.grey.shade100,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            child: TextButton(
              style: Styles.textButtonStyle,
              onPressed: () {
                this._closeDialog(context);
              },
              child: Text(
                'Ok',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
