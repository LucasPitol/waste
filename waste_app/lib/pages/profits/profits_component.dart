import 'package:waste_app/services/transactions_service.dart';
import 'package:waste_app/models/dtos/profits_block_dto.dart';
import 'package:waste_app/models/dtos/transaction_dto.dart';
import 'package:waste_app/models/filter-option-chip.dart';
import 'package:waste_app/services/auth_service.dart';
import 'package:waste_app/utils/constants.dart';
import 'package:waste_app/models/user_dto.dart';
import 'package:waste_app/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ProfitsComponent extends StatefulWidget {
  // RevenuesComponent({Key key}) : super(key: key);
  @override
  ProfitsComponentState createState() => ProfitsComponentState();
}

class ProfitsComponentState extends State<ProfitsComponent> {
  String localeLanguage =
      AuthService.currentUser.language == Constants.languages[0]
          ? Constants.ptLanguage
          : Constants.enLanguage;
  UserDto userDto = AuthService.currentUser;
  bool isPtLanguage;

  List<FilterOptionChip> filterOptions = [];
  List<ProfitsBlockDto> profitList = [];
  int filterSelected;

  TransactionService transactionService;
  AuthService authService;

  ProfitsComponentState() {
    this.isPtLanguage = userDto.language == Constants.languages[0];
    this.transactionService = TransactionService();
    this.authService = AuthService();
  }

  void initState() {
    super.initState();
    this.updateAppBar();
    this._buildFilterChipsOptions();
    this._buildRevenuesMock();
    this.authService.userExists(context);
  }

  updateAppBar() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Styles.mainBackgroundColor,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  _buildFilterChipsOptions() {
    filterSelected = 1;

    var monthlyOpt = FilterOptionChip();
    monthlyOpt.displayTextPt = 'Mensal';
    monthlyOpt.displayTextEn = 'Monthly';
    monthlyOpt.id = 1;
    monthlyOpt.enable = true;

    var yearlyOpt = FilterOptionChip();
    yearlyOpt.displayTextPt = 'Anual';
    yearlyOpt.displayTextEn = 'Yearly';
    yearlyOpt.id = 2;
    yearlyOpt.enable = false;

    filterOptions.add(monthlyOpt);
    filterOptions.add(yearlyOpt);
  }

  Widget createTileForProfits(ProfitsBlockDto item) {

    print(item.profit);
    print(item.revenue);
    String profit = item.profit > 0
        ? '+' + item.profit.toStringAsFixed(2)
        : item.profit.toStringAsFixed(2);

    String revenue = item.revenue > 0
        ? '+' + item.revenue.toStringAsFixed(2)
        : item.revenue.toStringAsFixed(2);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  DateFormat.yMMM(this.localeLanguage).format(item.blockDate),
                  style: Styles.poppinsTextGrey,
                ),
                Text(
                  profit,
                  style: Styles.poppinsTextGrey,
                ),
              ],
            ),
          ),
          Container(
            child: Column(
              children: [
                ListTile(
                  title: Container(
                    margin: EdgeInsets.only(top: 10),
                    child: ListTile(
                      trailing: Text(
                        revenue,
                        style: TextStyle(
                          color: Colors.grey.shade100,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      title: Text(
                        isPtLanguage ? 'Receita' : 'Revenue',
                        style: TextStyle(
                            color: Colors.grey.shade100,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget createFilterOptionsChip(FilterOptionChip item) {
    bool isOptionSelected = item.id == this.filterSelected;

    bool enabled = item.enable;

    String displayText = isPtLanguage ? item.displayTextPt : item.displayTextEn;

    Color textColor;

    if (enabled) {
      textColor = isOptionSelected ? Styles.mainBackgroundColor : Colors.grey;
    } else {
      textColor = Colors.grey.shade900;
    }

    TextStyle displayTextStyle = TextStyle(fontSize: 14, color: textColor);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (enabled) {
            this.filterSelected = item.id;
          }
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color:
              isOptionSelected ? Colors.deepPurple : Styles.mainBackgroundColor,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Text(
          displayText,
          style: displayTextStyle,
        ),
      ),
    );
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
                      Container(
                        alignment: Alignment.topLeft,
                        child: Text(
                          isPtLanguage ? 'Lucro\$' : 'Profit\$',
                          style: TextStyle(
                            color: Colors.grey.shade100,
                            fontWeight: FontWeight.w600,
                            fontSize: 24,
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.topRight,
                        margin: EdgeInsets.only(top: 10),
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
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Row(
                        children: filterOptions
                            .map((item) => createFilterOptionsChip(item))
                            .toList(),
                      ),
                    ),
                  ),
                ),
                Container(),
                Container(
                  alignment: Alignment.topRight,
                  child: Text(
                    '10% a.a',
                    style: TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.w600,
                        fontSize: 16),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    children: profitList
                        .map((item) => createTileForProfits(item))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _buildRevenuesMock() {
    var revenueBlock1 = ProfitsBlockDto();
    revenueBlock1.blockDate = DateTime(2020, 01);
    revenueBlock1.profit = 1050;
    revenueBlock1.revenue = 2000;
    revenueBlock1.spends = -950;

    var revenueBlock2 = ProfitsBlockDto();
    revenueBlock2.blockDate = DateTime(2020, 02);
    revenueBlock2.profit = 1050;
    revenueBlock2.revenue = 2000;
    revenueBlock2.spends = -950;

    profitList.add(revenueBlock1);
    profitList.add(revenueBlock2);
  }
}
