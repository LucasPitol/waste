import 'package:flutter/material.dart';
import 'package:waste_app/utils/styles.dart';

class LoadingWidget extends StatefulWidget {
  @override
  _LoadingWidgetState createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 60),
      width: double.infinity,
      alignment: Alignment.center,
      child: new CircularProgressIndicator(
        color: Styles.primaryColor,
      ),
    );
  }
}
