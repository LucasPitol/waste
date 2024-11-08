import 'package:meudin_ai_app/modules/home/home_module_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OverviewModule extends StatelessWidget {
  const OverviewModule({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeModuleController>(
      init: HomeModuleController(),
      builder: (controller) {
        return Container(
          child: Text('Overview'),
        );
      },
    );
  }
}
