import 'package:meudin_ai_app/modules/home/widgets/app_bar/home_app_bar.dart';
import 'package:meudin_ai_app/modules/home/home_module_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeModule extends StatelessWidget {
  const HomeModule({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeModuleController>(
      init: HomeModuleController(),
      builder: (controller) {
        return SingleChildScrollView(
          child: Column(
            children: [
              HomeAppBar(),
            ],
          ),
        );
      },
    );
  }
}
