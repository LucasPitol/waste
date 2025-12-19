import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
import 'package:get/get.dart';
import 'package:meudin_ai_app/services/wallet_service.dart';
import 'package:meudin_ai_app/routes/app_routes.dart';
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
  late bool isWalletListLoading;
  late bool isRefreshing;
  late bool showUpgradeBanner;
  late UpgradeBannerVersion selectedBannerVersion;
  Timer? _upgradeBannerTimer;

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
    isWalletListLoading = false;
    isRefreshing = false;
    showUpgradeBanner = false;
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
    _fillStandardDate();
    refreshAll();
    _startUpgradeBannerTimer();
  }

  void _startUpgradeBannerTimer() {
    _upgradeBannerTimer = Timer(const Duration(seconds: 3), () {
      showUpgradeBanner = true;
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
  Future<void> refreshAll() async {
    isRefreshing = true;
    update();
    
    try {
      await refreshUserAndWallet();
      await updatePageData();
    } finally {
      isRefreshing = false;
      update();
    }
  }

  openWalletSelector() async {
    List<Wallet> userWallets = _user!.walletList;

    Map<String, dynamic>? newWalletOptions = await Get.bottomSheet(
      WalletSelectorWidget(
        walletList: userWallets,
        currentUserId: _user!.id,
      ),
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Styles.whiteColor,
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

    bool isWalletOwnerTemp = (walletTemp.ownerId == _user!.id);

    currentWallet = walletTemp;
    isWalletOwner = isWalletOwnerTemp;

    update();

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
              leading: FaIcon(
                FontAwesomeIcons.pen,
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
              leading: FaIcon(
                FontAwesomeIcons.trash,
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
      _updateDatesForMonth(selectedDate);
      update();
      await updatePageData();
    }
  }

  updatePageData() async {
    loading = true;
    update();

    try {
      String walletId = currentWallet.id;
      ResponseDto res = await _transactionService.getTransactionDtoList(
        walletId,
        startDate,
        endDate,
      );

      loading = false;
      
      if (res.success) {
        transactionDtoList = res.data.isNotEmpty
            ? res.data.map<Transaction>((e) => Transaction.fromJson(e)).toList()
            : [];

        // Sort by transactionDate descending (most recent first)
        transactionDtoList.sort((a, b) {
          if (a.transactionDate == null && b.transactionDate == null) return 0;
          if (a.transactionDate == null) return 1;
          if (b.transactionDate == null) return -1;
          return b.transactionDate!.compareTo(a.transactionDate!);
        });

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
      } else {
        JoyModal.bottomSheetError(
          context: Get.context!,
          errorList: [res.errorMessage!],
          title: 'Erro ao carregar transações',
        );
      }
    } catch (e) {
      loading = false;
      
      JoyModal.bottomSheetError(
        context: Get.context!,
        errorList: ['Erro ao carregar dados: $e'],
        title: 'Erro',
      );
    } finally {
      loading = false;
      update();
    }
  }
}
