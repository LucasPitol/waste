import 'package:flutter/material.dart';
import 'package:meudin_app/utils/styles.dart';

class OptionBottomSheetWidget extends StatefulWidget {
  final String title;
  final String message;
  final String actionTitle;
  final String cancelTitle;

  OptionBottomSheetWidget({
    required this.title,
    required this.message,
    required this.actionTitle,
    required this.cancelTitle,
  });

  @override
  _OptionBottomSheetWidgetState createState() =>
      _OptionBottomSheetWidgetState(title, message, actionTitle, cancelTitle);
}

class _OptionBottomSheetWidgetState extends State<OptionBottomSheetWidget> {
  final String title;
  final String message;
  final String actionTitle;
  final String cancelTitle;

  _OptionBottomSheetWidgetState(
    this.title,
    this.message,
    this.actionTitle,
    this.cancelTitle,
  );

  _closeDialog(bool option) {
    Navigator.pop(context, option);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10),
            child: Icon(
              Icons.maximize,
              color: Colors.grey.shade800,
              size: 50,
            ),
          ),
          Container(
            alignment: Alignment.center,
            child: Text(
              title,
              style: Styles.montTextTitle,
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              message,
              style: Styles.montText,
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    _closeDialog(false);
                  },
                  child: Text(
                    cancelTitle,
                    style: Styles.textButtonTextStyle,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _closeDialog(true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Styles.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: Styles.defaultBorderRadius,
                    ),
                  ),
                  child: Text(
                    actionTitle,
                    style: Styles.buttonTextStyle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
