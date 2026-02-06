import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persiste e recupera o receipt Apple para validação on-demand.
/// Receipt recuperável após reinstalação via restore purchases.
class ReceiptStorageService {
  static const String _appleReceiptKey = 'apple_app_receipt';

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  /// Persiste o receipt após compra ou restauração
  Future<void> saveAppleReceipt(String receiptData) async {
    if (receiptData.isEmpty) return;
    await _storage.write(key: _appleReceiptKey, value: receiptData);
  }

  /// Recupera o receipt persistido (null se não houver)
  Future<String?> getAppleReceipt() async {
    return await _storage.read(key: _appleReceiptKey);
  }

  /// Remove o receipt (ex: logout)
  Future<void> clearAppleReceipt() async {
    await _storage.delete(key: _appleReceiptKey);
  }

  /// Verifica se há receipt persistido
  Future<bool> hasAppleReceipt() async {
    final receipt = await getAppleReceipt();
    return receipt != null && receipt.isNotEmpty;
  }
}
