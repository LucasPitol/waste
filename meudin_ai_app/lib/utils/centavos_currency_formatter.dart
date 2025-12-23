import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Formatter que interpreta a digitação em centavos (comportamento Nubank)
/// 
/// Exemplos:
/// - Digitar "1" → exibe "0,01"
/// - Digitar "10" → exibe "0,10"
/// - Digitar "100" → exibe "1,00"
/// - Digitar "810" → exibe "8,10"
/// - Digitar "12345" → exibe "123,45"
class CentavosCurrencyFormatter extends TextInputFormatter {
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$ ',
    decimalDigits: 2,
  );

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove todos os caracteres não numéricos
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Se não há dígitos, retorna vazio
    if (digitsOnly.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Converte para centavos (int)
    int centavos = int.parse(digitsOnly);

    // Converte centavos para reais (double)
    double valor = centavos / 100.0;

    // Formata como moeda
    String formatted = _currencyFormat.format(valor);

    // Calcula a nova posição do cursor (sempre no final)
    int newOffset = formatted.length;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }

  /// Converte o texto formatado de volta para valor numérico (double)
  /// Útil para obter o valor real ao salvar
  static double parseValue(String formattedText) {
    if (formattedText.trim().isEmpty) {
      return 0.0;
    }
    
    // Remove símbolo R$ e espaços
    String clean = formattedText
        .replaceAll('R\$', '')
        .replaceAll('R', '')
        .replaceAll('\$', '')
        .replaceAll(' ', '')
        .trim();
    
    // Remove pontos (separadores de milhar) e substitui vírgula por ponto
    // Exemplo: "R$ 123.456,78" → "123456.78"
    if (clean.contains(',')) {
      // Tem vírgula decimal
      clean = clean.replaceAll('.', ''); // Remove pontos de milhar
      clean = clean.replaceAll(',', '.'); // Substitui vírgula por ponto
    } else if (clean.contains('.')) {
      // Pode ser formato com ponto decimal ou separador de milhar
      // Se tiver mais de um ponto, são separadores de milhar
      final parts = clean.split('.');
      if (parts.length > 2) {
        // São separadores de milhar, remove todos
        clean = clean.replaceAll('.', '');
      }
      // Se tiver apenas um ponto, mantém como decimal
    }
    
    return double.tryParse(clean) ?? 0.0;
  }
}

