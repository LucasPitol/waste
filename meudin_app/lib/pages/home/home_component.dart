import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meudin_app/models/dtos/response_dto.dart';
import 'package:meudin_app/models/dtos/tab_selector_dto.dart';
import 'package:meudin_app/models/dtos/transaction_dto.dart';
import 'package:meudin_app/models/wallet.dart';
import 'package:meudin_app/pages/shared/info_bottom_sheet_widget.dart';
import 'package:meudin_app/pages/shared/loading_widget.dart';
import 'package:meudin_app/services/transaction_service.dart';
import 'package:meudin_app/services/user_service.dart';
import 'package:meudin_app/utils/constants.dart';
import 'package:meudin_app/utils/styles.dart';
import 'package:meudin_app/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meudin_app/utils/utils.dart';

import 'new_wallet_component.dart';
import 'wallets_bottom_sheet.dart';

class HomeComponent extends StatefulWidget {
  // final GlobalKey<OverlayBuilderState> overlayBuilderStatelKey;

  HomeComponent({required Key key}) : super(key: key);

  @override
  HomeComponentState createState() => HomeComponentState();
}

class HomeComponentState extends State<HomeComponent> {
  // final GlobalKey<OverlayBuilderState> overlayBuilderStatelKey;
  User? _user;
  late Wallet _currentWallet;
  late UserService _userService;
  late TransactionService _transactionService;

  double _monthRevenue = 0.0;
  double _monthSpends = 0.0;
  double _monthBalance = 0.0;

  late bool _loading;
  late List<TabSelector> _tabs;
  late int _tabSelected;
  late List<TransactionDto> transactionDtoList;
  late List<TransactionDto> _twoFirstTransactionDtoList;
  late DateTime startDate;
  late DateTime endDate;

  HomeComponentState() {
    _user = UserService.currentUser;
    _transactionService = TransactionService();
    _currentWallet = _user!.walletList
        .singleWhere((element) => element.id == _user!.currentWalletId);
    _userService = UserService();
    _tabs = <TabSelector>[];
    _tabSelected = 0;
    _loading = false;
    transactionDtoList = <TransactionDto>[];
    _twoFirstTransactionDtoList = <TransactionDto>[];
  }

  @override
  void initState() {
    super.initState();
    updateAppBar();
    _fillStandardDate();
    _fillTabOptions();
    updatePageData();
  }

  _fillStandardDate() {
    DateTime now = DateTime.now();
    startDate = DateTime(now.year, now.month, 1);
    endDate = now.add(const Duration(days: 2));
  }

  updatePageData() async {
    setState(() {
      _loading = true;
    });

    await _updateUserWallets();

    await _updateTransactionList();
    // await _updateMembersList();

    setState(() {
      _loading = false;
    });
  }

  _updateUserWallets() async {
    await _userService.updateUserWallets();

    _user = UserService.currentUser;

    Wallet _currentWalletTemp = _user!.walletList
        .singleWhere((element) => element.id == _user!.currentWalletId);

    setState(() {
      _currentWallet = _currentWalletTemp;
    });
  }

  _updateTransactionList() async {
    String walletId = _currentWallet.id;

    ResponseDto res = await _transactionService.getTransactionDtoList(
        walletId, startDate, endDate);

    if (res.success) {
      transactionDtoList = res.data;

      double totalAmount = 0;
      double totalRevenue = 0;
      double totalSpend = 0;

      for (var element in transactionDtoList) {
        double amount = element.amount!;

        if (amount > 0) {
          totalRevenue = totalRevenue + amount;
        } else {
          totalSpend = totalSpend + amount;
        }
      }

      totalAmount = (totalRevenue + totalSpend);

      _monthRevenue = totalRevenue;
      _monthSpends = totalSpend;
      _monthBalance = totalAmount;

      _twoFirstTransactionDtoList = transactionDtoList.take(2).toList();
    } else {
      // exibir aviso
    }
  }

  _fillTabOptions() {
    var visionOpt = TabSelector(
      displayName: 'Visão',
      value: 0,
    );

    var membersOpt = TabSelector(
      displayName: 'Membros',
      value: 1,
    );

    _tabs = [visionOpt, membersOpt];
  }

  updateAppBar() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Styles.mainBackgroundColor,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  Widget _buildAppBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: Styles.getAppLogo()),
          IconButton(
            icon: FaIcon(
              FontAwesomeIcons.redo,
              color: Styles.mainTextColor,
              size: 20,
            ),
            onPressed: () {
              updatePageData();
            },
          ),
          IconButton(
            icon: FaIcon(
              FontAwesomeIcons.gripLines,
              color: Styles.mainTextColor,
              size: 20,
            ),
            onPressed: () {
              print('Settings');
            },
          ),
        ],
      ),
    );
  }

  _goToNewWalletPage() async {
    Navigator.pop(context);

    int walletCountLimit = Constants.numberOfWalletsLimitOnFreePlan;
    int userWalletOwnedCount = _userService.getNumberOfWalletsOwned();

    if (userWalletOwnedCount >= walletCountLimit) {
      String title = 'Ops...';
      String message =
          'Limite de carteiras excedido, em breve o limite será estendido';

      _openInfoBottomSheet(title, message);
    } else {
      bool? refresh = await Navigator.of(context)
          .push(MaterialPageRoute(builder: (BuildContext context) {
        return NewWalletComponent();
      }));

      if (refresh != null && refresh) {
        await _updateUserWallets();
        _user = UserService.currentUser;
        String newWalletId = _user!.currentWalletId;
        _switchCurrentWallet(newWalletId);
      }
    }
  }

  void _openInfoBottomSheet(String title, String message) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Styles.cardColor,
        builder: (builder) {
          return InfoBottomSheetWidget(title: title, message: message);
        });
  }

  _openWalletsBottomSheet() async {
    List<Wallet> userWallets = _user!.walletList;

    String? newWalletId = await showModalBottomSheet(
        context: context,
        backgroundColor: Styles.cardColor,
        builder: (builder) {
          return WalletsBottomSheetWidget(
            walletList: userWallets,
            handleNewWalletPage: _goToNewWalletPage,
          );
        });

    if (newWalletId != null && newWalletId.isNotEmpty) {
      _switchCurrentWallet(newWalletId);
    }
  }

  _switchCurrentWallet(String newWalletId) {
    Wallet walletTemp =
        _user!.walletList.singleWhere((element) => element.id == newWalletId);

    UserService.currentUser!.currentWalletId = newWalletId;

    setState(() {
      _currentWallet = walletTemp;
    });

    _updateTransactionList();
  }

  Widget _buildWalletSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              width: double.infinity,
              height: 5,
            ),
            Row(
              children: [
                Text(
                  _currentWallet.name,
                  style: Styles.montTextTitle,
                ),
                IconButton(
                  icon: const FaIcon(
                    FontAwesomeIcons.sortDown,
                    color: Colors.grey,
                    size: 20,
                  ),
                  onPressed: () {
                    _openWalletsBottomSheet();
                  },
                ),
              ],
            ),
            Text(
              'Plano básico',
              style: Styles.montSubText,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: _tabs.map((e) {
          bool isOptionSelected = e.value == _tabSelected;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _tabSelected = e.value;
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: isOptionSelected
                    ? Styles.cardDecoration
                    : BoxDecoration(color: Styles.mainBackgroundColor),
                child: Text(
                  e.displayName,
                  style:
                      isOptionSelected ? Styles.montText : Styles.montTextGrey,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContentBox() {
    if (_loading) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 60),
        child: LoadingWidget(),
      );
    } else {
      switch (_tabSelected) {
        case 0:
          return _buildHomeBox();

        case 1:
          return Container();

        default:
          return Container();
      }
    }
  }

  Widget _buildHomeBox() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      width: double.infinity,
      decoration: Styles.cardDecoration,
      child: SizedBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Utils.getAmountFormated(_monthBalance),
                        style: Styles.montTextTitle,
                      ),
                      Text(
                        'Balanço do mês',
                        style: Styles.montSubText,
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    print('switch month');
                  },
                  child: Text(
                    'Julho',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Styles.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              width: double.infinity,
              height: 20,
            ),
            Row(
              children: [
                SizedBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '+' + Utils.getAmountFormated(_monthRevenue),
                        style: Styles.montText,
                      ),
                      Text(
                        'Entrada',
                        style: Styles.montSubText,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 20,
                  height: 20,
                ),
                SizedBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Utils.getAmountFormated(_monthSpends),
                        style: Styles.montText,
                      ),
                      Text(
                        'Saida',
                        style: Styles.montSubText,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              width: double.infinity,
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transações',
                  style: Styles.montTextTitle,
                ),
                TextButton(
                  onPressed: () {
                    print('See all transactions');
                  },
                  child: Text(
                    'Ver todas',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Styles.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            //2 transactions
            SizedBox(
              child: Column(
                children: _twoFirstTransactionDtoList.map((e) {
                  String title = e.reason ?? '';
                  String date = Utils.formatDateDDMM(e.transactionDate);
                  String amountStr = Utils.formatAmount(e.amount);

                  if (e.amount! > 0) {
                    amountStr = '+' + amountStr;
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: Styles.montText,
                              ),
                              Text(
                                date,
                                style: Styles.montSubText,
                              )
                            ],
                          ),
                        ),
                        Text(
                          amountStr,
                          style: Styles.montText,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildAppBar(),
            _buildWalletSection(),
            const SizedBox(
              width: double.infinity,
              height: 20,
            ),
            _buildTabsSection(),
            _buildContentBox(),
          ],
        ),
      ),
    );
  }
}
