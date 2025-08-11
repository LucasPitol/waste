import 'package:meudin_ai_app/services/session_service.dart';

/// Call this before runApp() or in your splash logic.
Future<bool> initializeAppSession() async {
  return await SessionService.tryAutoLogin();
}
