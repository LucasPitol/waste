import 'package:flutter/material.dart';
import 'package:meudin_ai_app/ui/app_icons.dart';

class SpendingCategory {
  final String id;
  final String name;
  final String value;
  final String? icon; // String do backend (ex: "food", "shoppingBags")
  final String? color; // Hex string do backend (ex: "#FF6B6B")
  final String type; // "personal" ou "business"
  final DateTime creationDate;
  final DateTime lastUpdate;

  // Computed properties para UI
  IconData get iconData => _getIconFromString(icon?.isNotEmpty == true ? icon! : value);
  Color get colorData => _getColorFromString(color ?? '#B2BEC3');

  SpendingCategory({
    required this.id,
    required this.name,
    required this.value,
    this.icon,
    this.color,
    required this.type,
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
    final String type = data['type']?.toString() ?? 'personal'; // Default para 'personal' se não vier
    
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
      type: type,
      creationDate: creationDate,
      lastUpdate: lastUpdate,
    );
  }

  /// Mapeia string de ícone do backend para IconData do Phosphor
  static IconData _getIconFromString(String iconString) {
    if (iconString.isEmpty) {
      return AppIcons.circleQuestion;
    }
    
    final iconMap = {
      // Alimentação
      'food': AppIcons.utensils,
      
      // Compras/Shopping
      'shoppingbags': AppIcons.shoppingBag,
      'shopping': AppIcons.shoppingBag,
      'shoppingcart': AppIcons.cartShopping,
      'compras': AppIcons.shoppingBag,
      
      // Investimento
      'investment': AppIcons.chartLine,
      'investimento': AppIcons.chartLine,
      'investments': AppIcons.chartLine,
      'stocks': AppIcons.arrowTrendUp,
      'stonks': AppIcons.arrowTrendUp,
      'chart': AppIcons.chartLine,
      
      // Educação
      'education': AppIcons.book,
      'educacao': AppIcons.book,
      'school': AppIcons.graduationCap,
      'book': AppIcons.book,
      'books': AppIcons.book,
      'livros': AppIcons.book,
      'bookopen': AppIcons.bookOpen,
      
      // Salário
      'salary': AppIcons.moneyBillWave,
      'salario': AppIcons.moneyBillWave,
      'income': AppIcons.moneyBillWave,
      'wage': AppIcons.moneyBillWave,
      'money': AppIcons.moneyBill,
      'wallet': AppIcons.wallet,
      'coins': AppIcons.coins,
      
      // Transporte
      'transport': AppIcons.bus,
      'transporte': AppIcons.bus,
      'car': AppIcons.car,
      'vehicle': AppIcons.car,
      'veiculo': AppIcons.car,
      'bus': AppIcons.bus,
      'train': AppIcons.train,
      'bicycle': AppIcons.bicycle,
      'motorcycle': AppIcons.motorcycle,
      'taxi': AppIcons.taxi,
      
      // Moradia
      'house': AppIcons.house,
      'home': AppIcons.house,
      'housing': AppIcons.house,
      'moradia': AppIcons.house,
      
      // Saúde
      'health': AppIcons.heartPulse,
      'saude': AppIcons.heartPulse,
      'medical': AppIcons.heartPulse,
      
      // Lazer/Entretenimento
      'entertainment': AppIcons.gamepad,
      'leisure': AppIcons.gamepad,
      'lazer': AppIcons.gamepad,
      
      // Contas/Utilidades
      'bills': AppIcons.fileInvoiceDollar,
      'contas': AppIcons.fileInvoiceDollar,
      'utilities': AppIcons.fileInvoiceDollar,
      
      // Categorias Empresariais (Business)
      'boxes-stacked': AppIcons.boxesStacked,
      'materials': AppIcons.boxesStacked,
      'material': AppIcons.boxesStacked,
      'file-invoice-dollar': AppIcons.fileInvoiceDollar,
      'taxes': AppIcons.fileInvoiceDollar,
      'impostos': AppIcons.fileInvoiceDollar,
      'bullhorn': AppIcons.bullhorn,
      'marketing': AppIcons.bullhorn,
      'user-gear': AppIcons.userGear,
      'outsourcing': AppIcons.userGear,
      'servicos-terceirizados': AppIcons.userGear,
      'cloud': AppIcons.cloud,
      'nuvem': AppIcons.cloud,
      'internet': AppIcons.wifi,
      'wifi': AppIcons.wifi,
      'screwdriver-wrench': AppIcons.screwdriverWrench,
      'tools': AppIcons.screwdriverWrench,
      'ferramentas': AppIcons.screwdriverWrench,
      'credit-card': AppIcons.creditCard,
      'fees': AppIcons.creditCard,
      'tarifas': AppIcons.creditCard,
      'truck': AppIcons.truck,
      'logistics': AppIcons.truck,
      'logistica': AppIcons.truck,
      'handshake': AppIcons.handshake,
      'commission': AppIcons.handshake,
      'comissao': AppIcons.handshake,
      
      // Outros
      'box': AppIcons.box,
      'pet': AppIcons.paw,
      'travel': AppIcons.planeDeparture,
      'viagem': AppIcons.planeDeparture,
      'fitness': AppIcons.dumbbell,
      'gym': AppIcons.dumbbell,
      'academia': AppIcons.dumbbell,
      'beauty': AppIcons.scissors,
      'beleza': AppIcons.scissors,
      'electronics': AppIcons.mobileScreen,
      'eletronicos': AppIcons.mobileScreen,
      'gift': AppIcons.gift,
      'presente': AppIcons.gift,
      'subscription': AppIcons.tv,
      'streaming': AppIcons.tv,
      'assinatura': AppIcons.tv,
      'others': AppIcons.circleQuestion,
      'outros': AppIcons.circleQuestion,
      'other': AppIcons.box,
    };

    final lowerIcon = iconString.toLowerCase();
    return iconMap[lowerIcon] ?? AppIcons.circleQuestion;
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
        'type': type,
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
        type: 'personal',
        creationDate: now,
        lastUpdate: now,
      ),
      SpendingCategory(
        id: '2',
        name: 'Transporte',
        value: 'transport',
        icon: 'car',
        color: '#4ECDC4',
        type: 'personal',
        creationDate: now,
        lastUpdate: now,
      ),
      SpendingCategory(
        id: '3',
        name: 'Moradia',
        value: 'house',
        icon: 'house',
        color: '#95E1D3',
        type: 'personal',
        creationDate: now,
        lastUpdate: now,
      ),
      SpendingCategory(
        id: '4',
        name: 'Saúde',
        value: 'health',
        icon: 'health',
        color: '#FF8B94',
        type: 'personal',
        creationDate: now,
        lastUpdate: now,
      ),
      SpendingCategory(
        id: '5',
        name: 'Educação',
        value: 'education',
        icon: 'education',
        color: '#6C5CE7',
        type: 'personal',
        creationDate: now,
        lastUpdate: now,
      ),
      SpendingCategory(
        id: '6',
        name: 'Lazer',
        value: 'leisure',
        icon: 'entertainment',
        color: '#FD79A8',
        type: 'personal',
        creationDate: now,
        lastUpdate: now,
      ),
      SpendingCategory(
        id: '7',
        name: 'Compras',
        value: 'shopping',
        icon: 'shoppingBags',
        color: '#FCBAD3',
        type: 'personal',
        creationDate: now,
        lastUpdate: now,
      ),
      SpendingCategory(
        id: '8',
        name: 'Contas',
        value: 'bills',
        icon: 'bills',
        color: '#74B9FF',
        type: 'personal',
        creationDate: now,
        lastUpdate: now,
      ),
    ];
  }
}

