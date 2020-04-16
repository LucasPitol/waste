import 'package:flutter/material.dart';
import 'package:waste_app/pages/login/login_component.dart';


void main() {
  // initializeDateFormatting().then((_) => runApp(MaterialApp(home: AppMorador())));
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {

    return LoginComponent();
 
  }
}
