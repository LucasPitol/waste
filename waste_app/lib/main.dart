import 'package:flutter/material.dart';
import 'package:waste_app/pages/login/login_component.dart';

import 'models/user_dto.dart';
import 'services/auth_service.dart';


void main() {
  // initializeDateFormatting().then((_) => runApp(MaterialApp(home: AppMorador())));
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  UserDto currentUser;

  void _updateMainState() {
    setState(() {
      this.currentUser = AuthService.currentUser;
    });
  }

  @override
  Widget build(BuildContext context) {

    if (currentUser == null) {
      return LoginComponent(_updateMainState);
    } else {
      return Text('Entroou');
    } 
  }
}
