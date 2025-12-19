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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          IconButton(
            icon: const FaIcon(
              FontAwesomeIcons.arrowLeft,
              color: Styles.primaryTextColor,
              size: 20,
            ),
            onPressed: () {
              Get.back();
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transações',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Styles.primaryTextColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  Utils.formatDateMMMdeYYYY(startDate),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
