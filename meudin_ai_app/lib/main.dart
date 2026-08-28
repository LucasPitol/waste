import 'package:intl/date_symbol_data_local.dart';
import 'package:meudin_ai_app/routes/app_routes.dart';
import 'package:meudin_ai_app/services/theme_service.dart';
import 'package:meudin_ai_app/ui/styles.dart';
import 'package:meudin_ai_app/app_session_initializer.dart';
import 'package:meudin_ai_app/services/plan_state_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:meudin_ai_app/utils/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting(Constants.ptLanguageCode, null);
  
  // Inicializa o ThemeService e carrega preferência salva antes de rodar o app
  final themeService = Get.put(ThemeService(), permanent: true);
  await themeService.loadSavedPreference();

  // Inicializa sessão antes de rodar o app
  final loggedIn = await initializeAppSession();

  if (loggedIn) {
    Get.put(PlanStateController(), permanent: true);
    Get.find<PlanStateController>().refreshPlan(); // fire-and-forget, não bloqueia
  }

  runApp(MyApp(initialRoute: loggedIn ? AppRoutes.homeAppRoute : AppRoutes.signInRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    // Obtém o ThemeService já inicializado
    final themeService = Get.find<ThemeService>();

    return Obx(
      () {
        // Determina o brightness baseado no tema
        final brightness = _getBrightness(themeService.themeMode);
        
        // Configura a status bar
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: brightness == Brightness.dark 
                ? Brightness.light 
                : Brightness.dark,
            systemNavigationBarColor: brightness == Brightness.dark
                ? const Color(0xFF121212)
                : Colors.white,
            systemNavigationBarIconBrightness: brightness == Brightness.dark
                ? Brightness.light
                : Brightness.dark,
          ),
        );
        
        return GetMaterialApp(
          key: ValueKey(themeService.themeMode),
          debugShowCheckedModeBanner: false,
          theme: Styles.mainTheme,
          darkTheme: Styles.darkTheme,
          themeMode: themeService.themeMode,
          initialRoute: initialRoute,
          getPages: AppRoutes.pages,
        );
      },
    );
  }
  
  Brightness _getBrightness(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return Brightness.light;
      case ThemeMode.dark:
        return Brightness.dark;
      case ThemeMode.system:
        return WidgetsBinding.instance.platformDispatcher.platformBrightness;
    }
  }
}
