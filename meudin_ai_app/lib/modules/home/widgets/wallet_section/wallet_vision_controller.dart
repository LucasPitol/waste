import 'package:meudin_ai_app/models/transaction.dart';
import 'package:meudin_ai_app/models/tuple.dart';
import 'package:meudin_ai_app/models/wallet_member.dart';
import 'package:meudin_ai_app/services/wallet_service.dart';
import 'package:get/get.dart';
import 'package:meudin_ai_app/routes/app_routes.dart';
import 'package:meudin_ai_app/modules/home/home_module_controller.dart';

class WalletVisionWidgetController extends GetxController {
  late List<Tuple> tabs;
  late int selectedTab;
  late bool loading;
  
  // Members state
  List<WalletMember> members = [];
  bool isLoadingMembers = false;
  String? membersError;
  String? currentWalletId;
  bool isWalletOwner = false;

  WalletVisionWidgetController() {
    tabs = [
      Tuple(t1: 0, t2: 'Visão'),
      Tuple(t1: 1, t2: 'Membros'),
    ];
    selectedTab = 0;
    loading = true;
  }

  void setWalletInfo(String walletId, bool owner) {
    final previousWalletId = currentWalletId;
    final walletChanged = previousWalletId != null && previousWalletId != walletId;
    
    currentWalletId = walletId;
    isWalletOwner = owner;
    
    // Reset members state when wallet changes
    if (walletChanged) {
      members = [];
      membersError = null;
      isLoadingMembers = false;
      
      // If on members tab, reload members for the new wallet
      if (selectedTab == 1 && walletId.isNotEmpty) {
        Future.microtask(() {
          if (!isLoadingMembers && selectedTab == 1 && currentWalletId == walletId) {
            loadMembers(walletId);
          }
        });
      }
    }
  }

  selectTab(int newValue, {String? walletId}) {
    selectedTab = newValue;
    update();
    
    // Load members ONLY when user taps on "Membros" tab (lazy loading as per requirements)
    if (newValue == 1 && walletId != null && walletId.isNotEmpty) {
      loadMembers(walletId);
    }
  }

  Future<void> loadMembers(String walletId) async {
    if (isLoadingMembers) return; // Prevent multiple simultaneous requests
    
    isLoadingMembers = true;
    membersError = null;
    update();

    try {
      final walletService = WalletService();
      final response = await walletService.getWalletMembers(walletId);
      
      if (response.success && response.data is List) {
        members = (response.data as List)
            .map<WalletMember>((e) => WalletMember.fromJson(e as Map<String, dynamic>))
            .toList();
        membersError = null;
      } else {
        membersError = response.errorMessage ?? 'Erro ao carregar membros';
        members = [];
      }
    } catch (e) {
      membersError = 'Erro ao carregar membros: $e';
      members = [];
    } finally {
      isLoadingMembers = false;
      update();
    }
  }
  
  Future<void> refreshMembers() async {
    if (currentWalletId != null && currentWalletId!.isNotEmpty) {
      await loadMembers(currentWalletId!);
    }
  }

  goToSeeAllTransactionsPage({
    required List<Transaction> transactions,
    required DateTime startDate,
  }) async {
    final refresh = await Get.toNamed(
      AppRoutes.transactionsListRoute,
      arguments: [transactions, startDate],
    );

    if (refresh != null && refresh) {
      // Refresh data in home module
      final homeController = Get.find<HomeModuleController>();
      await homeController.updatePageData();
    }
  }
}
