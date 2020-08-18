import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:waste_app/main_component.dart';
import 'package:waste_app/pages/login/login_component.dart';

import 'models/user_dto.dart';
import 'services/auth_service.dart';
import 'utils/constants.dart';
import 'utils/styles.dart';

void main() {
  initializeDateFormatting(Constants.ptLanguage).then((_) => runApp(Phoenix(
      child: MaterialApp(debugShowCheckedModeBanner: false, home: MyApp()))));
  // runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  UserDto currentUser;
  bool isAuthenticated = false;

  _MyAppState() {
    SchedulerBinding.instance
        .addPostFrameCallback((_) => this._updateMainState());
  }

  void setAppLanguage() {
    Locale locale = Localizations.localeOf(context);

    String languageCode = locale.languageCode;

    if (languageCode != 'pt') {
      AuthService.currentUser.language = 'en';
    } else {
      AuthService.currentUser.language = 'pt';
    }
  }

  void _updateMainState() {
    setState(() {
      this.setAppLanguage();
      this.currentUser = AuthService.currentUser;
      this.isAuthenticated = AuthService.isAuthenticated();
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.deepPurple,
    ));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Styles.mainTheme,
      home: this.isAuthenticated
          ? MainComponent()
          : LoginComponent(_updateMainState),
    );
  }
}
