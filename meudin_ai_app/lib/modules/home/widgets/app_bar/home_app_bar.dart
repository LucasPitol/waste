import 'package:meudin_ai_app/modules/home/widgets/app_bar/home_app_bar_controller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeAppBarController>(
      init: HomeAppBarController(),
      builder: (controller) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const JoyLogo(),
              SizedBox(
                child: Row(
                  children: [
                    IconButton(
                      icon: const FaIcon(
                        FontAwesomeIcons.arrowRotateRight,
                        color: Styles.primaryTextColor,
                        size: 20,
                      ),
                      onPressed: () {
                        print('Refresh');
                      },
                    ),
                    IconButton(
                      icon: const FaIcon(
                        FontAwesomeIcons.solidCircleUser,
                        color: Styles.primaryTextColor,
                        size: 22,
                      ),
                      onPressed: () {
                        print('profile');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
