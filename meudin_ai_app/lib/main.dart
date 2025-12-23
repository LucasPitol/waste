import 'package:intl/date_symbol_data_local.dart';
import 'package:meudin_ai_app/routes/app_routes.dart';
import 'package:meudin_ai_app/services/theme_service.dart';
import 'package:meudin_ai_app/ui/styles.dart';
import 'package:meudin_ai_app/app_session_initializer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:meudin_ai_app/utils/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting(Constants.ptLanguageCode, null);
  
  // Inicializa o ThemeService antes de rodar o app
  Get.put(ThemeService(), permanent: true);
  
  // Inicializa sessão antes de rodar o app
  final loggedIn = await initializeAppSession();
  
  runApp(MyApp(initialRoute: loggedIn ? AppRoutes.homeAppRoute : AppRoutes.signInRoute));
}

class MyApp extends StatefulWidget {
  final String initialRoute;
  
  const MyApp({super.key, required this.initialRoute});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _updateSystemUIOverlayStyle();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    _updateSystemUIOverlayStyle();
  }

  void _updateSystemUIOverlayStyle() {
    final themeService = Get.find<ThemeService>();
    final brightness = _getBrightness(themeService.themeMode);
    
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: brightness == Brightness.dark 
            ? Brightness.light 
            : Brightness.dark,
        statusBarBrightness: brightness == Brightness.dark 
            ? Brightness.dark 
            : Brightness.light,
        systemNavigationBarColor: brightness == Brightness.dark
            ? const Color(0xFF121212)
            : Colors.white,
        systemNavigationBarIconBrightness: brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Obtém o ThemeService já inicializado
    final themeService = Get.find<ThemeService>();

    return Obx(
      () {
        // Atualiza a status bar quando o tema mudar
        final brightness = _getBrightness(themeService.themeMode);
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: brightness == Brightness.dark 
                ? Brightness.light 
                : Brightness.dark,
            statusBarBrightness: brightness == Brightness.dark 
                ? Brightness.dark 
                : Brightness.light,
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
          initialRoute: widget.initialRoute,
          getPages: AppRoutes.pages,
        );
      },
    );
  }
  
  /// Determina o brightness atual baseado no themeMode
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
