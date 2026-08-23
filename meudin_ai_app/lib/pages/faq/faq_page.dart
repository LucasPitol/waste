import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meudin_ai_app/pages/faq/faq_page_controller.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';
import 'package:meudin_ai_app/ui/app_icons.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GetBuilder<FAQPageController>(
      init: FAQPageController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: AppIcon(
                AppIcons.arrowLeft,
                color: theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
                size: 20,
              ),
              onPressed: () => Get.back(),
            ),
            title: Text(
              'FAQ',
              style: TextStyle(
                color: theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Perguntas frequentes',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Encontre respostas rápidas para suas dúvidas',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7) ?? Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 32),

                // FAQ Items
                ...controller.faqItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isExpanded = controller.expandedIndex == index;
                  
                  return _buildFAQItem(
                    context,
                    theme,
                    controller,
                    index: index,
                    question: item['question']!,
                    answer: item['answer']!,
                    isExpanded: isExpanded,
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFAQItem(
    BuildContext context,
    ThemeData theme,
    FAQPageController controller, {
    required int index,
    required String question,
    required String answer,
    required bool isExpanded,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: isDark 
            ? Border.all(
                color: theme.colorScheme.surface.withOpacity(0.3),
                width: 0.5,
              )
            : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => controller.toggleExpanded(index),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      question,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  AppIcon(
                    isExpanded 
                        ? AppIcons.chevronUp
                        : AppIcons.chevronDown,
                    size: 12,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4) ?? Colors.grey.shade400,
                  ),
                ],
              ),
              if (isExpanded) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    answer,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8) ?? Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
