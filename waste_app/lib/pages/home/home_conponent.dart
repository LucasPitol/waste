import 'package:waste_app/pages/manage_wallets/edit_wallet.dart';
import 'package:waste_app/pages/home/settings_component.dart';
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
import 'package:waste_app/utils/styles.dart';
import 'see_all_transactions_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';


class HomeComponent extends StatefulWidget {
  HomeComponent({Key key}) : super(key: key);
  @override
  HomeComponentState createState() => HomeComponentState();
}

class HomeComponentState extends State<HomeComponent> {
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

  HomeComponentState() {
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

    await this._getUserWallets();
    await this._getScreenContentData();

    setState(() {
      this.loading = false;
    });
  }

  Future<List<TransactionDto>> getLast2Transactions() async {
    return await this
        .transactionService
        .getLast2Transactions(dropdownWalletValue);
  }

  buildMembersMock() {
    var member1 = MemberDto();
    member1.id = 1;
    member1.name = 'Judas';
    member1.email = 'judasso@gmail.com';

    var member2 = MemberDto();
    member2.id = 2;
    member2.name = 'Jeca';
    member2.email = 'jekinha@gmail.com';

    members.add(member1);
    members.add(member2);
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
    setState(() {
      this.isWalletOwner = this.walletService.isOwner(walletId, uid);
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
    var refresh = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => EditWallet(walletId)));

    if (refresh != null && refresh) {
      updatePageContent();
    }
  }

  _getScreenContentData() async {
    this.transactions = await this.getLast2Transactions();
    this.buildMembersMock();
  }

  Widget _getScreenLayoutContent() {
    int screenOpt = this.screenOptionSelected;

    switch (screenOpt) {
      case 1:
        return Container(
          margin: EdgeInsets.only(top: 20), // remover depois 
          width: double.infinity,
          decoration: Styles.contentBox,
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
                    'Poupado',
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
                      GestureDetector(
                        onTap: () {
                          _openSeeAllTransactionsPage();
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
                        'Membros',
                        style: TextStyle(
                          color: Colors.grey.shade100,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          print('Novo membro');
                        },
                        child: Text(
                          isPtLanguage ? 'Novo membro' : 'New member',
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
                Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Column(
                    children: members
                        .map((item) => createTileForMembers(item))
                        .toList(),
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
        trailing: GestureDetector(
          onTap: () {
            print('remove member');
          },
          child: Container(
            child: Icon(
              Icons.close,
              color: Colors.grey,
            ),
          ),
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

  _goToSettings() async {
    var refresh = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => SettingsComponent()));

    this.userDto = AuthService.currentUser;

    if (refresh != null && refresh) {
      this.isPtLanguage = userDto.language == Constants.languages[0];
      this.updatePageContent();
    }
  }

  _openSeeAllTransactionsPage() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                SeeAllTransactionsComponent(this.currentWallet)));
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
      resizeToAvoidBottomPadding: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                Container(
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
                              'Plano básico',
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
                                child: Icon(
                                  Icons.refresh,
                                  color: Colors.grey.shade100,
                                ),
                              ),
                            ),
                            InkWell(
                              borderRadius: Styles.circularBorderRadius,
                              onTap: () {
                                _goToSettings();
                              },
                              child: Icon(
                                Icons.settings,
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
                  margin: EdgeInsets.only(top: 20),
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
                      isWalletOwner
                          ? Container(
                              alignment: Alignment.topRight,
                              child: GestureDetector(
                                onTap: () {
                                  _goToEditWalletPage();
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
                // Container(
                //   alignment: Alignment.centerLeft,
                //   child: SingleChildScrollView(
                //     scrollDirection: Axis.horizontal,
                //     physics: const BouncingScrollPhysics(),
                //     child: Padding(
                //       padding: EdgeInsets.symmetric(vertical: 20),
                //       child: Row(
                //         children: screenOptions
                //             .map((item) => createScreenOptionsChip(item))
                //             .toList(),
                //       ),
                //     ),
                //   ),
                // ),
                loading
                    ? Container(
                        margin: EdgeInsets.symmetric(vertical: 60),
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: Theme(
                          data: Theme.of(context)
                              .copyWith(accentColor: Colors.deepPurple),
                          child: new CircularProgressIndicator(),
                        ),
                      )
                    : _getScreenLayoutContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
