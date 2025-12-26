import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meudin_ai_app/services/support_service.dart';
import 'package:meudin_ai_app/services/user_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ContactSupportPageController extends GetxController {
  final SupportService _supportService = SupportService();
  final TextEditingController messageController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  
  bool loading = false;
  String appVersion = '1.0.0';
  String platform = 'Unknown';

  @override
  void onInit() {
    super.onInit();
    _loadAppVersion();
    _detectPlatform();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      appVersion = packageInfo.version;
      update();
    } catch (e) {
      appVersion = '1.0.0';
    }
  }

  void _detectPlatform() {
    if (Platform.isIOS) {
      platform = 'iOS';
    } else if (Platform.isAndroid) {
      platform = 'Android';
    } else {
      platform = 'Unknown';
    }
    update();
  }

  String? _validateMessage(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, descreva sua dúvida ou problema';
    }
    return null;
  }

  String? validateMessage(String? value) => _validateMessage(value);

  Future<void> sendMessage() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    loading = true;
    update();

    try {
      final user = UserService.currentUser;
      final walletId = user?.currentWalletId;

      final response = await _supportService.contactSupport(
        message: messageController.text.trim(),
        walletId: walletId?.isNotEmpty == true ? walletId : null,
        platform: platform,
        appVersion: appVersion,
      );

      loading = false;
      update();

      if (response.success) {
        // Mostra bottom sheet informando que o retorno não é imediato
        _showSuccessBottomSheet();
      } else {
        Get.snackbar(
          'Erro',
          response.errorMessage ?? 'Não foi possível enviar sua mensagem. Tente novamente.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
        );
      }
    } catch (e) {
      loading = false;
      update();
      Get.snackbar(
        'Erro',
        'Ocorreu um erro ao enviar sua mensagem. Tente novamente.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  void _showSuccessBottomSheet() {
    final theme = Theme.of(Get.context!);
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.2) ?? Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 64,
            ),
            const SizedBox(height: 20),
            Text(
              'Mensagem enviada!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Recebemos sua mensagem e entraremos em contato em breve via e-mail. O retorno não é imediato, mas responderemos o mais rápido possível.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back(); // Fecha o bottom sheet
                  Get.back(); // Volta para a página anterior
                  messageController.clear();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Entendi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      isDismissible: false,
      enableDrag: false,
    );
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }
}

