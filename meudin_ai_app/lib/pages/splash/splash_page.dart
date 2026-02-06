import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meudin_ai_app/app_session_initializer.dart';
import 'package:meudin_ai_app/routes/app_routes.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initSession();
  }

  Future<void> _initSession() async {
    final loggedIn = await initializeAppSession();
    if (!mounted) return;
    if (loggedIn) {
      Get.put(PlanStateController(), permanent: true);
      await Get.find<PlanStateController>().refreshPlan();
      if (!mounted) return;
      Get.offAllNamed(AppRoutes.homeAppRoute);
    } else {
      Get.offAllNamed(AppRoutes.signInRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox.shrink(),
    );
  }
}
