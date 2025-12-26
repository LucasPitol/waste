import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';
import 'package:meudin_ai_app/pages/add_member/add_member_page_controller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AddMemberPage extends StatelessWidget {
  const AddMemberPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GetBuilder<AddMemberPageController>(
      init: AddMemberPageController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: theme.brightness == Brightness.dark 
                ? theme.scaffoldBackgroundColor 
                : Styles.whiteConfortColor,
            elevation: 0,
            iconTheme: IconThemeData(
              color: theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
            ),
            leading: IconButton(
              icon: FaIcon(
                FontAwesomeIcons.arrowLeft,
                color: theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
                size: 20,
              ),
              onPressed: () => Get.back(),
            ),
            title: Text(
              'Adicionar Membro',
              style: TextStyle(
                color: theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
          ),
          backgroundColor: theme.brightness == Brightness.dark 
              ? theme.scaffoldBackgroundColor 
              : Styles.whiteConfortColor,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Email Field
                Container(
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark 
                        ? theme.colorScheme.surface 
                        : Colors.white,
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
                      FaIcon(
                        FontAwesomeIcons.envelope,
                        size: 18,
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6) ?? Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: controller.emailController,
                          keyboardType: TextInputType.emailAddress,
                          textCapitalization: TextCapitalization.none,
                          decoration: InputDecoration(
                            labelText: 'Email do membro',
                            border: InputBorder.none,
                            labelStyle: TextStyle(
                              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6) ?? Colors.grey,
                            ),
                          ),
                          style: TextStyle(
                            color: theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                JoyElevatedButton(
                  text: controller.loading ? 'Adicionando...' : 'Adicionar Membro',
                  function: controller.loading ? null : controller.addMember,
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
                          valueColor: AlwaysStoppedAnimation<Color>(Styles.primaryColor),
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
