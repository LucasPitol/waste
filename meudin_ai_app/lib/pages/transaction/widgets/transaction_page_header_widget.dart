import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';
import 'package:meudin_ai_app/utils/utils.dart';

class TransactionPageHeaderWidget extends StatelessWidget {
  final DateTime startDate;

  const TransactionPageHeaderWidget({super.key, required this.startDate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      alignment: Alignment.topRight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                JoyText.h1(
                  'Transações',
                ),
                JoyText.secundaryText(
                  Utils.formatDateMMMdeYYYY(startDate),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const FaIcon(
              FontAwesomeIcons.xmark,
              color: Styles.primaryTextColor,
              size: 22,
            ),
            onPressed: () {
              Get.back();
            },
          ),
        ],
      ),
    );
  }
}
