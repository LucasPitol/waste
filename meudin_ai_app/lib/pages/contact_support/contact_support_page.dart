import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meudin_ai_app/pages/contact_support/contact_support_page_controller.dart';
import 'package:meudin_ai_app/ui/joy_elevated_button.dart';
import 'package:meudin_ai_app/ui/joy_text_form_field.dart';
import 'package:meudin_ai_app/ui/joy_loading_block.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';
import 'package:meudin_ai_app/ui/app_icons.dart';

class ContactSupportPage extends StatelessWidget {
  const ContactSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GetBuilder<ContactSupportPageController>(
      init: ContactSupportPageController(),
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
              'Falar com suporte',
              style: TextStyle(
                color: theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Text(
                        'Como podemos ajudar?',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Descreva sua dúvida ou problema e nossa equipe entrará em contato com você.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7) ?? Colors.grey.shade600,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Message Field
                      Text(
                        'Mensagem',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: theme.textTheme.bodyMedium?.color ?? Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: controller.messageController,
                        validator: controller.validateMessage,
                        maxLines: 8,
                        maxLength: 1000,
                        textCapitalization: TextCapitalization.sentences,
                        style: TextStyle(
                          color: theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: 'Digite sua mensagem aqui...',
                          hintStyle: TextStyle(
                            color: theme.brightness == Brightness.dark 
                                ? Colors.grey[500] 
                                : Colors.grey[400],
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                          filled: true,
                          fillColor: theme.brightness == Brightness.dark 
                              ? theme.colorScheme.surface 
                              : Colors.grey[50],
                          contentPadding: const EdgeInsets.all(20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: theme.brightness == Brightness.dark 
                                  ? Colors.grey[700]! 
                                  : Colors.grey[200]!,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Styles.primaryColor,
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Colors.red[300]!,
                              width: 1,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Info Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.brightness == Brightness.dark
                              ? theme.colorScheme.surface.withOpacity(0.5)
                              : Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.brightness == Brightness.dark
                                ? Colors.blue.shade800
                                : Colors.blue.shade200,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline,
                              color: theme.brightness == Brightness.dark
                                  ? Colors.blue.shade300
                                  : Colors.blue.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Sua mensagem será analisada pela equipe e o retorno será feito via e-mail. Não é um atendimento imediato.',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: theme.brightness == Brightness.dark
                                      ? Colors.blue.shade200
                                      : Colors.blue.shade900,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Send Button
                      JoyElevatedButton(
                        text: 'Enviar',
                        function: controller.sendMessage,
                        backgroundColor: Styles.primaryColor,
                        textColor: Styles.whiteColor,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              JoyLoadingBlock(controller.loading),
            ],
          ),
        );
      },
    );
  }
}

