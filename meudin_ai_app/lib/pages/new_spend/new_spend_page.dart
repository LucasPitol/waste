import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';
import 'package:meudin_ai_app/pages/new_spend/new_spend_page_controller.dart';
import 'package:meudin_ai_app/utils/centavos_currency_formatter.dart';
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
        final theme = Theme.of(context);
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: FaIcon(
                FontAwesomeIcons.arrowLeft,
                size: 20,
                color: theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
              ),
              onPressed: () => Get.back(),
            ),
            title: Text(
              'Novo Gasto',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
              ),
            ),
            backgroundColor: theme.brightness == Brightness.dark 
                ? theme.colorScheme.surface 
                : Styles.whiteColor,
            elevation: 0,
          ),
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Amount
                Container(
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark 
                        ? theme.colorScheme.surface 
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: theme.brightness == Brightness.dark
                            ? Colors.black.withOpacity(0.3)
                            : Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.dollarSign, 
                        size: 18, 
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6) 
                            ?? Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: controller.amountController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            CentavosCurrencyFormatter(),
                          ],
                          style: TextStyle(
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Valor',
                            labelStyle: TextStyle(
                              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                            ),
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
                    color: theme.brightness == Brightness.dark 
                        ? theme.colorScheme.surface 
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: theme.brightness == Brightness.dark
                            ? Colors.black.withOpacity(0.3)
                            : Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.pen, 
                        size: 18, 
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6) 
                            ?? Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: controller.reasonController,
                          textCapitalization: TextCapitalization.sentences,
                          style: TextStyle(
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Descrição',
                            labelStyle: TextStyle(
                              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                            ),
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
                    color: theme.brightness == Brightness.dark 
                        ? theme.colorScheme.surface 
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: theme.brightness == Brightness.dark
                            ? Colors.black.withOpacity(0.3)
                            : Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.calendar, 
                        size: 18, 
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6) 
                            ?? Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: controller.pickDate,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Data', 
                                  style: TextStyle(
                                    fontSize: 12, 
                                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6) 
                                        ?? Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  controller.selectedDateString,
                                  style: TextStyle(
                                    fontSize: 16, 
                                    color: theme.textTheme.bodyLarge?.color ?? Colors.black,
                                  ),
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
                    color: theme.brightness == Brightness.dark 
                        ? theme.colorScheme.surface 
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: theme.brightness == Brightness.dark
                            ? Colors.black.withOpacity(0.3)
                            : Colors.black.withOpacity(0.03),
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
                              : (theme.brightness == Brightness.dark
                                  ? Colors.grey.shade800
                                  : Colors.grey[100]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: FaIcon(
                          controller.selectedCategoryIcon,
                          size: 18,
                          color: controller.selectedCategory?.colorData 
                              ?? (theme.textTheme.bodyMedium?.color?.withOpacity(0.6) ?? Colors.grey),
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
                                Text(
                                  'Categoria', 
                                  style: TextStyle(
                                    fontSize: 12, 
                                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6) 
                                        ?? Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  controller.selectedCategoryName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: controller.selectedCategory != null
                                        ? (theme.textTheme.bodyLarge?.color ?? Colors.black)
                                        : (theme.textTheme.bodyMedium?.color?.withOpacity(0.6) 
                                            ?? Colors.grey.shade600),
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
                      FaIcon(
                        FontAwesomeIcons.chevronRight,
                        size: 14,
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6) 
                            ?? Colors.grey,
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
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Styles.primaryColor,
                          ),
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
