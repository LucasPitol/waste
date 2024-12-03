import 'dart:convert';

class EncryptionService {
  Future<String> encryptString(String input) async {
    final encrypted = base64Encode(utf8.encode(input));

    return encrypted;
  }
}
