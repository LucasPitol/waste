import 'package:intl/date_symbol_data_local.dart';
import 'package:meudin_ai_app/routes/app_routes.dart';
import 'package:meudin_ai_app/services/theme_service.dart';
import 'package:meudin_ai_app/ui/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meudin_ai_app/utils/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting(Constants.ptLanguageCode, null);
  
  // Inicializa o ThemeService antes de rodar o app
  Get.put(ThemeService(), permanent: true);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtém o ThemeService já inicializado
    final themeService = Get.find<ThemeService>();

    return Obx(
      () => GetMaterialApp(
        key: ValueKey(themeService.themeMode),
        debugShowCheckedModeBanner: false,
        theme: Styles.mainTheme,
        darkTheme: Styles.darkTheme,
        themeMode: themeService.themeMode,
        initialRoute: AppRoutes.splashRoute,
        getPages: AppRoutes.pages,
      ),
    );
  }
}
