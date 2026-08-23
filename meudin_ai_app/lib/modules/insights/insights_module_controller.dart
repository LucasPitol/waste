import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
import 'package:meudin_ai_app/services/local_storage_service.dart';
import 'package:meudin_ai_app/services/cache_service.dart';
import 'package:meudin_ai_app/services/subscription_state_service.dart';
import 'package:meudin_ai_app/modules/insights/widgets/date_filter_header.dart';
import 'package:meudin_ai_app/utils/expense_category_visuals.dart';
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
  late SubscriptionStateService _subscriptionStateService;
  late bool isRefreshing;
  List<SpendingCategory> _categories = [];
  List<CategoryExpense> _categoryExpenses = [];
  
  // Dados para comparação
  double? previousPeriodSpends;
  double? monthlyAverageSpends;
  double? monthlyAverageRevenue;
  String? _planLimitNoticeKey;

  static const String _planLimitMessage =
      'Seu plano limita o histórico de transações disponível. '
      'Faça upgrade para consultar períodos maiores.';

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
    _subscriptionStateService = SubscriptionStateService();
    loading = false;
    isRefreshing = false;
    previousPeriodSpends = null;
    monthlyAverageSpends = null;
    monthlyAverageRevenue = null;
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

  /// Define datas padrão: últimos 3 meses até hoje
  void _fillDefaultDates() {
    final range = _dateRangeForPreset(InsightsDatePreset.last3Months);
    startDate = range.$1;
    endDate = range.$2;
  }

  (DateTime, DateTime) _dateRangeForPreset(InsightsDatePreset preset) {
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    switch (preset) {
      case InsightsDatePreset.last3Months:
        // 3 meses incluindo o mês atual (ex: ago → jun, jul, ago)
        return (DateTime(now.year, now.month - 2, 1), end);
      case InsightsDatePreset.last6Months:
        // 6 meses incluindo o mês atual (ex: ago → mar … ago)
        return (DateTime(now.year, now.month - 5, 1), end);
      case InsightsDatePreset.thisYear:
        return (DateTime(now.year, 1, 1), end);
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  InsightsDatePreset? get activeDatePreset {
    for (final preset in InsightsDatePreset.values) {
      final range = _dateRangeForPreset(preset);
      if (_isSameDay(startDate, range.$1) && _isSameDay(endDate, range.$2)) {
        return preset;
      }
    }
    return null;
  }

  Future<void> applyDatePreset(InsightsDatePreset preset) async {
    final range = _dateRangeForPreset(preset);
    final newStartDate = range.$1;
    final newEndDate = range.$2;

    final datesChanged = !_isSameDay(newStartDate, startDate) ||
        !_isSameDay(newEndDate, endDate);

    startDate = newStartDate;
    endDate = newEndDate;

    if (!datesChanged) return;

    _resetPlanLimitNoticeKey();
    await _cacheService.invalidateCache('insights', currentWallet.id);

    update();
    await refreshAll();
  }

  DateTime? _parseApiDate(String? value) {
    if (value == null || value.isEmpty) return null;
    final parts = value.split('-');
    if (parts.length != 3) return null;
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  String _formatCacheDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> _buildCacheMetadata({
    required DateTime requestedStart,
    required DateTime requestedEnd,
    required bool wasAdjusted,
    String? effectiveStartDate,
    String? effectiveEndDate,
  }) {
    return {
      'requestedStartDate': _formatCacheDate(requestedStart),
      'requestedEndDate': _formatCacheDate(requestedEnd),
      'wasAdjusted': wasAdjusted,
      if (effectiveStartDate != null) 'effectiveStartDate': effectiveStartDate,
      if (effectiveEndDate != null) 'effectiveEndDate': effectiveEndDate,
    };
  }

  bool _matchesRequestedDateRange(Map<String, dynamic> metadata) {
    return metadata['requestedStartDate'] == _formatCacheDate(startDate) &&
        metadata['requestedEndDate'] == _formatCacheDate(endDate);
  }

  bool _wasUserPeriodAdjusted({
    required DateTime requestedStart,
    required DateTime requestedEnd,
    required bool wasAdjusted,
    String? effectiveStartDate,
    String? effectiveEndDate,
  }) {
    if (!wasAdjusted) return false;

    final effectiveStart = _parseApiDate(effectiveStartDate);
    final effectiveEnd = _parseApiDate(effectiveEndDate);
    if (effectiveStart == null && effectiveEnd == null) return true;

    final requestedStartNorm = _normalizeDate(requestedStart);
    final requestedEndNorm = _normalizeDate(requestedEnd);

    if (effectiveStart != null &&
        _normalizeDate(effectiveStart).isAfter(requestedStartNorm)) {
      return true;
    }

    if (effectiveEnd != null &&
        _normalizeDate(effectiveEnd).isBefore(requestedEndNorm)) {
      return true;
    }

    return false;
  }

  void _applyEffectiveDatesFromMetadata(Map<String, dynamic> metadata) {
    final requestedStart = _parseApiDate(metadata['requestedStartDate'] as String?);
    final requestedEnd = _parseApiDate(metadata['requestedEndDate'] as String?);
    if (requestedStart == null || requestedEnd == null) return;

    final wasUserAdjusted = _wasUserPeriodAdjusted(
      requestedStart: requestedStart,
      requestedEnd: requestedEnd,
      wasAdjusted: metadata['wasAdjusted'] == true,
      effectiveStartDate: metadata['effectiveStartDate'] as String?,
      effectiveEndDate: metadata['effectiveEndDate'] as String?,
    );
    if (!wasUserAdjusted) return;

    final effectiveStart = _parseApiDate(metadata['effectiveStartDate'] as String?);
    final effectiveEnd = _parseApiDate(metadata['effectiveEndDate'] as String?);

    if (effectiveStart != null) {
      startDate = effectiveStart;
    }
    if (effectiveEnd != null) {
      endDate = DateTime(
        effectiveEnd.year,
        effectiveEnd.month,
        effectiveEnd.day,
        23,
        59,
        59,
        999,
      );
    }
  }

  void _applyDateRangeMetadata(
    ResponseDto res, {
    required DateTime requestedStart,
    required DateTime requestedEnd,
  }) {
    if (!_wasUserPeriodAdjusted(
      requestedStart: requestedStart,
      requestedEnd: requestedEnd,
      wasAdjusted: res.wasAdjusted,
      effectiveStartDate: res.effectiveStartDate,
      effectiveEndDate: res.effectiveEndDate,
    )) {
      return;
    }

    final effectiveStart = _parseApiDate(res.effectiveStartDate);
    final effectiveEnd = _parseApiDate(res.effectiveEndDate);

    if (effectiveStart != null) {
      startDate = effectiveStart;
    }
    if (effectiveEnd != null) {
      endDate = DateTime(
        effectiveEnd.year,
        effectiveEnd.month,
        effectiveEnd.day,
        23,
        59,
        59,
        999,
      );
    }
  }

  String _planLimitNoticeKeyFor({
    required String walletId,
    required DateTime requestedStart,
    required DateTime requestedEnd,
  }) {
    return '$walletId|${_formatCacheDate(requestedStart)}|${_formatCacheDate(requestedEnd)}';
  }

  void _resetPlanLimitNoticeKey() {
    _planLimitNoticeKey = null;
  }

  void _maybeShowPlanLimitBottomSheet({
    required bool wasUserAdjusted,
    required String walletId,
    required DateTime requestedStart,
    required DateTime requestedEnd,
  }) {
    if (!wasUserAdjusted) return;

    final noticeKey = _planLimitNoticeKeyFor(
      walletId: walletId,
      requestedStart: requestedStart,
      requestedEnd: requestedEnd,
    );
    if (_planLimitNoticeKey == noticeKey) return;
    _planLimitNoticeKey = noticeKey;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = Get.context;
      if (context == null) return;

      Get.bottomSheet(
        JoyModal.limitReachedBottomSheet(
          context: context,
          title: 'Limite do plano',
          message: _planLimitMessage,
        ),
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        backgroundColor: Colors.transparent,
      );
    });
  }

  void _applyTransactionsFromRawData(List<Map<String, dynamic>> dataList) {
    final allTransactions = dataList
        .map<Transaction>((e) => Transaction.fromJson(e))
        .toList();

    transactionDtoList = allTransactions
        .where(
          (transaction) =>
              transaction.transactionDate != null &&
              _isDateInRange(transaction.transactionDate!, startDate, endDate),
        )
        .toList();

    transactionDtoList.sort((a, b) {
      if (a.transactionDate == null && b.transactionDate == null) return 0;
      if (a.transactionDate == null) return 1;
      if (b.transactionDate == null) return -1;
      return b.transactionDate!.compareTo(a.transactionDate!);
    });

    double totalRevenueTemp = 0;
    double totalSpendTemp = 0;

    for (var element in transactionDtoList) {
      final amount = element.amount!;
      if (amount > 0) {
        totalRevenueTemp += amount;
      } else {
        totalSpendTemp += amount;
      }
    }

    revenue = totalRevenueTemp;
    spends = totalSpendTemp;
    balance = totalRevenueTemp + totalSpendTemp;

    _calculateCategoryExpenses();
    _calculateMonthlyAverages();
  }

  /// Calcula gastos por categoria usando os dados já carregados
  void _calculateCategoryExpenses() {
    _categoryExpenses = ExpenseCategoryVisuals.calculateChartCategories(
      transactions: transactionDtoList,
      categories: _categories,
    );
  }

  /// Calcula médias mensais de despesas e receitas com base nas transações já carregadas
  void _calculateMonthlyAverages() {
    monthlyAverageSpends = _calculateMonthlyAverageForType(isRevenue: false);
    monthlyAverageRevenue = _calculateMonthlyAverageForType(isRevenue: true);
  }

  double _calculateMonthlyAverageForType({required bool isRevenue}) {
    final total = isRevenue ? revenue : spends.abs();
    if (total == 0) return 0.0;

    final monthCount = _countCalendarMonthsInPeriod(startDate, endDate);
    if (monthCount == 0) return 0.0;

    return total / monthCount;
  }

  int _countCalendarMonthsInPeriod(DateTime start, DateTime end) {
    return (end.year - start.year) * 12 + (end.month - start.month) + 1;
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool _isDateInRange(DateTime date, DateTime start, DateTime end) {
    final normalized = _normalizeDate(date);
    final rangeStart = _normalizeDate(start);
    final rangeEnd = _normalizeDate(end);
    return !normalized.isBefore(rangeStart) && !normalized.isAfter(rangeEnd);
  }

  (DateTime, DateTime)? _previousPeriodRange() {
    final monthCount = _countCalendarMonthsInPeriod(startDate, endDate);
    if (monthCount < 2) return null;

    final previousStart =
        DateTime(startDate.year, startDate.month - monthCount, 1);
    final previousEndDay =
        _normalizeDate(startDate).subtract(const Duration(days: 1));
    final previousEnd = DateTime(
      previousEndDay.year,
      previousEndDay.month,
      previousEndDay.day,
      23,
      59,
      59,
      999,
    );
    return (previousStart, previousEnd);
  }

  /// Comparativo exige o período anterior além do filtro atual.
  /// Ex.: filtro 3 meses → ~6 meses de histórico; Free (3 meses) não cobre.
  Future<bool> _canLoadComparisonForPlan() async {
    final range = _previousPeriodRange();
    if (range == null) return false;

    final maxHistoryMonths =
        await _subscriptionStateService.getMaxHistoryMonths();
    if (maxHistoryMonths == null) return true;

    final monthCount = _countCalendarMonthsInPeriod(startDate, endDate);
    return monthCount * 2 <= maxHistoryMonths;
  }

  Future<void> _loadPreviousPeriodSpends() async {
    previousPeriodSpends = null;

    if (!await _canLoadComparisonForPlan()) {
      return;
    }

    final range = _previousPeriodRange();
    if (range == null) {
      return;
    }

    try {
      final res = await _transactionService.getTransactionDtoList(
        currentWallet.id,
        range.$1,
        range.$2,
      );

      if (!res.success || res.data is! List) {
        previousPeriodSpends = null;
        return;
      }

      var total = 0.0;
      for (final item in res.data as List) {
        final transaction =
            Transaction.fromJson(item as Map<String, dynamic>);
        if (transaction.amount != null && transaction.amount! < 0) {
          total += transaction.amount!.abs();
        }
      }
      previousPeriodSpends = total;
    } catch (_) {
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
        _resetPlanLimitNoticeKey();
        await _cacheService.invalidateCache('insights', currentWallet.id);
      }
      
      update();
      await refreshAll();
    }
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
      final previousWalletId = currentWallet.id;
      await _walletService.getUserWallets();
      _user = UserService.currentUser;

      currentWallet = _user!.walletList
          .singleWhere((element) => element.id == _user!.currentWalletId);
      isWalletOwner = (currentWallet.ownerId == _user!.id);

      if (previousWalletId != currentWallet.id) {
        _resetPlanLimitNoticeKey();
      }
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
      final requestedStart = startDate;
      final requestedEnd = endDate;
      previousPeriodSpends = null;
      CacheEntryResult? cachedEntry;
      
      if (!forceRefresh) {
        cachedEntry = await _cacheService.getCacheEntry('insights', walletId);
      }
      
      if (cachedEntry != null &&
          cachedEntry.data.isNotEmpty &&
          !forceRefresh &&
          cachedEntry.metadata != null &&
          _matchesRequestedDateRange(cachedEntry.metadata!)) {
        try {
          _applyEffectiveDatesFromMetadata(cachedEntry.metadata!);
          _applyTransactionsFromRawData(cachedEntry.data);
          await _loadPreviousPeriodSpends();

          _maybeShowPlanLimitBottomSheet(
            wasUserAdjusted: _wasUserPeriodAdjusted(
              requestedStart: requestedStart,
              requestedEnd: requestedEnd,
              wasAdjusted: cachedEntry.metadata!['wasAdjusted'] == true,
              effectiveStartDate:
                  cachedEntry.metadata!['effectiveStartDate'] as String?,
              effectiveEndDate:
                  cachedEntry.metadata!['effectiveEndDate'] as String?,
            ),
            walletId: walletId,
            requestedStart: requestedStart,
            requestedEnd: requestedEnd,
          );

          update();
          return;
        } catch (e) {
          await _cacheService.invalidateCache('insights', walletId);
        }
      } else if (cachedEntry != null &&
          (cachedEntry.metadata == null ||
              !_matchesRequestedDateRange(cachedEntry.metadata!))) {
        await _cacheService.invalidateCache('insights', walletId);
      }

      loading = true;
      isRefreshing = true;
      update();

      ResponseDto res = await _transactionService.getTransactionDtoList(
        walletId,
        requestedStart,
        requestedEnd,
      );

      loading = false;
      isRefreshing = false;
      
      if (res.success) {
        List<Map<String, dynamic>> dataList = [];
        if (res.data is List && (res.data as List).isNotEmpty) {
          dataList = (res.data as List)
              .map((e) => e as Map<String, dynamic>)
              .toList();
        }

        await _cacheService.saveCache(
          'insights',
          walletId,
          dataList,
          metadata: _buildCacheMetadata(
            requestedStart: requestedStart,
            requestedEnd: requestedEnd,
            wasAdjusted: res.wasAdjusted,
            effectiveStartDate: res.effectiveStartDate,
            effectiveEndDate: res.effectiveEndDate,
          ),
        );

        _applyDateRangeMetadata(
          res,
          requestedStart: requestedStart,
          requestedEnd: requestedEnd,
        );
        _applyTransactionsFromRawData(dataList);
        await _loadPreviousPeriodSpends();

        _maybeShowPlanLimitBottomSheet(
          wasUserAdjusted: _wasUserPeriodAdjusted(
            requestedStart: requestedStart,
            requestedEnd: requestedEnd,
            wasAdjusted: res.wasAdjusted,
            effectiveStartDate: res.effectiveStartDate,
            effectiveEndDate: res.effectiveEndDate,
          ),
          walletId: walletId,
          requestedStart: requestedStart,
          requestedEnd: requestedEnd,
        );
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

  /// Skeleton apenas no carregamento inicial ou fetch sem dados em cache.
  /// Evita piscar todos os cards em pull-to-refresh ou hit de cache.
  bool get showSkeleton => loading || (isRefreshing && !hasData);
  
  /// Retorna se o período tem 2+ meses no filtro e há despesas no período anterior
  bool get canShowComparison {
    if (_countCalendarMonthsInPeriod(startDate, endDate) < 2) {
      return false;
    }
    final previous = previousPeriodSpends;
    return previous != null && previous > 0;
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
            FaIcon(
              FontAwesomeIcons.calendar,
              size: 16,
              color: Styles.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
