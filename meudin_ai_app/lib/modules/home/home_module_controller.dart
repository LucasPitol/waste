import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:meudin_ai_app/ui/app_icons.dart';
import 'package:meudin_ai_app/modules/home/widgets/wallet_selector/wallet_selector_widget.dart';
import 'package:meudin_ai_app/modules/home/widgets/wallet_selector/edit_wallet_modal.dart';
import 'package:meudin_ai_app/modules/home/widgets/wallet_selector/delete_wallet_modal.dart';
import 'package:meudin_ai_app/modules/home/widgets/wallet_section/month_year_picker_bottom_sheet.dart';
import 'package:meudin_ai_app/modules/home/widgets/upgrade_banner/upgrade_banner_widget.dart';
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
import 'package:meudin_ai_app/services/plan_state_controller.dart';
import 'package:meudin_ai_app/routes/app_routes.dart';
import 'package:meudin_ai_app/services/wallet_service.dart';
import 'package:meudin_ai_app/services/session_service.dart';
import 'package:meudin_ai_app/services/local_storage_service.dart';
import 'package:meudin_ai_app/services/cache_service.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';

class HomeModuleController extends GetxController {
  User? _user;
  late Wallet currentWallet;
  late bool isWalletOwner;
  late bool loading;
  late double monthRevenue;
  late double monthSpends;
  late double monthBalance;
  late DateTime startDate;
  late DateTime endDate;
  late List<Transaction> transactionDtoList;
  late List<Transaction> twoFirstTransactionDtoList;
  late TransactionService _transactionService;
  late WalletService _walletService;
  late UserService _userService;
  late SpendingCategoryService _spendingCategoryService;
  late CacheService _cacheService;
  late bool isWalletListLoading;
  late bool isRefreshing;
  late UpgradeBannerVersion selectedBannerVersion;
  Timer? _upgradeBannerTimer;
  bool _bannerTimerFired = false;

  bool get showUpgradeBanner {
    if (!_bannerTimerFired) return false;
    final planCtrl = Get.isRegistered<PlanStateController>()
        ? Get.find<PlanStateController>()
        : null;
    return planCtrl?.isFree ?? true;
  }
  List<SpendingCategory> _categories = [];
  List<CategoryExpense> _categoryExpenses = [];

  HomeModuleController() {
    _userService = UserService();
    _user = _userService.getCurrentUser();
    
    currentWallet = _user!.walletList
        .singleWhere((element) => element.id == _user!.currentWalletId);
    
    isWalletOwner = (currentWallet.ownerId == _user!.id);
    
    monthRevenue = 0.0;
    monthSpends = 0.0;
    monthBalance = 0.0;
    transactionDtoList = [];
    twoFirstTransactionDtoList = [];
    _transactionService = TransactionService();
    _walletService = WalletService();
    _spendingCategoryService = SpendingCategoryService();
    _cacheService = CacheService();
    loading = false;
    isWalletListLoading = false;
    isRefreshing = false;
    // Seleção aleatória da versão do banner (50% de chance para cada)
    selectedBannerVersion = _selectRandomBannerVersion();
  }

  /// Seleciona aleatoriamente uma versão do banner (50% de chance para cada)
  UpgradeBannerVersion _selectRandomBannerVersion() {
    final random = Random();
    // 50% de chance para cada versão
    return random.nextBool() 
        ? UpgradeBannerVersion.neutral 
        : UpgradeBannerVersion.contextual;
  }

  @override
  void onInit() {
    super.onInit();
    _ensurePlanStateAndListen();
    _fillStandardDate();
    _fetchCategories();
    _restoreLastSelectedWallet();
    _startUpgradeBannerTimer();
  }

  void _ensurePlanStateAndListen() {
    if (!Get.isRegistered<PlanStateController>()) {
      Get.put(PlanStateController(), permanent: true);
    }
    Get.find<PlanStateController>().refreshPlan();
    ever(Get.find<PlanStateController>().planCode, (_) => update());
  }

  /// Restaura a última carteira selecionada do local storage antes de buscar transações
  Future<void> _restoreLastSelectedWallet() async {
    try {
      // Lê os dados do usuário do local storage para obter o currentWalletId atualizado
      final localStorageService = LocalStorageService();
      final storedUser = await localStorageService.getUserData();
      
      if (storedUser != null && storedUser.currentWalletId.isNotEmpty) {
        // Verifica se a carteira ainda existe na lista de carteiras do usuário
        final walletExists = _user!.walletList.any(
          (wallet) => wallet.id == storedUser.currentWalletId,
        );
        
        if (walletExists) {
          // Atualiza o currentWalletId no UserService se for diferente
          if (_user!.currentWalletId != storedUser.currentWalletId) {
            _user!.currentWalletId = storedUser.currentWalletId;
            UserService.currentUser!.currentWalletId = storedUser.currentWalletId;
            
            // Atualiza a carteira atual
            currentWallet = _user!.walletList
                .singleWhere((element) => element.id == storedUser.currentWalletId);
            isWalletOwner = (currentWallet.ownerId == _user!.id);
          }
        }
      }
    } catch (e) {
      // Se houver erro ao ler do storage, continua com a carteira atual
      // (já definida no construtor)
    }
    
    // Após restaurar a carteira, busca os dados
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

  /// Calcula gastos por categoria usando APENAS os dados já carregados em transactionDtoList
  /// Não faz nenhuma nova requisição de transações - usa os mesmos dados do saldo e listagem
  void _calculateCategoryExpenses() {
    // Usa transactionDtoList que já foi carregado em updatePageData()
    // Filtra apenas despesas (valores negativos) com categoria
    final expenses = transactionDtoList
        .where((t) => t.amount != null && t.amount! < 0 && t.categoryId != null)
        .toList();

    if (expenses.isEmpty) {
      _categoryExpenses = [];
      return;
    }

    // Agrupa por categoria usando os dados já carregados
    final Map<String, double> totalByCategory = {};
    
    for (var transaction in expenses) {
      final categoryId = transaction.categoryId!;
      final amount = transaction.amount!.abs(); // Converte para positivo
      totalByCategory[categoryId] = (totalByCategory[categoryId] ?? 0.0) + amount;
    }

    // Calcula total
    final double totalAmount = totalByCategory.values.fold(0.0, (sum, value) => sum + value);

    if (totalAmount == 0) {
      _categoryExpenses = [];
      return;
    }

    // Cria lista de CategoryExpense usando apenas os dados já carregados
    _categoryExpenses = totalByCategory.entries.map((entry) {
      final categoryId = entry.key;
      final amount = entry.value;
      // Calcula percentual com precisão
      final percentage = (amount / totalAmount) * 100;

      // Busca informações da categoria (já carregadas em _categories)
      final category = _categories.firstWhere(
        (cat) => cat.id == categoryId,
        orElse: () => SpendingCategory(
          id: categoryId,
          name: 'Outro',
          value: 'other',
          type: 'personal',
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

    // Ordena por valor descendente
    _categoryExpenses.sort((a, b) => b.amount.compareTo(a.amount));
    
    // Limita a 4 categorias, agrupa o resto em "Outros"
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
    
    // CORREÇÃO: Garante que os percentuais somem exatamente 100%
    // Ajusta o último item para compensar erros de arredondamento
    if (_categoryExpenses.isNotEmpty) {
      final totalPercentage = _categoryExpenses.fold(0.0, (sum, e) => sum + e.percentage);
      final difference = 100.0 - totalPercentage;
      if (difference.abs() > 0.001) { // Se diferença > 0.001%
        // Ajusta o último item para garantir soma = 100%
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

  void _startUpgradeBannerTimer() {
    _upgradeBannerTimer = Timer(const Duration(seconds: 3), () {
      _bannerTimerFired = true;
      update();
    });
  }

  @override
  void onClose() {
    _upgradeBannerTimer?.cancel();
    super.onClose();
  }

  Future<void> refreshUserAndWallet() async {
    isWalletListLoading = true;
    update();
    
    try {
      await _walletService.getUserWallets();
      _user = UserService.currentUser;

      currentWallet = _user!.walletList
          .singleWhere((element) => element.id == _user!.currentWalletId);
      isWalletOwner = (currentWallet.ownerId == _user!.id);
    } catch (e) {
      // Handle wallet loading error silently
    } finally {
      isWalletListLoading = false;
      update();
    }
  }

  /// Complete refresh - both wallets and transactions with unified loading
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

  openWalletSelector() async {
    List<Wallet> userWallets = _user!.walletList;
    final theme = Theme.of(Get.context!);

    Map<String, dynamic>? newWalletOptions = await Get.bottomSheet(
      WalletSelectorWidget(
        walletList: userWallets,
        currentUserId: _user!.id,
      ),
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: theme.brightness == Brightness.dark 
          ? theme.colorScheme.surface 
          : Styles.whiteColor,
    );

    if (newWalletOptions != null) {
      // Handle wallet menu (edit/delete)
      if (newWalletOptions['action'] == 'menu') {
        final walletId = newWalletOptions['walletId'] as String;
        final walletName = newWalletOptions['walletName'] as String;
        await _showWalletMenu(walletId, walletName);
        return;
      }

      // Handle wallet selection
      if (newWalletOptions.containsKey('newWalletId') &&
          newWalletOptions['createNewWallet'] == false) {
        final newWalletId = newWalletOptions['newWalletId'];
        _switchCurrentWallet(newWalletId);
      }

      // Handle new wallet creation
      if (newWalletOptions['createNewWallet'] == true) {
        final result = await Get.toNamed(AppRoutes.newWalletRoute);
        if (result != null && result is String) {
          // Refresh wallet list after creating new wallet
          await refreshUserAndWallet();
          // Select the newly created wallet
          final newWalletId = result as String;
          if (_user!.walletList.any((w) => w.id == newWalletId)) {
            // _switchCurrentWallet já salva no local storage
            _switchCurrentWallet(newWalletId);
          }
        }
      }
    }
  }

  _switchCurrentWallet(String newWalletId) {
    Wallet walletTemp =
        _user!.walletList.singleWhere((element) => element.id == newWalletId);

    UserService.currentUser!.currentWalletId = newWalletId;
    _user!.currentWalletId = newWalletId;

    // Salva a carteira selecionada no local storage
    SessionService.updateCurrentWalletId(newWalletId);

    bool isWalletOwnerTemp = (walletTemp.ownerId == _user!.id);

    currentWallet = walletTemp;
    isWalletOwner = isWalletOwnerTemp;

    update();

    // Ao trocar carteira, busca dados (cache será verificado por carteira)
    updatePageData();
  }

  Future<void> _showWalletMenu(String walletId, String walletName) async {
    final theme = Theme.of(Get.context!);
    final result = await Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.dark 
              ? theme.colorScheme.surface 
              : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: AppIcon(
                AppIcons.pen,
                size: 18,
                color: theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
              ),
              title: Text(
                'Editar nome',
                style: TextStyle(
                  color: theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
                ),
              ),
              onTap: () {
                Get.back(result: 'edit');
              },
            ),
            ListTile(
              leading: AppIcon(
                AppIcons.trash,
                size: 18,
                color: Colors.red,
              ),
              title: Text(
                'Excluir carteira',
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),
              onTap: () {
                Get.back(result: 'delete');
              },
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.transparent,
    );

    if (result == 'edit') {
      await _editWallet(walletId, walletName);
    } else if (result == 'delete') {
      await _deleteWallet(walletId, walletName);
    }
  }

  Future<void> _editWallet(String walletId, String currentName) async {
    final theme = Theme.of(Get.context!);
    String? newName;

    await Get.bottomSheet(
      EditWalletModal(
        currentName: currentName,
        onSave: (name) {
          newName = name;
        },
      ),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.transparent,
    );

    if (newName != null && newName!.isNotEmpty && newName != currentName) {
      isRefreshing = true;
      update();

      try {
        final response = await _walletService.updateWallet(walletId, newName!);
        
        if (response.success) {
          await refreshUserAndWallet();
          
          // If the edited wallet is the current one, update it
          if (currentWallet.id == walletId) {
            currentWallet = _user!.walletList
                .singleWhere((element) => element.id == walletId);
            update();
          }
        } else {
          Get.bottomSheet(
            JoyModal.errorBottomSheet(
              context: Get.context!,
              errorList: [response.errorMessage ?? 'Erro ao editar carteira'],
              title: 'Erro ao editar carteira',
            ),
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            backgroundColor: Colors.transparent,
          );
        }
      } catch (e) {
        Get.bottomSheet(
          JoyModal.errorBottomSheet(
            context: Get.context!,
            errorList: ['Erro ao editar carteira: $e'],
            title: 'Erro ao editar carteira',
          ),
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          backgroundColor: Colors.transparent,
        );
      } finally {
        isRefreshing = false;
        update();
      }
    }
  }

  Future<void> _deleteWallet(String walletId, String walletName) async {
    final theme = Theme.of(Get.context!);
    bool? confirmed;

    await Get.bottomSheet(
      DeleteWalletModal(
        walletName: walletName,
        onConfirm: () {
          confirmed = true;
        },
      ),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.transparent,
    );

    if (confirmed == true) {
      // Check if it's the only wallet
      if (_user!.walletList.length <= 1) {
        Get.bottomSheet(
          JoyModal.errorBottomSheet(
            context: Get.context!,
            errorList: ['Você não pode excluir sua única carteira'],
            title: 'Não é possível excluir',
          ),
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          backgroundColor: Colors.transparent,
        );
        return;
      }

      isRefreshing = true;
      update();

      try {
        final response = await _walletService.deleteWallet(walletId);
        
        if (response.success) {
          await refreshUserAndWallet();
          
          // If the deleted wallet was the current one, switch to the first available wallet
          if (currentWallet.id == walletId) {
            if (_user!.walletList.isNotEmpty) {
              // _switchCurrentWallet já salva no local storage
              _switchCurrentWallet(_user!.walletList.first.id);
            }
          }
        } else {
          Get.bottomSheet(
            JoyModal.errorBottomSheet(
              context: Get.context!,
              errorList: [response.errorMessage ?? 'Erro ao excluir carteira'],
              title: 'Erro ao excluir carteira',
            ),
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            backgroundColor: Colors.transparent,
          );
        }
      } catch (e) {
        Get.bottomSheet(
          JoyModal.errorBottomSheet(
            context: Get.context!,
            errorList: ['Erro ao excluir carteira: $e'],
            title: 'Erro ao excluir carteira',
          ),
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          backgroundColor: Colors.transparent,
        );
      } finally {
        isRefreshing = false;
        update();
      }
    }
  }

  _fillStandardDate() {
    DateTime now = DateTime.now();
    startDate = DateTime(now.year, now.month, 1);
    endDate = DateTime(now.year, now.month, now.day, 59, 59, 59, 59);
  }

  void _updateDatesForMonth(DateTime selectedDate) {
    DateTime now = DateTime.now();
    int selectedYear = selectedDate.year;
    int selectedMonth = selectedDate.month;

    // Start date is always the first day of the selected month
    startDate = DateTime(selectedYear, selectedMonth, 1);

    // End date logic:
    // - If selected month is current month: use current day
    // - Otherwise: use last day of the selected month
    if (selectedYear == now.year && selectedMonth == now.month) {
      endDate = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
    } else {
      // Get last day of the selected month
      final lastDay = DateTime(selectedYear, selectedMonth + 1, 0);
      endDate = DateTime(selectedYear, selectedMonth, lastDay.day, 23, 59, 59, 999);
    }
  }

  Future<void> openMonthYearPicker() async {
    final selectedDate = await Get.bottomSheet<DateTime>(
      MonthYearPickerBottomSheet(initialDate: startDate),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.transparent,
    );

    if (selectedDate != null) {
      // Verifica se o mês/ano realmente mudou antes de invalidar o cache
      final newStartDate = DateTime(selectedDate.year, selectedDate.month, 1);
      final monthChanged = newStartDate.year != startDate.year || 
                          newStartDate.month != startDate.month;
      
      _updateDatesForMonth(selectedDate);
      
      // Se o mês mudou, invalida o cache para forçar busca com as novas datas
      if (monthChanged) {
        await _cacheService.invalidateCache('home', currentWallet.id);
      }
      
      update();
      await updatePageData();
    }
  }

  /// Carrega dados da página, usando cache quando disponível
  /// [forceRefresh] força busca na API mesmo com cache válido (pull to refresh)
  updatePageData({bool forceRefresh = false}) async {
    try {
      // Garante que categorias estão carregadas (apenas uma vez, se necessário)
      // Isso é necessário apenas para mapear categoryId -> nome/cor, não é nova requisição de transações
      if (_categories.isEmpty) {
        await _fetchCategories();
      }

      String walletId = currentWallet.id;
      List<Map<String, dynamic>>? cachedData;
      
      // Verifica cache apenas se não for refresh forçado
      if (!forceRefresh) {
        cachedData = await _cacheService.getCache('home', walletId);
      }
      
      // Se tem cache válido, usa ele SEM mostrar loading
      if (cachedData != null && cachedData.isNotEmpty && !forceRefresh) {
        try {
          // Processa dados do cache
          transactionDtoList = cachedData
              .map<Transaction>((e) => Transaction.fromJson(e))
              .toList();

          // Sort by transactionDate descending (most recent first)
          transactionDtoList.sort((a, b) {
            if (a.transactionDate == null && b.transactionDate == null) return 0;
            if (a.transactionDate == null) return 1;
            if (b.transactionDate == null) return -1;
            return b.transactionDate!.compareTo(a.transactionDate!);
          });

          // Calcula saldo, receitas e despesas usando transactionDtoList
          double totalAmountTemp = 0;
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

          totalAmountTemp = (totalRevenueTemp + totalSpendTemp);

          monthRevenue = totalRevenueTemp;
          monthSpends = totalSpendTemp;
          monthBalance = totalAmountTemp;

          twoFirstTransactionDtoList = transactionDtoList.take(2).toList();

          // Calcula gastos por categoria usando os MESMOS dados (transactionDtoList)
          _calculateCategoryExpenses();
          
          // Não precisa setar loading/isRefreshing pois nunca foram setados
          update();
          return; // Retorna sem fazer request à API
        } catch (e) {
          // Se houver erro ao processar cache, invalida e busca da API
          await _cacheService.invalidateCache('home', walletId);
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
        await _cacheService.saveCache('home', walletId, dataList);
        
        // Processa dados para UI
        transactionDtoList = dataList
            .map<Transaction>((e) => Transaction.fromJson(e))
            .toList();

        // Sort by transactionDate descending (most recent first)
        transactionDtoList.sort((a, b) {
          if (a.transactionDate == null && b.transactionDate == null) return 0;
          if (a.transactionDate == null) return 1;
          if (b.transactionDate == null) return -1;
          return b.transactionDate!.compareTo(a.transactionDate!);
        });

        // Calcula saldo, receitas e despesas usando transactionDtoList
        double totalAmountTemp = 0;
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

        totalAmountTemp = (totalRevenueTemp + totalSpendTemp);

        monthRevenue = totalRevenueTemp;
        monthSpends = totalSpendTemp;
        monthBalance = totalAmountTemp;

        twoFirstTransactionDtoList = transactionDtoList.take(2).toList();

        // Calcula gastos por categoria usando os MESMOS dados (transactionDtoList)
        _calculateCategoryExpenses();

        // Aviso de limite de histórico (backend ajustou intervalo)
        if (res.wasAdjusted) {
          Future.microtask(() {
            Get.bottomSheet(
              JoyModal.limitReachedBottomSheet(
                context: Get.context!,
                title: 'Limite do plano',
                message:
                    'Seu plano limita o histórico de transações disponível. '
                    'Faça upgrade para consultar períodos maiores.',
              ),
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              backgroundColor: Colors.transparent,
            );
          });
        }
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
}
