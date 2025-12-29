import 'dart:async';
import 'package:flutter/material.dart';
import 'package:meudin_ai_app/services/transaction_service.dart';
import 'package:meudin_ai_app/models/dtos/response_dto.dart';
import 'package:meudin_ai_app/services/user_service.dart';
import 'package:meudin_ai_app/models/transaction.dart';
import 'package:meudin_ai_app/models/wallet.dart';
import 'package:meudin_ai_app/models/user.dart';
import 'package:meudin_ai_app/models/category_expense.dart';
import 'package:meudin_ai_app/models/spending_category.dart';
import 'package:meudin_ai_app/services/spending_category_service.dart';
import 'package:get/get.dart';
import 'package:meudin_ai_app/services/wallet_service.dart';
import 'package:meudin_ai_app/services/session_service.dart';
import 'package:meudin_ai_app/services/local_storage_service.dart';
import 'package:meudin_ai_app/services/cache_service.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';

class InsightsModuleController extends GetxController {
  User? _user;
  late Wallet currentWallet;
  late bool isWalletOwner;
  late bool loading;
  late double revenue;
  late double spends;
  late double balance;
  late DateTime startDate;
  late DateTime endDate;
  late List<Transaction> transactionDtoList;
  late TransactionService _transactionService;
  late WalletService _walletService;
  late UserService _userService;
  late SpendingCategoryService _spendingCategoryService;
  late CacheService _cacheService;
  late bool isRefreshing;
  List<SpendingCategory> _categories = [];
  List<CategoryExpense> _categoryExpenses = [];
  
  // Dados para comparação
  double? previousPeriodSpends;
  double? monthlyAverageSpends;

  InsightsModuleController() {
    _userService = UserService();
    _user = _userService.getCurrentUser();
    
    currentWallet = _user!.walletList
        .singleWhere((element) => element.id == _user!.currentWalletId);
    
    isWalletOwner = (currentWallet.ownerId == _user!.id);
    
    revenue = 0.0;
    spends = 0.0;
    balance = 0.0;
    transactionDtoList = [];
    _transactionService = TransactionService();
    _walletService = WalletService();
    _spendingCategoryService = SpendingCategoryService();
    _cacheService = CacheService();
    loading = false;
    isRefreshing = false;
    previousPeriodSpends = null;
    monthlyAverageSpends = null;
  }

  @override
  void onInit() {
    super.onInit();
    _fillDefaultDates();
    _fetchCategories();
    _restoreLastSelectedWallet();
  }

  /// Restaura a última carteira selecionada do local storage antes de buscar transações
  Future<void> _restoreLastSelectedWallet() async {
    try {
      final localStorageService = LocalStorageService();
      final storedUser = await localStorageService.getUserData();
      
      if (storedUser != null && storedUser.currentWalletId.isNotEmpty) {
        final walletExists = _user!.walletList.any(
          (wallet) => wallet.id == storedUser.currentWalletId,
        );
        
        if (walletExists) {
          if (_user!.currentWalletId != storedUser.currentWalletId) {
            _user!.currentWalletId = storedUser.currentWalletId;
            UserService.currentUser!.currentWalletId = storedUser.currentWalletId;
            
            currentWallet = _user!.walletList
                .singleWhere((element) => element.id == storedUser.currentWalletId);
            isWalletOwner = (currentWallet.ownerId == _user!.id);
          }
        }
      }
    } catch (e) {
      // Se houver erro ao ler do storage, continua com a carteira atual
    }
    
    refreshAll();
  }

  Future<void> _fetchCategories() async {
    final res = await _spendingCategoryService.getSpendingCategories();
    if (res.success && res.data is List) {
      _categories = (res.data as List)
          .map<SpendingCategory>((e) => SpendingCategory.fromApi(e))
          .toList();
    }
  }

  List<CategoryExpense> get categoryExpenses => _categoryExpenses;
  List<SpendingCategory> get categories => _categories;

  /// Define datas padrão: 01/01 do ano corrente até hoje
  void _fillDefaultDates() {
    DateTime now = DateTime.now();
    startDate = DateTime(now.year, 1, 1);
    endDate = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
  }

  /// Calcula gastos por categoria usando os dados já carregados
  void _calculateCategoryExpenses() {
    final expenses = transactionDtoList
        .where((t) => t.amount != null && t.amount! < 0 && t.categoryId != null)
        .toList();

    if (expenses.isEmpty) {
      _categoryExpenses = [];
      return;
    }

    final Map<String, double> totalByCategory = {};
    
    for (var transaction in expenses) {
      final categoryId = transaction.categoryId!;
      final amount = transaction.amount!.abs();
      totalByCategory[categoryId] = (totalByCategory[categoryId] ?? 0.0) + amount;
    }

    final double totalAmount = totalByCategory.values.fold(0.0, (sum, value) => sum + value);

    if (totalAmount == 0) {
      _categoryExpenses = [];
      return;
    }

    _categoryExpenses = totalByCategory.entries.map((entry) {
      final categoryId = entry.key;
      final amount = entry.value;
      final percentage = (amount / totalAmount) * 100;

      final category = _categories.firstWhere(
        (cat) => cat.id == categoryId,
        orElse: () => SpendingCategory(
          id: categoryId,
          name: 'Outro',
          value: 'other',
          creationDate: DateTime.now(),
          lastUpdate: DateTime.now(),
        ),
      );

      return CategoryExpense(
        categoryId: categoryId,
        categoryName: category.name,
        categoryColor: category.colorData,
        amount: amount,
        percentage: percentage,
      );
    }).toList();

    _categoryExpenses.sort((a, b) => b.amount.compareTo(a.amount));
    
    if (_categoryExpenses.length > 4) {
      final topCategories = _categoryExpenses.take(4).toList();
      final others = _categoryExpenses.skip(4);
      
      final othersTotal = others.fold(0.0, (sum, cat) => sum + cat.amount);
      final othersPercentage = (othersTotal / totalAmount) * 100;

      if (othersTotal > 0) {
        topCategories.add(CategoryExpense(
          categoryId: 'others',
          categoryName: 'Outros',
          categoryColor: Colors.grey,
          amount: othersTotal,
          percentage: othersPercentage,
        ));
      }

      _categoryExpenses = topCategories;
    }
    
    if (_categoryExpenses.isNotEmpty) {
      final totalPercentage = _categoryExpenses.fold(0.0, (sum, e) => sum + e.percentage);
      final difference = 100.0 - totalPercentage;
      if (difference.abs() > 0.001) {
        final lastIndex = _categoryExpenses.length - 1;
        _categoryExpenses[lastIndex] = CategoryExpense(
          categoryId: _categoryExpenses[lastIndex].categoryId,
          categoryName: _categoryExpenses[lastIndex].categoryName,
          categoryColor: _categoryExpenses[lastIndex].categoryColor,
          amount: _categoryExpenses[lastIndex].amount,
          percentage: _categoryExpenses[lastIndex].percentage + difference,
        );
      }
    }
  }

  /// Calcula a média mensal de despesas
  void _calculateMonthlyAverage() {
    if (spends == 0) {
      monthlyAverageSpends = 0.0;
      return;
    }

    // Filtra apenas despesas (valores negativos)
    final expenses = transactionDtoList
        .where((t) => t.amount != null && t.amount! < 0 && t.transactionDate != null)
        .toList();

    if (expenses.isEmpty) {
      monthlyAverageSpends = 0.0;
      return;
    }

    // Ordena por data (mais antiga primeiro)
    expenses.sort((a, b) => a.transactionDate!.compareTo(b.transactionDate!));

    // Encontra a transação mais próxima do startDate (primeira transação no período)
    final firstTransactionDate = expenses.first.transactionDate!;
    
    // Encontra a última transação no período
    final lastTransactionDate = expenses.last.transactionDate!;

    // Calcula diferença em meses entre a primeira e última transação (meses com dados reais)
    final monthsDifference = _calculateMonthsDifference(firstTransactionDate, lastTransactionDate);
    
    // Se período for menor que 1 mês, considera pelo menos 1 mês para cálculo
    final effectiveMonths = monthsDifference < 1.0 ? 1.0 : monthsDifference;
    monthlyAverageSpends = spends.abs() / effectiveMonths;
  }

  /// Calcula diferença em meses entre duas datas
  double _calculateMonthsDifference(DateTime start, DateTime end) {
    final yearsDiff = end.year - start.year;
    final monthsDiff = end.month - start.month;
    final daysDiff = end.day - start.day;
    
    // Aproximação: considera meses completos + fração do mês atual
    final totalMonths = yearsDiff * 12 + monthsDiff;
    final fractionOfMonth = daysDiff / 30.0; // Aproximação
    
    return totalMonths + fractionOfMonth;
  }

  /// Calcula comparativo com período anterior (se período >= 2 meses)
  Future<void> _calculateComparison() async {
    final monthsDifference = _calculateMonthsDifference(startDate, endDate);
    
    if (monthsDifference < 2) {
      previousPeriodSpends = null;
      return;
    }

    // Calcula período anterior (mesma duração, antes do startDate)
    final periodDuration = endDate.difference(startDate);
    final previousEndDate = startDate.subtract(const Duration(days: 1));
    final previousStartDate = previousEndDate.subtract(periodDuration);

    try {
      String walletId = currentWallet.id;
      ResponseDto res = await _transactionService.getTransactionDtoList(
        walletId,
        previousStartDate,
        previousEndDate,
      );

      if (res.success && res.data.isNotEmpty) {
        final previousTransactions = res.data
            .map<Transaction>((e) => Transaction.fromJson(e))
            .toList();

        double previousSpendsTemp = 0.0;
        for (var transaction in previousTransactions) {
          if (transaction.amount != null && transaction.amount! < 0) {
            previousSpendsTemp += transaction.amount!.abs();
          }
        }
        previousPeriodSpends = previousSpendsTemp;
      } else {
        previousPeriodSpends = null;
      }
    } catch (e) {
      previousPeriodSpends = null;
    }
  }

  /// Abre bottom sheet para seleção de intervalo de datas
  Future<void> openDateRangePicker() async {
    final theme = Theme.of(Get.context!);
    final result = await Get.bottomSheet<Map<String, DateTime>>(
      _DateRangePickerBottomSheet(
        initialStartDate: startDate,
        initialEndDate: endDate,
      ),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.transparent,
    );

    if (result != null) {
      final newStartDate = result['start']!;
      final newEndDate = result['end']!;
      
      // Verifica se as datas realmente mudaram antes de invalidar o cache
      final datesChanged = newStartDate != startDate || newEndDate != endDate;
      
      startDate = newStartDate;
      endDate = newEndDate;
      
      // Se as datas mudaram, invalida o cache para forçar busca com as novas datas
      if (datesChanged) {
        await _cacheService.invalidateCache('insights', currentWallet.id);
      }
      
      update();
      await refreshAll();
    }
  }

  /// Limpa filtros (volta para padrão: 01/01 do ano corrente até hoje)
  Future<void> clearFilters() async {
    _fillDefaultDates();
    // Invalida o cache ao limpar filtros para garantir dados atualizados
    await _cacheService.invalidateCache('insights', currentWallet.id);
    update();
    await refreshAll();
  }

  /// Complete refresh - busca transações e calcula todos os dados
  /// [forceRefresh] força busca na API mesmo com cache válido (pull to refresh)
  Future<void> refreshAll({bool forceRefresh = false}) async {
    isRefreshing = true;
    update();
    
    try {
      await refreshUserAndWallet();
      await updatePageData(forceRefresh: forceRefresh);
    } finally {
      isRefreshing = false;
      update();
    }
  }

  Future<void> refreshUserAndWallet() async {
    try {
      await _walletService.getUserWallets();
      _user = UserService.currentUser;

      currentWallet = _user!.walletList
          .singleWhere((element) => element.id == _user!.currentWalletId);
      isWalletOwner = (currentWallet.ownerId == _user!.id);
    } catch (e) {
      // Handle wallet loading error silently
    }
  }

  /// Carrega dados da página, usando cache quando disponível
  /// [forceRefresh] força busca na API mesmo com cache válido (pull to refresh)
  Future<void> updatePageData({bool forceRefresh = false}) async {
    try {
      if (_categories.isEmpty) {
        await _fetchCategories();
      }

      String walletId = currentWallet.id;
      List<Map<String, dynamic>>? cachedData;
      
      // Verifica cache apenas se não for refresh forçado
      if (!forceRefresh) {
        cachedData = await _cacheService.getCache('insights', walletId);
      }
      
      // Se tem cache válido, usa ele SEM mostrar loading
      if (cachedData != null && cachedData.isNotEmpty && !forceRefresh) {
        try {
          // Processa dados do cache
          transactionDtoList = cachedData
              .map<Transaction>((e) => Transaction.fromJson(e))
              .toList();

          transactionDtoList.sort((a, b) {
            if (a.transactionDate == null && b.transactionDate == null) return 0;
            if (a.transactionDate == null) return 1;
            if (b.transactionDate == null) return -1;
            return b.transactionDate!.compareTo(a.transactionDate!);
          });

          // Calcula KPIs
          double totalRevenueTemp = 0;
          double totalSpendTemp = 0;

          for (var element in transactionDtoList) {
            double amount = element.amount!;

            if (amount > 0) {
              totalRevenueTemp = totalRevenueTemp + amount;
            } else {
              totalSpendTemp = totalSpendTemp + amount;
            }
          }

          revenue = totalRevenueTemp;
          spends = totalSpendTemp;
          balance = totalRevenueTemp + totalSpendTemp;

          // Calcula gastos por categoria
          _calculateCategoryExpenses();
          
          // Calcula média mensal
          _calculateMonthlyAverage();
          
          // Calcula comparativo (sempre busca da API pois depende de período anterior)
          await _calculateComparison();
          
          // Não precisa setar loading/isRefreshing pois nunca foram setados
          update();
          return; // Retorna sem fazer request à API
        } catch (e) {
          // Se houver erro ao processar cache, invalida e busca da API
          await _cacheService.invalidateCache('insights', walletId);
          // Continua para buscar da API
        }
      }

      // Se não tem cache válido ou forceRefresh, busca da API
      // Apenas agora mostra loading
      loading = true;
      isRefreshing = true;
      update();

      ResponseDto res = await _transactionService.getTransactionDtoList(
        walletId,
        startDate,
        endDate,
      );

      loading = false;
      isRefreshing = false;
      
      if (res.success) {
        // Converte dados para lista de Map para salvar no cache
        List<Map<String, dynamic>> dataList = [];
        if (res.data is List && (res.data as List).isNotEmpty) {
          dataList = (res.data as List)
              .map((e) => e as Map<String, dynamic>)
              .toList();
        }
        
        // Salva no cache
        await _cacheService.saveCache('insights', walletId, dataList);
        
        // Processa dados para UI
        transactionDtoList = dataList
            .map<Transaction>((e) => Transaction.fromJson(e))
            .toList();

        transactionDtoList.sort((a, b) {
          if (a.transactionDate == null && b.transactionDate == null) return 0;
          if (a.transactionDate == null) return 1;
          if (b.transactionDate == null) return -1;
          return b.transactionDate!.compareTo(a.transactionDate!);
        });

        // Calcula KPIs
        double totalRevenueTemp = 0;
        double totalSpendTemp = 0;

        for (var element in transactionDtoList) {
          double amount = element.amount!;

          if (amount > 0) {
            totalRevenueTemp = totalRevenueTemp + amount;
          } else {
            totalSpendTemp = totalSpendTemp + amount;
          }
        }

        revenue = totalRevenueTemp;
        spends = totalSpendTemp;
        balance = totalRevenueTemp + totalSpendTemp;

        // Calcula gastos por categoria
        _calculateCategoryExpenses();
        
        // Calcula média mensal
        _calculateMonthlyAverage();
        
        // Calcula comparativo
        await _calculateComparison();
      } else {
        JoyModal.bottomSheetError(
          context: Get.context!,
          errorList: [res.errorMessage!],
          title: 'Erro ao carregar transações',
        );
      }
    } catch (e) {
      loading = false;
      isRefreshing = false;
      
      JoyModal.bottomSheetError(
        context: Get.context!,
        errorList: ['Erro ao carregar dados: $e'],
        title: 'Erro',
      );
    } finally {
      loading = false;
      isRefreshing = false;
      update();
    }
  }

  /// Retorna se há dados para exibir
  bool get hasData => transactionDtoList.isNotEmpty;
  
  /// Retorna se o período é >= 2 meses
  bool get canShowComparison {
    final monthsDifference = _calculateMonthsDifference(startDate, endDate);
    return monthsDifference >= 2 && previousPeriodSpends != null;
  }
  
  /// Retorna percentual de variação (positivo = aumento, negativo = redução)
  double? get comparisonPercentage {
    if (!canShowComparison || previousPeriodSpends == null || previousPeriodSpends == 0) {
      return null;
    }
    
    final currentSpends = spends.abs();
    final difference = currentSpends - previousPeriodSpends!;
    return (difference / previousPeriodSpends!) * 100;
  }
}

/// Bottom sheet para seleção de intervalo de datas
class _DateRangePickerBottomSheet extends StatefulWidget {
  final DateTime initialStartDate;
  final DateTime initialEndDate;

  const _DateRangePickerBottomSheet({
    required this.initialStartDate,
    required this.initialEndDate,
  });

  @override
  State<_DateRangePickerBottomSheet> createState() => _DateRangePickerBottomSheetState();
}

class _DateRangePickerBottomSheetState extends State<_DateRangePickerBottomSheet> {
  late DateTime selectedStartDate;
  late DateTime selectedEndDate;

  @override
  void initState() {
    super.initState();
    selectedStartDate = widget.initialStartDate;
    selectedEndDate = widget.initialEndDate;
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedStartDate,
      firstDate: DateTime(2000),
      lastDate: selectedEndDate,
    );
    if (picked != null) {
      setState(() {
        selectedStartDate = picked;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedEndDate,
      firstDate: selectedStartDate,
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedEndDate = DateTime(picked.year, picked.month, picked.day, 23, 59, 59, 999);
      });
    }
  }

  void _confirmSelection() {
    Get.back(result: {
      'start': selectedStartDate,
      'end': selectedEndDate,
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark 
            ? theme.colorScheme.surface 
            : Styles.whiteColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 4),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? Colors.grey.shade700
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selecione o período',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Filtre suas transações por intervalo',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6) 
                          ?? Colors.grey.shade600,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            // Date pickers
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _DatePickerField(
                    label: 'Data inicial',
                    date: selectedStartDate,
                    onTap: _selectStartDate,
                  ),
                  const SizedBox(height: 16),
                  _DatePickerField(
                    label: 'Data final',
                    date: selectedEndDate,
                    onTap: _selectEndDate,
                  ),
                ],
              ),
            ),
            // Confirm Button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _confirmSelection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Styles.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Confirmar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DatePickerField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.brightness == Brightness.dark
                ? Colors.grey.shade700
                : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6) 
                        ?? Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.calendar_today,
              size: 20,
              color: Styles.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
