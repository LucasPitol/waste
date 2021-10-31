import 'package:waste_app/pages/new_wallet_member/new_wallet_member_component.dart';
import 'package:waste_app/pages/dialogs/alert_dialog_component.dart';
import 'package:waste_app/pages/manage_wallets/edit_wallet.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:waste_app/pages/home/settings_component.dart';
import 'package:waste_app/pages/shared/loading_widget.dart';
import 'package:waste_app/services/transactions_service.dart';
import 'package:waste_app/models/dtos/transaction_dto.dart';
import 'package:waste_app/models/screen-option-chip.dart';
import 'package:waste_app/services/wallet_service.dart';
import 'package:waste_app/models/dtos/member-dto.dart';
import 'package:waste_app/services/auth_service.dart';
import 'package:waste_app/models/user_dto.dart';
import 'package:waste_app/utils/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waste_app/models/wallet.dart';
import 'package:waste_app/utils/layout.dart';
import 'see_all_transactions_component.dart';
import 'package:waste_app/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'remove_member_dialog.dart';
import 'leave_wallet_dialog.dart';
import 'package:intl/intl.dart';

class HomeComponent extends StatefulWidget {
  final GlobalKey<OverlayBuilderState> overlayBuilderStatelKey;

  HomeComponent({Key key, this.overlayBuilderStatelKey}) : super(key: key);
  @override
  HomeComponentState createState() =>
      HomeComponentState(overlayBuilderStatelKey);
}

class HomeComponentState extends State<HomeComponent> {
  final GlobalKey<OverlayBuilderState> overlayBuilderStatelKey;
  String localeLanguage =
      AuthService.currentUser.language == Constants.languages[0]
          ? Constants.ptLanguage
          : Constants.enLanguage;
  UserDto userDto = AuthService.currentUser;

  List<ScreenOptionChip> screenOptions = [];
  List<TransactionDto> transactions = [];
  List<MemberDto> members = [];
  int screenOptionSelected;

  TransactionService transactionService;
  WalletService walletService;
  AuthService authService;

  bool isWalletOwner = false;
  bool isPtLanguage;
  bool loading = true;
  List<Wallet> wallets;
  String dropdownWalletValue;
  Wallet currentWallet;

  HomeComponentState(this.overlayBuilderStatelKey) {
    this.isPtLanguage = userDto.language == Constants.languages[0];
    this.transactionService = TransactionService();
    this.walletService = WalletService();
    this.authService = AuthService();
  }

  void initState() {
    super.initState();
    this.updateAppBar();
    this.authService.userExists(context);
    this._buildScreenChipsOptions();
    this.updatePageContent();
    // this._getTotalProfileData();
    this._updatePermission();
  }

  updatePageContent() async {
    setState(() {
      this.loading = true;
    });

    this.updateAppBar();

    await this._getUserWallets();
    await this._getScreenContentData();

    setState(() {
      this.loading = false;
    });
  }

  Future<List<MemberDto>> getMembers() async {
    return this
        .walletService
        .getMembersByWalletId(this.currentWallet.membersId);
  }

  Future<List<TransactionDto>> getLast2Transactions() async {
    return await this
        .transactionService
        .getLast2Transactions(dropdownWalletValue);
  }

  _buildScreenChipsOptions() {
    screenOptionSelected = 1;

    var visionOpt = ScreenOptionChip();
    visionOpt.displayTextPt = 'Visão';
    visionOpt.displayTextEn = 'Vision';
    visionOpt.id = 1;

    var membersOpt = ScreenOptionChip();
    membersOpt.displayTextPt = 'Membros';
    membersOpt.displayTextEn = 'Members';
    membersOpt.id = 2;

    screenOptions.add(visionOpt);
    screenOptions.add(membersOpt);
  }

  void _updatePermission() {
    String walletId = this.userDto.currentWalletId;
    String uid = this.userDto.uid;

    bool isOwner = this.walletService.isOwner(walletId, uid);
    setState(() {
      this.isWalletOwner = isOwner;
    });
  }

  Future<void> _getUserWallets() async {
    setState(() {
      wallets = this.walletService.getUserWalletsLocal();
    });

    this.dropdownWalletValue = this.walletService.getCurrentWalletId();

    String uid = this.userDto.uid;
    List<Wallet> walletsTemp = await this.walletService.getWalletsByUserId(uid);

    setState(() {
      wallets = walletsTemp;
      currentWallet = wallets.where((w) => w.id == dropdownWalletValue).first;
    });
  }

  void switchWallets(String walletId) {
    setState(() {
      this.dropdownWalletValue = walletId;
      currentWallet = wallets.where((w) => w.id == walletId).first;
    });

    this.walletService.switchWallet(walletId);

    this._refreshTransactionsOnly();
    this._updatePermission();
  }

  _refreshTransactionsOnly() async {
    setState(() {
      this.loading = true;
    });

    await this._getScreenContentData();

    setState(() {
      this.loading = false;
    });
  }

  void _goToEditWalletPage() async {
    String walletId = this.userDto.currentWalletId;

    this.overlayBuilderStatelKey.currentState.hideOverlay();

    var refresh = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => EditWallet(walletId)));

    this.overlayBuilderStatelKey.currentState.showOverlay();

    if (refresh != null && refresh) {
      updatePageContent();
    }
  }

  _leavetWallet() async {
    bool leave = await _openLeaveWalletDialog();

    if (leave != null && leave) {
      setState(() {
        this.loading = true;
      });

      await this
          .walletService
          .removeMember(this.userDto.uid, this.dropdownWalletValue);

      this.wallets.remove(this.dropdownWalletValue);

      this.walletService.updateUserWalletsLocal(wallets);
      this.walletService.switchWallet(this.wallets.first.id);

      this._getUserWallets();
      this.updatePageContent();
    }
  }

  Future<bool> _openLeaveWalletDialog() async {
    return await showDialog<bool>(
        context: context,
        builder: (builder) {
          return LeaveWalletDialogComponent(this.currentWallet);
        });
  }

  _removeMember(MemberDto member) async {
    bool deleteMember = await _openRemoveMemberDialog(member);

    if (deleteMember != null && deleteMember) {
      setState(() {
        this.loading = true;
      });

      await this
          .walletService
          .removeMember(member.id, this.dropdownWalletValue);

      this.updatePageContent();
    }
  }

  Future<bool> _openRemoveMemberDialog(MemberDto member) async {
    return await showDialog<bool>(
        context: context,
        builder: (builder) {
          return RemoveMemberDialogComponent(member);
        });
  }

  _getScreenContentData() async {
    this.transactions = await this.getLast2Transactions();
    this.members = await this.getMembers();
  }

  Widget _getScreenLayoutContent() {
    int screenOpt = this.screenOptionSelected;

    switch (screenOpt) {
      case 1:
        return Container(
          width: double.infinity,
          decoration: Styles.contentBox,
          margin: EdgeInsets.symmetric(horizontal: 15),
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  alignment: Alignment.topLeft,
                  child: Text(
                    Constants.getAmountFormated(currentWallet.totalBalance),
                    style: TextStyle(
                      color: Colors.grey.shade100,
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  alignment: Alignment.topLeft,
                  child: Text(
                    isPtLanguage ? 'Caixa' : 'Balance',
                    style: TextStyle(
                      color: Colors.grey.shade100,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        isPtLanguage ? 'Transações' : 'Transactions',
                        style: Styles.poppinsTextGrey,
                      ),
                      Container(
                        // alignment: Alignment.topRight,
                        child: InkWell(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                          onTap: () {
                            this._openSeeAllTransactionsPage();
                          },
                          child: Text(
                            isPtLanguage ? 'Ver todas' : 'See all',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14.0,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: transactions != null && transactions.isNotEmpty
                      ? Column(
                          children: transactions
                              .map((item) => createTileForTransactions(item))
                              .toList(),
                        )
                      : Container(
                          child: Text(
                            isPtLanguage
                                ? 'Nenhuma transação'
                                : 'No transactions',
                            style: TextStyle(
                              color: Colors.grey.shade100,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
        break;

      case 2:
        return Container(
          width: double.infinity,
          decoration: Styles.contentBox,
          margin: EdgeInsets.symmetric(horizontal: 15),
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        isPtLanguage ? 'Membros' : 'Members',
                        style: TextStyle(
                          color: Colors.grey.shade100,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      isWalletOwner
                          ? GestureDetector(
                              onTap: () {
                                this._goToNewMemberPage();
                              },
                              child: Text(
                                isPtLanguage ? 'Novo membro' : 'New member',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14.0,
                                  color: Colors.deepPurple,
                                ),
                              ),
                            )
                          : GestureDetector(
                              onTap: () {
                                this._leavetWallet();
                              },
                              child: Text(
                                isPtLanguage
                                    ? 'Deixar carteira'
                                    : 'Leave wallet',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14.0,
                                  color: Colors.deepPurple,
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
                members.isNotEmpty
                    ? Container(
                        margin: EdgeInsets.only(top: 10),
                        child: Column(
                          children: members
                              .map((item) => createTileForMembers(item))
                              .toList(),
                        ),
                      )
                    : Container(
                        margin: EdgeInsets.only(top: 20, bottom: 10),
                        child: Text(
                          isPtLanguage
                              ? 'Nenhum membro nessa carteira'
                              : 'No members',
                          style: Styles.poppinsTextLight,
                        ),
                      ),
              ],
            ),
          ),
        );
        break;

      default:
        return Container();
        break;
    }
  }

  Widget createScreenOptionsChip(ScreenOptionChip item) {
    bool isOptionSelected = item.id == this.screenOptionSelected;

    String displayText = isPtLanguage ? item.displayTextPt : item.displayTextEn;

    TextStyle displayTextStyle = TextStyle(
        fontSize: 14,
        color: isOptionSelected ? Colors.grey.shade100 : Colors.grey);

    return GestureDetector(
      onTap: () {
        setState(() {
          this.screenOptionSelected = item.id;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color:
              isOptionSelected ? Styles.boxColor : Styles.mainBackgroundColor,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Text(
          displayText,
          style: displayTextStyle,
        ),
      ),
    );
  }

  Widget createTileForMembers(MemberDto item) {
    return Container(
      child: ListTile(
        trailing: isWalletOwner
            ? GestureDetector(
                onTap: () {
                  this._removeMember(item);
                },
                child: Container(
                  child: FaIcon(
                    FontAwesomeIcons.times,
                    size: 18,
                    color: Colors.grey,
                  ),
                ),
              )
            : Container(
                width: 1,
                height: 1,
              ),
        title: Text(
          item.name,
          style: TextStyle(
              color: Colors.grey.shade100,
              fontSize: 18,
              fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          item.email,
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Future<void> _openInfoDialog(String title, String content) async {
    await showDialog<String>(
        context: context,
        builder: (builder) {
          return AlertDialogComponent(title, content);
        });
  }

  _goToNewMemberPage() async {
    if (currentWallet.membersId.length >= Constants.walletMembersLimit) {
      String title = 'Ops..';
      String text = isPtLanguage
          ? 'Limite de membros excedido nessa carteira, em breve o limite será estendido'
          : 'Limit of members exceeded in this wallet, soon the limit will be extended';

      _openInfoDialog(title, text);
    } else {
      List<String> membersMail = <String>[];

      members.forEach((element) {
        membersMail.add(element.email);
      });

      this.overlayBuilderStatelKey.currentState.hideOverlay();

      var refresh = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  NewWalletMemberComponent(this.currentWallet, membersMail)));

      this.overlayBuilderStatelKey.currentState.showOverlay();

      if (refresh != null && refresh) {
        this.updatePageContent();
      }
    }
  }

  _goToSettings() async {
    this.overlayBuilderStatelKey.currentState.hideOverlay();

    var refresh = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => SettingsComponent()));

    this.overlayBuilderStatelKey.currentState.showOverlay();

    this.userDto = AuthService.currentUser;

    if (refresh != null && refresh) {
      this.isPtLanguage = userDto.language == Constants.languages[0];
      this.updatePageContent();
    }
  }

  _openSeeAllTransactionsPage() async {
    this.overlayBuilderStatelKey.currentState.hideOverlay();

    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                SeeAllTransactionsComponent(this.currentWallet)));

    this.overlayBuilderStatelKey.currentState.showOverlay();
  }

  Widget createTileForTransactions(TransactionDto item) {
    String transactionDate =
        DateFormat.Md(this.localeLanguage).format(item.transactionDate) +
            ', ' +
            DateFormat.Hm(this.localeLanguage).format(item.transactionDate);

    String ammount = item.amount > 0
        ? '+' + Constants.getAmountFormated(item.amount)
        : Constants.getAmountFormated(item.amount);

    return Container(
      child: ListTile(
        trailing: Text(
          ammount,
          style: TextStyle(
            color: Colors.grey.shade100,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        title: Text(
          item.reason,
          style: TextStyle(
              color: Colors.grey.shade100,
              fontSize: 18,
              fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          transactionDate,
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  updateAppBar() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Styles.mainBackgroundColor,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.mainBackgroundColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(left: 20, right: 20, top: 10),
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Container(
                            alignment: Alignment.topLeft,
                            child: Text(
                              this.userDto.name,
                              style: TextStyle(
                                color: Colors.grey.shade100,
                                fontWeight: FontWeight.w600,
                                fontSize: 24,
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.topLeft,
                            child: Text(
                              isPtLanguage ? 'Plano básico' : 'Standard plan',
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              margin: EdgeInsets.only(right: 15),
                              child: InkWell(
                                borderRadius: Styles.circularBorderRadius,
                                onTap: () {
                                  this.updatePageContent();
                                },
                                child: FaIcon(
                                  FontAwesomeIcons.redo,
                                  size: 20,
                                  color: Colors.grey.shade100,
                                ),
                              ),
                            ),
                            InkWell(
                              borderRadius: Styles.circularBorderRadius,
                              onTap: () {
                                _goToSettings();
                              },
                              child: FaIcon(
                                FontAwesomeIcons.bars,
                                size: 20,
                                color: Colors.grey.shade100,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.only(top: 20, left: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        child: DropdownButton<String>(
                          dropdownColor: Styles.mainBackgroundColor,
                          value: dropdownWalletValue,
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            // color: Colors.grey,
                          ),
                          iconSize: 24,
                          elevation: 16,
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade100,
                              fontSize: 14,
                            ),
                          ),
                          underline: Container(
                            height: 1,
                            color: Styles.mainBackgroundColor,
                          ),
                          onChanged: (String newValue) {
                            switchWallets(newValue);
                          },
                          items: wallets
                              .map<DropdownMenuItem<String>>((Wallet item) {
                            return DropdownMenuItem<String>(
                              value: item.id,
                              child: Text(
                                item.name,
                                style: Styles.poppinsTextLight,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      (isWalletOwner)
                          ? Container(
                              alignment: Alignment.topRight,
                              child: InkWell(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4)),
                                onTap: () {
                                  this._goToEditWalletPage();
                                },
                                child: Text(
                                  isPtLanguage ? 'Editar' : 'Edit',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14.0,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                      child: Row(
                        children: screenOptions
                            .map((item) => createScreenOptionsChip(item))
                            .toList(),
                      ),
                    ),
                  ),
                ),
                loading ? LoadingWidget() : _getScreenLayoutContent(),
                // PlansCarouselComponent(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
