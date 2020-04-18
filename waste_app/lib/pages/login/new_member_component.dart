import 'package:flutter/material.dart';
import 'package:waste_app/utils/styles.dart';

class NewMemberComponent extends StatefulWidget {
  @override
  _NewMemberComponentState createState() => _NewMemberComponentState();
}

class _NewMemberComponentState extends State<NewMemberComponent> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Styles.mainTheme,
    );
  }
}
