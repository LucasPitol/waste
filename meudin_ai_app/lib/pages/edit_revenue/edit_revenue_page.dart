import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/currency_input_formatter.dart';
import 'package:get/get.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';
import 'package:meudin_ai_app/pages/edit_revenue/edit_revenue_page_controller.dart';
import 'package:meudin_ai_app/models/transaction.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EditRevenuePage extends StatelessWidget {
  const EditRevenuePage({super.key});

  @override
  Widget build(BuildContext context) {
    final transaction = Get.arguments as Transaction;
    return GetBuilder<EditRevenuePageController>(
      init: EditRevenuePageController(transaction),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const FaIcon(
                FontAwesomeIcons.arrowLeft,
                size: 20,
              ),
              onPressed: () => Get.back(),
            ),
            title: const Text(
              'Editar Receita',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
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
                  function: controller.loading ? null : controller.updateRevenue,
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
                const SizedBox(height: 24),
                // Delete button
                OutlinedButton(
                  onPressed: controller.deleting ? null : controller.showDeleteConfirmation,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: controller.deleting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                            strokeWidth: 2.5,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const FaIcon(
                              FontAwesomeIcons.trash,
                              size: 16,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Excluir transação',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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
