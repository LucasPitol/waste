import 'package:flutter/material.dart';
import 'package:meudin_app/utils/styles.dart';

class InfoBottomSheetWidget extends StatefulWidget {
  final String? title;
  final String? message;

  InfoBottomSheetWidget({this.title, this.message});

  @override
  _InfoBottomSheetWidgetState createState() =>
      _InfoBottomSheetWidgetState(title, message);
}

class _InfoBottomSheetWidgetState extends State<InfoBottomSheetWidget> {
  final String? title;
  final String? message;

  _InfoBottomSheetWidgetState(this.title, this.message);

  _closeDialog() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
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
              title!,
              style: Styles.montTextTitle,
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              message!,
              style: Styles.montText,
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: TextButton(
              onPressed: () {
                _closeDialog();
              },
              child: Text(
                'Fechar',
                style: Styles.textButtonTextStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
