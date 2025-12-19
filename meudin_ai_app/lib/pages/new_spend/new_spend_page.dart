import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/currency_input_formatter.dart';
import 'package:get/get.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';
import 'package:meudin_ai_app/pages/new_spend/new_spend_page_controller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NewSpendPage extends StatelessWidget {
  const NewSpendPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NewSpendPageController>(
      init: NewSpendPageController(),
      builder: (controller) {
        // Show error bottom sheet if errorList is set
        if (controller.errorList != null && controller.errorList!.isNotEmpty) {
          Future.microtask(() {
            Get.bottomSheet(
              JoyModal.errorBottomSheet(
                context: context,
                errorList: controller.errorList!,
                title: 'Revise as informações preenchidas',
              ),
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              backgroundColor: Colors.transparent,
            );
            controller.errorList = null;
            controller.update();
          });
        }
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
              'Novo Gasto',
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
                // Amount
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Row(
                    children: [
                      const FaIcon(FontAwesomeIcons.dollarSign, size: 18, color: Colors.grey),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: controller.amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                // Reason
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Row(
                    children: [
                      const FaIcon(FontAwesomeIcons.pen, size: 18, color: Colors.grey),
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
                // Spend Date
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Row(
                    children: [
                      const FaIcon(FontAwesomeIcons.calendar, size: 18, color: Colors.grey),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: controller.pickDate,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Data', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                const SizedBox(height: 2),
                                Text(
                                  controller.selectedDateString,
                                  style: const TextStyle(fontSize: 16, color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Category
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: controller.selectedCategory != null
                              ? controller.selectedCategory!.colorData.withOpacity(0.15)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: FaIcon(
                          controller.selectedCategoryIcon,
                          size: 18,
                          color: controller.selectedCategory?.colorData ?? Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: controller.pickCategory,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Categoria', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                const SizedBox(height: 2),
                                Text(
                                  controller.selectedCategoryName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: controller.selectedCategory != null
                                        ? Colors.black
                                        : Colors.grey[600],
                                    fontWeight: controller.selectedCategory != null
                                        ? FontWeight.w500
                                        : FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const FaIcon(
                        FontAwesomeIcons.chevronRight,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                JoyElevatedButton(
                  text: controller.loading ? 'Salvando...' : 'Salvar',
                  function: controller.loading ? null : controller.saveSpend,
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
