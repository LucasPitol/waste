import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:meudin_app/models/dtos/member-dto.dart';
import 'package:meudin_app/models/dtos/response_dto.dart';
import 'package:meudin_app/models/dtos/tab_selector_dto.dart';
import 'package:meudin_app/models/dtos/transaction_dto.dart';
import 'package:meudin_app/models/wallet.dart';
import 'package:meudin_app/pages/list_transactions/list_transactions_component.dart';
import 'package:meudin_app/pages/new_wallet_member/new_wallet_member_component.dart';
import 'package:meudin_app/pages/settings/settings_component.dart';
import 'package:meudin_app/pages/shared/info_bottom_sheet_widget.dart';
import 'package:meudin_app/pages/shared/loading_widget.dart';
import 'package:meudin_app/pages/shared/option_bottom_sheet_widget.dart';
import 'package:meudin_app/services/transaction_service.dart';
import 'package:meudin_app/services/user_service.dart';
import 'package:meudin_app/services/wallet_service.dart';
import 'package:meudin_app/utils/constants.dart';
import 'package:meudin_app/utils/styles.dart';
import 'package:meudin_app/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meudin_app/utils/utils.dart';

import 'new_wallet_component.dart';
import 'switch_date_bottom_sheet_widget.dart';
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
  late WalletService _walletService;
  late TransactionService _transactionService;

  double _monthRevenue = 0.0;
  double _monthSpends = 0.0;
  double _monthBalance = 0.0;
  bool _isWalletOwner = false;

  late bool _loading;
  late List<TabSelector> _tabs;
  late int _tabSelected;
  late List<TransactionDto> transactionDtoList;
  late List<TransactionDto> _twoFirstTransactionDtoList;
  late DateTime startDate;
  late DateTime endDate;
  late List<MemberDto> _walletMembers;

  HomeComponentState() {
    _user = UserService.currentUser;
    _transactionService = TransactionService();
    _walletService = WalletService();
    _currentWallet = _user!.walletList
        .singleWhere((element) => element.id == _user!.currentWalletId);
    _isWalletOwner = (_currentWallet.ownerId == _user!.id);
    _userService = UserService();
    _tabs = <TabSelector>[];
    _tabSelected = 0;
    _loading = false;
    transactionDtoList = <TransactionDto>[];
    _twoFirstTransactionDtoList = <TransactionDto>[];
    _walletMembers = <MemberDto>[];
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
    await _updateMembersList();

    setState(() {
      _loading = false;
    });
  }

  _updateUserWallets() async {
    await _userService.updateUserWallets();

    _user = UserService.currentUser;

    Wallet _currentWalletTemp = _user!.walletList
        .singleWhere((element) => element.id == _user!.currentWalletId);

    bool isWalletOwnerTemp = (_currentWalletTemp.ownerId == _user!.id);

    setState(() {
      _currentWallet = _currentWalletTemp;
      _isWalletOwner = isWalletOwnerTemp;
    });
  }

  _updateMembersList() async {
    List<String> memberIdList = _currentWallet.membersId;

    ResponseDto res = await _userService.getMembersByMemberIds(memberIdList);

    if (res.success) {
      _walletMembers = res.data;
    }
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
              _goToSettings();
            },
          ),
        ],
      ),
    );
  }

  _goToSettings() async {
    bool? refresh = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return SettingsComponent();
    }));

    if (refresh != null && refresh) {
      updatePageData();
    }
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

    bool isWalletOwnerTemp = (walletTemp.ownerId == _user!.id);

    setState(() {
      _currentWallet = walletTemp;
      _isWalletOwner = isWalletOwnerTemp;
    });

    updatePageData();
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
          return _buildMemberBox();

        default:
          return Container();
      }
    }
  }

  _openSwitchDateBottomSheet() async {
    DateTime? newDate = await showModalBottomSheet(
        context: context,
        backgroundColor: Styles.cardColor,
        builder: (builder) {
          return SwitchDateBottomSheetWidget(
            startDate: startDate,
          );
        });

    if (newDate != null) {
      startDate = DateTime(newDate.year, newDate.month, 1);
      int endDateDay = endDate.day;
      endDate = DateTime(newDate.year, newDate.month, endDateDay);
      updatePageData();
    }
  }

  _goToNewMemberPage() async {
    bool? refresh = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return NewWalletMemberComponent(
        currentWallet: _currentWallet,
        walletMembers: _walletMembers,
      );
    }));

    if (refresh != null && refresh) {
      updatePageData();
    }
  }

  _leaveWallet() async {
    String title;
    String message;

    List<Wallet> userWallets = _user!.walletList;

    if (userWallets.length <= 1) {
      title = 'Atenção!';
      message = 'Você não pode deixar sua única carteira';

      _openInfoBottomSheet(title, message);
    } else {
      title = 'Deixar de acompanhar a carteira?';
      String walletName = _currentWallet.name;
      message =
          'Você poderá volta para \'$walletName\' se for convidado novamente';

      String actionTitle = 'Deixar carteira';
      String cancelTitle = 'Cancelar';

      bool? leave = await _openOptionBottomSheet(
          title, message, actionTitle, cancelTitle);

      if (leave != null && leave) {
        setState(() {
          _loading = true;
        });

        Wallet wallet = _currentWallet;
        String uid = _user!.id;

        _walletService.removeMember(uid, wallet).then((value) {
          userWallets.remove(wallet);

          String walletIdToSwitch = userWallets.first.id;

          _switchCurrentWallet(walletIdToSwitch);
        });
      }
    }
  }

  _openOptionBottomSheet(String title, String message, String actionTitle,
      String cancelTitle) async {
    return await showModalBottomSheet(
      context: context,
      backgroundColor: Styles.cardColor,
      builder: (builder) {
        return OptionBottomSheetWidget(
          title: title,
          message: message,
          actionTitle: actionTitle,
          cancelTitle: cancelTitle,
        );
      },
    );
  }

  Widget _buildMemberBox() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      width: double.infinity,
      decoration: Styles.cardDecoration,
      child: SizedBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  'Membros',
                  style: Styles.montTextTitle,
                ),
                _isWalletOwner
                    ? TextButton(
                        onPressed: () {
                          _goToNewMemberPage();
                        },
                        child: Text(
                          'Adicionar membro',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Styles.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : TextButton(
                        onPressed: () {
                          _leaveWallet();
                        },
                        child: Text(
                          'Deixar carteira',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Styles.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ],
            ),
            //
            _walletMembers.isNotEmpty
                ? Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: Column(
                      children: _walletMembers
                          .map((item) => createTileForMembers(item))
                          .toList(),
                    ),
                  )
                : Container(
                    margin: const EdgeInsets.only(top: 20, bottom: 10),
                    child: Text(
                      'Nenhum membro nesta carteira',
                      style: Styles.montTextGrey,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  _removeMember(MemberDto member) async {
    String title = 'Remover membro?';
    String walletName = _currentWallet.name;
    String memberName = member.name;
    String message =
        'Remover $memberName de \'$walletName\'? \nVocê poderá convida-lo novamente';

    String actionTitle = 'Remover membro';
    String cancelTitle = 'Cancelar';

    bool? remove =
        await _openOptionBottomSheet(title, message, actionTitle, cancelTitle);

    if (remove != null && remove) {
      setState(() {
        _loading = true;
      });

      Wallet wallet = _currentWallet;
      String memberId = member.id;

      _walletService.removeMember(memberId, wallet).then((value) {
        updatePageData();
      });
    }
  }

  Widget createTileForMembers(MemberDto member) {
    bool self = (member.id == _user!.id);

    Widget trailing = _isWalletOwner
        ? self
            ? const SizedBox(
                width: 1,
                height: 1,
              )
            : IconButton(
                icon: const FaIcon(
                  FontAwesomeIcons.times,
                  color: Colors.grey,
                  size: 20, // 18
                ),
                onPressed: () {
                  _removeMember(member);
                },
              )
        : const SizedBox(
            width: 1,
            height: 1,
          );

    return ListTile(
      trailing: trailing,
      title: Text(
        member.name,
        style: TextStyle(
            color: Colors.grey.shade100,
            fontSize: 18,
            fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        member.email,
        style: Styles.montSubText,
      ),
    );
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
                    _openSwitchDateBottomSheet();
                  },
                  child: Text(
                    DateFormat.yMMMM(Constants.ptLanguage).format(startDate),
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
                    _goToSeeAllTransactionsPage();
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

  _goToSeeAllTransactionsPage() async {
    bool? refresh = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return ListTransactionsComponent(
        startDate: startDate,
        endDate: endDate,
        transactionDtoList: transactionDtoList,
      );
    }));

    if (refresh != null && refresh) {
      updatePageData();
    }
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
