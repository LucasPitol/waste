import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';

import 'main_component.dart';
import 'models/user.dart';
import 'pages/login/login_component.dart';
import 'services/user_service.dart';
import 'utils/constants.dart';
import 'utils/styles.dart';
import 'utils/utils.dart';

const bool USE_EMULATOR = true;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  initializeDateFormatting(Constants.ptLanguage);

  await Firebase.initializeApp();

  if (USE_EMULATOR) {
    await _connectToFirebaseEmulator();
    Utils.mockData();
  }

  runApp(Phoenix(child: MyApp()));
}

Future _connectToFirebaseEmulator() async {
  const localHostString = '192.168.0.17';

  FirebaseFirestore.instance.settings = const Settings(
    host: '$localHostString:8080',
    sslEnabled: false,
    persistenceEnabled: false,
  );
  // FirebaseFirestore.instance.useFirestoreEmulator('192.168.0.17', 8080);
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
      title: 'Meudin',
      theme: Styles.mainTheme,
      home:
          isAuthenticated ? MainComponent() : LoginComponent(_updateMainState),
    );
  }
}
