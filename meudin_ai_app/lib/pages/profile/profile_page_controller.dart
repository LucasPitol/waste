import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meudin_ai_app/models/subscription.dart';
import 'package:meudin_ai_app/models/user_subscription.dart';
import 'package:meudin_ai_app/routes/app_routes.dart';
import 'package:meudin_ai_app/services/session_service.dart';
import 'package:meudin_ai_app/services/subscription_state_service.dart';
import 'package:meudin_ai_app/services/theme_service.dart';
import 'package:meudin_ai_app/services/user_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePageController extends GetxController {
  late String userName;
  late String userEmail;
  late bool loading;
  late ThemeService _themeService;
  late SubscriptionStateService _subscriptionStateService;
  String appVersion = '1.0.0'; // Default fallback
  UserSubscription? _userSubscription;

  ProfilePageController() {
    loading = false;
    _themeService = Get.find<ThemeService>();
    _subscriptionStateService = SubscriptionStateService();
    _loadUserData();
    _loadAppVersion();
    _loadSubscription();
  }

  Future<void> _loadSubscription() async {
    try {
      _userSubscription = await _subscriptionStateService.getSubscription();
      update();
    } catch (e) {
      // Silent error - subscription data is optional
    }
  }

  String get currentPlanName {
    if (_userSubscription == null) {
      return 'Plano Start';
    }
    return 'Plano ${_userSubscription!.plan.displayName}';
  }

  bool get hasActiveSubscription {
    return _userSubscription?.subscription?.isActive ?? false;
  }

  String? get subscriptionProvider =>
      _userSubscription?.subscription?.provider;

  String get subscriptionStatusText {
    if (_userSubscription?.subscription == null) {
      return 'Sem assinatura ativa';
    }
    
    final status = _userSubscription!.subscription!.status;
    switch (status) {
      case SubscriptionStatus.active:
        return 'Ativa';
      case SubscriptionStatus.pending:
        return 'Pagamento pendente';
      case SubscriptionStatus.pastDue:
        return 'Pagamento em atraso';
      case SubscriptionStatus.canceled:
        return 'Cancelada';
      case SubscriptionStatus.expired:
        return 'Expirada';
    }
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      appVersion = packageInfo.version;
      update();
    } catch (e) {
      // Se houver erro, mantém o valor padrão
      appVersion = '1.0.0';
    }
  }

  void _loadUserData() {
    final user = UserService.currentUser;
    if (user != null) {
      userName = user.displayName;
      userEmail = user.email;
    } else {
      userName = 'Usuário';
      userEmail = '';
    }
  }

  ThemeMode get currentThemeMode => _themeService.themeMode;
  String get currentThemeName => _themeService.getThemeModeName();

  Future<void> changeTheme(ThemeMode newThemeMode) async {
    await _themeService.setThemeMode(newThemeMode);
    update();
  }

  void openFAQ() {
    Get.toNamed(AppRoutes.faqRoute);
  }

  void sendFeedback() {
    // TODO: Implementar modal/bottom sheet para feedback
    Get.snackbar('Feedback', 'Em breve');
  }

  void contactSupport() {
    Get.toNamed(AppRoutes.contactSupportRoute);
  }

  void showAbout(BuildContext context) {
    // Implementado na ProfilePage._showAboutBottomSheet
  }

  Future<void> openTerms() async {
    final uri = Uri.parse('https://phrygian-guan-5b6.notion.site/Termos-de-Uso-Meudin-2d6e00f9b28d809da295d1fa8494eef3');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Erro', 'Não foi possível abrir os termos de uso');
    }
  }

  Future<void> openPrivacyPolicy() async {
    final uri = Uri.parse('https://phrygian-guan-5b6.notion.site/Pol-tica-de-Privacidade-Meudin-2d6e00f9b28d80af8e51f8232c53254a');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Erro', 'Não foi possível abrir a política de privacidade');
    }
  }

  Future<void> logout() async {
    loading = true;
    update();

    try {
      await SessionService.logout();
      Get.offAllNamed(AppRoutes.signInRoute);
    } catch (e) {
      loading = false;
      update();
    }
  }
}

