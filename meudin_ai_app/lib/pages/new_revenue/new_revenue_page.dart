import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/currency_input_formatter.dart';
import 'package:get/get.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';
import 'package:meudin_ai_app/pages/new_revenue/new_revenue_page_controller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NewRevenuePage extends StatelessWidget {
  const NewRevenuePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NewRevenuePageController>(
      init: NewRevenuePageController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Get.back(),
            ),
            title: const Text('Nova Receita'),
            backgroundColor: Styles.whiteColor,
            foregroundColor: Styles.primaryTextColor,
            elevation: 0,
          ),
          backgroundColor: Styles.whiteConfortColor,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Row(
                    children: [
                      const FaIcon(FontAwesomeIcons.dollarSign,
                          size: 18, color: Colors.grey),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: controller.amountController,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            CurrencyInputFormatter(leadingSymbol: 'R\$')
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Valor',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Row(
                    children: [
                      const FaIcon(FontAwesomeIcons.pen,
                          size: 18, color: Colors.grey),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: controller.reasonController,
                          decoration: const InputDecoration(
                            labelText: 'Descrição',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Row(
                    children: [
                      const FaIcon(FontAwesomeIcons.calendar,
                          size: 18, color: Colors.grey),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: controller.pickDate,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Data',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                                const SizedBox(height: 2),
                                Text(
                                  controller.selectedDateString,
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                JoyElevatedButton(
                  text: controller.loading ? 'Salvando...' : 'Salvar',
                  function: controller.loading ? null : controller.saveRevenue,
                  backgroundColor: Styles.primaryColor,
                  textColor: Styles.whiteColor,
                ),
                if (controller.loading)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                          strokeWidth: 2.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
