import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SpendingCategory {
  final String id;
  final String name;
  final String value;
  final String? icon; // String do backend (ex: "food", "shoppingBags")
  final String? color; // Hex string do backend (ex: "#FF6B6B")
  final DateTime creationDate;
  final DateTime lastUpdate;

  // Computed properties para UI
  IconData get iconData => _getIconFromString(icon ?? '');
  Color get colorData => _getColorFromString(color ?? '#B2BEC3');

  SpendingCategory({
    required this.id,
    required this.name,
    required this.value,
    this.icon,
    this.color,
    required this.creationDate,
    required this.lastUpdate,
  });

  /// Parse from API response
  static SpendingCategory fromApi(Map<String, dynamic> data) {
    final String id = data['id']?.toString() ?? '';
    final String name = data['name']?.toString() ?? 'Outro';
    final String value = data['value']?.toString() ?? '';
    final String? icon = data['icon']?.toString();
    final String? color = data['color']?.toString();
    
    // Parse dates
    DateTime creationDate;
    DateTime lastUpdate;
    
    try {
      creationDate = DateTime.parse(data['creationDate']?.toString() ?? DateTime.now().toIso8601String());
    } catch (e) {
      creationDate = DateTime.now();
    }
    
    try {
      lastUpdate = DateTime.parse(data['lastUpdate']?.toString() ?? creationDate.toIso8601String());
    } catch (e) {
      lastUpdate = creationDate;
    }
    
    return SpendingCategory(
      id: id,
      name: name,
      value: value,
      icon: icon,
      color: color,
      creationDate: creationDate,
      lastUpdate: lastUpdate,
    );
  }

  /// Mapeia string de ícone do backend para IconData do FontAwesome
  static IconData _getIconFromString(String iconString) {
    if (iconString.isEmpty) {
      return FontAwesomeIcons.circleQuestion;
    }
    
    final iconMap = {
      // Alimentação
      'food': FontAwesomeIcons.utensils,
      
      // Compras/Shopping
      'shoppingbags': FontAwesomeIcons.shoppingBag,
      'shopping': FontAwesomeIcons.shoppingBag,
      'shoppingcart': FontAwesomeIcons.cartShopping,
      'compras': FontAwesomeIcons.shoppingBag,
      
      // Investimento
      'investment': FontAwesomeIcons.chartLine,
      'investimento': FontAwesomeIcons.chartLine,
      'investments': FontAwesomeIcons.chartLine,
      'stocks': FontAwesomeIcons.arrowTrendUp,
      'stonks': FontAwesomeIcons.arrowTrendUp,
      'chart': FontAwesomeIcons.chartLine,
      
      // Educação
      'education': FontAwesomeIcons.book,
      'educacao': FontAwesomeIcons.book,
      'school': FontAwesomeIcons.graduationCap,
      'book': FontAwesomeIcons.book,
      'books': FontAwesomeIcons.book,
      'livros': FontAwesomeIcons.book,
      'bookopen': FontAwesomeIcons.bookOpen,
      
      // Salário
      'salary': FontAwesomeIcons.moneyBillWave,
      'salario': FontAwesomeIcons.moneyBillWave,
      'income': FontAwesomeIcons.moneyBillWave,
      'wage': FontAwesomeIcons.moneyBillWave,
      'money': FontAwesomeIcons.moneyBill,
      'wallet': FontAwesomeIcons.wallet,
      'coins': FontAwesomeIcons.coins,
      
      // Transporte
      'transport': FontAwesomeIcons.bus,
      'transporte': FontAwesomeIcons.bus,
      'car': FontAwesomeIcons.car,
      'vehicle': FontAwesomeIcons.car,
      'veiculo': FontAwesomeIcons.car,
      'bus': FontAwesomeIcons.bus,
      'train': FontAwesomeIcons.train,
      'bicycle': FontAwesomeIcons.bicycle,
      'motorcycle': FontAwesomeIcons.motorcycle,
      'taxi': FontAwesomeIcons.taxi,
      
      // Moradia
      'house': FontAwesomeIcons.house,
      'home': FontAwesomeIcons.house,
      'moradia': FontAwesomeIcons.house,
      
      // Saúde
      'health': FontAwesomeIcons.heartPulse,
      'saude': FontAwesomeIcons.heartPulse,
      'medical': FontAwesomeIcons.heartPulse,
      
      // Lazer/Entretenimento
      'entertainment': FontAwesomeIcons.gamepad,
      'leisure': FontAwesomeIcons.gamepad,
      'lazer': FontAwesomeIcons.gamepad,
      
      // Contas/Utilidades
      'bills': FontAwesomeIcons.fileInvoiceDollar,
      'contas': FontAwesomeIcons.fileInvoiceDollar,
      'utilities': FontAwesomeIcons.fileInvoiceDollar,
      
      // Outros
      'pet': FontAwesomeIcons.paw,
      'travel': FontAwesomeIcons.planeDeparture,
      'viagem': FontAwesomeIcons.planeDeparture,
      'fitness': FontAwesomeIcons.dumbbell,
      'gym': FontAwesomeIcons.dumbbell,
      'academia': FontAwesomeIcons.dumbbell,
      'beauty': FontAwesomeIcons.scissors,
      'beleza': FontAwesomeIcons.scissors,
      'electronics': FontAwesomeIcons.mobileScreen,
      'eletronicos': FontAwesomeIcons.mobileScreen,
      'gift': FontAwesomeIcons.gift,
      'presente': FontAwesomeIcons.gift,
      'subscription': FontAwesomeIcons.tv,
      'streaming': FontAwesomeIcons.tv,
      'assinatura': FontAwesomeIcons.tv,
      'others': FontAwesomeIcons.circleQuestion,
      'outros': FontAwesomeIcons.circleQuestion,
    };

    final lowerIcon = iconString.toLowerCase();
    final iconData = iconMap[lowerIcon] ?? FontAwesomeIcons.circleQuestion;
    
    // Debug: print quando não encontrar ícone
    if (!iconMap.containsKey(lowerIcon)) {
      print('⚠️ [SpendingCategory] Ícone não encontrado: "$iconString" (usando fallback)');
    }
    
    return iconData;
  }

  /// Converte hex string para Color
  static Color _getColorFromString(String hexString) {
    try {
      // Remove # se presente
      String hex = hexString.replaceAll('#', '');
      
      // Adiciona FF para alpha se não tiver
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      
      // Converte para int e cria Color
      final colorValue = int.parse(hex, radix: 16);
      return Color(colorValue);
    } catch (e) {
      // Fallback para cor padrão
      return const Color(0xFFB2BEC3);
    }
  }

  /// Converte para JSON (útil para debug)
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'value': value,
        'icon': icon,
        'color': color,
        'creationDate': creationDate.toIso8601String(),
        'lastUpdate': lastUpdate.toIso8601String(),
      };

  /// Lista de todas as categorias disponíveis (para testes)
  static List<SpendingCategory> getMockCategories() {
    final now = DateTime.now();
    return [
      SpendingCategory(
        id: '1',
        name: 'Alimentação',
        value: 'food',
        icon: 'food',
        color: '#FF6B6B',
        creationDate: now,
        lastUpdate: now,
      ),
      SpendingCategory(
        id: '2',
        name: 'Transporte',
        value: 'transport',
        icon: 'car',
        color: '#4ECDC4',
        creationDate: now,
        lastUpdate: now,
      ),
      SpendingCategory(
        id: '3',
        name: 'Moradia',
        value: 'house',
        icon: 'house',
        color: '#95E1D3',
        creationDate: now,
        lastUpdate: now,
      ),
      SpendingCategory(
        id: '4',
        name: 'Saúde',
        value: 'health',
        icon: 'health',
        color: '#FF8B94',
        creationDate: now,
        lastUpdate: now,
      ),
      SpendingCategory(
        id: '5',
        name: 'Educação',
        value: 'education',
        icon: 'education',
        color: '#6C5CE7',
        creationDate: now,
        lastUpdate: now,
      ),
      SpendingCategory(
        id: '6',
        name: 'Lazer',
        value: 'leisure',
        icon: 'entertainment',
        color: '#FD79A8',
        creationDate: now,
        lastUpdate: now,
      ),
      SpendingCategory(
        id: '7',
        name: 'Compras',
        value: 'shopping',
        icon: 'shoppingBags',
        color: '#FCBAD3',
        creationDate: now,
        lastUpdate: now,
      ),
      SpendingCategory(
        id: '8',
        name: 'Contas',
        value: 'bills',
        icon: 'bills',
        color: '#74B9FF',
        creationDate: now,
        lastUpdate: now,
      ),
    ];
  }
}

