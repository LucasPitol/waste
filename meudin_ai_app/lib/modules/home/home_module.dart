import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meudin_ai_app/modules/home/home_module_controller.dart';

class HomeModule extends StatelessWidget {
  const HomeModule({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeModuleController>(
      init: HomeModuleController(),
      builder: (controller) {
        return Container(
          child: Text('Home'),
        );
      },
    );
  }
}
