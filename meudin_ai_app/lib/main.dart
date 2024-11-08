import 'package:meudin_ai_app/routes/app_routes.dart';
import 'package:meudin_ai_app/ui/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // await initializeDateFormatting(Constants.ptLanguage, null);
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  // if (kDebugMode) {
  //   FirebaseFirestore.instance.useFirestoreEmulator('127.0.0.1', 8080);
  // }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Styles.mainTheme,
      initialRoute: AppRoutes.homeAppRoute,
      getPages: AppRoutes.pages,
    );
  }
}
