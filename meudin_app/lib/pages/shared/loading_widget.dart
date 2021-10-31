import 'package:flutter/material.dart';
import 'package:meudin_app/utils/styles.dart';

class LoadingWidget extends StatefulWidget {
  @override
  _LoadingWidgetState createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 60),
      width: double.infinity,
      alignment: Alignment.center,
      child: CircularProgressIndicator(
        color: Styles.primaryColor,
      ),
    );
  }
}
