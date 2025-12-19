import 'dart:async';
import 'package:flutter/material.dart';
import 'package:meudin_ai_app/modules/home/widgets/wallet_selector/wallet_selector_widget.dart';
import 'package:meudin_ai_app/modules/home/widgets/wallet_section/month_year_picker_bottom_sheet.dart';
import 'package:meudin_ai_app/services/transaction_service.dart';
import 'package:meudin_ai_app/models/dtos/response_dto.dart';
import 'package:meudin_ai_app/services/user_service.dart';
import 'package:meudin_ai_app/models/transaction.dart';
import 'package:meudin_ai_app/models/wallet.dart';
import 'package:meudin_ai_app/models/user.dart';
import 'package:get/get.dart';
import 'package:meudin_ai_app/services/wallet_service.dart';
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
  late bool showPlanCarousel;
  Timer? _planCarouselTimer;

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
    showPlanCarousel = false;
  }

  @override
  void onInit() {
    super.onInit();
    _fillStandardDate();
    refreshAll();
    _startPlanCarouselTimer();
  }

  void _startPlanCarouselTimer() {
    _planCarouselTimer = Timer(const Duration(seconds: 3), () {
      showPlanCarousel = true;
      update();
    });
  }

  @override
  void onClose() {
    _planCarouselTimer?.cancel();
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
      WalletSelectorWidget(walletList: userWallets),
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Styles.whiteColor,
    );

    if (newWalletOptions != null) {
      if (newWalletOptions.containsKey('newWalletId') &&
          newWalletOptions['createNewWallet'] == false) {
        final newWalletId = newWalletOptions['newWalletId'];
        _switchCurrentWallet(newWalletId);
      }

      if (newWalletOptions['createNewWallet'] == true) {
        // Create new wallet functionality
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
