import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:waste_app/models/dtos/member-dto.dart';
import 'package:waste_app/models/dtos/transaction_dto.dart';
import 'package:waste_app/models/screen-option-chip.dart';
import 'package:waste_app/models/user_dto.dart';
import 'package:waste_app/models/wallet.dart';
import 'package:waste_app/services/auth_service.dart';
import 'package:waste_app/services/transactions_service.dart';
import 'package:waste_app/services/wallet_service.dart';
import 'package:waste_app/utils/constants.dart';
import 'package:waste_app/utils/styles.dart';

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
  List<Wallet> wallets;
  String dropdownWalletValue;

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
    this._getUserWallets();
    // this._getTotalProfileData();
    this._updatePermission();
    this._getScreenContent();
  }

  buildTransactionsMock() {
    var transaction1 = TransactionDto();
    transaction1.amount = 500.00;
    transaction1.reason = 'Dividendos';
    transaction1.transactionDate = DateTime(2020, 09, 15);

    var transaction2 = TransactionDto();
    transaction2.amount = -80.00;
    transaction2.reason = 'Restaurante';
    transaction2.transactionDate = DateTime(2020, 09, 10);

    transactions.add(transaction1);
    transactions.add(transaction2);
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
    });
  }

  void switchWallets(String walletId) {
    setState(() {
      this.dropdownWalletValue = walletId;
    });

    this.walletService.switchWallet(walletId);

    // this._getTotalProfileData();
    this._updatePermission();
  }

  _getScreenContent() {
    int screenOpt = this.screenOptionSelected;

    this.buildTransactionsMock();
    this.buildMembersMock();

    // switch (screenOpt) {
    //   case 1:
    //     this.buildTransactionsMock();
    //     break;

    //   case 2:
    //     this.buildMembersMock();
    //     break;

    //   default:
    //     break;
    // }
  }

  Widget _getScreenLayoutContent() {
    int screenOpt = this.screenOptionSelected;

    switch (screenOpt) {
      case 1:
        return Container(
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
                    '50,000.00',
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
                        'Transações',
                        style: Styles.poppinsTextGrey,
                      ),
                      GestureDetector(
                        onTap: () {
                          // _goToEditWalletPage();
                          print('Ver todas');
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
                  child: Column(
                    children: transactions
                        .map((item) => createTileForTransactions(item))
                        .toList(),
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

  Widget createTileForTransactions(TransactionDto item) {
    String transactionDate =
        DateFormat.Md(this.localeLanguage).format(item.transactionDate);

    String ammount = item.amount > 0
        ? '+' + item.amount.toStringAsFixed(2)
        : item.amount.toStringAsFixed(2);

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
                              'Rombado',
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
                              child: GestureDetector(
                                onTap: () {
                                  print('settings');
                                },
                                child: Icon(
                                  Icons.refresh,
                                  color: Colors.grey.shade100,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                print('settings');
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
                                  // _goToEditWalletPage();
                                  print('edit wallet');
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
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        children: screenOptions
                            .map((item) => createScreenOptionsChip(item))
                            .toList(),
                      ),
                    ),
                  ),
                ),
                _getScreenLayoutContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
