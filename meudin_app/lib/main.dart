import 'package:flutter/scheduler.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';

import 'models/user.dart';
import 'pages/login/login_component.dart';
import 'services/user_service.dart';
import 'utils/constants.dart';
import 'utils/styles.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // await Firebase.initializeApp();
  initializeDateFormatting(Constants.ptLanguage)
      .then((_) => runApp(Phoenix(child: MyApp())));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late User? currentUser;
  bool isAuthenticated = false;

  _MyAppState() {
    SchedulerBinding.instance!.addPostFrameCallback((_) => _updateMainState());
  }

  void _updateMainState() {
    setState(() {
      currentUser = UserService.currentUser;
      isAuthenticated = UserService.isAuthenticated();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Styles.mainTheme,
      home: isAuthenticated
          ? Container()
          : LoginComponent(_updateMainState),
    );
  }
}
