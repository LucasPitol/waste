import 'package:bezier_chart/bezier_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:waste_app/models/dtos/revenue_block_dto.dart';
import 'package:waste_app/models/dtos/transaction_dto.dart';
import 'package:waste_app/models/filter-option-chip.dart';
import 'package:waste_app/models/user_dto.dart';
import 'package:waste_app/services/auth_service.dart';
import 'package:waste_app/services/transactions_service.dart';
import 'package:waste_app/utils/constants.dart';
import 'package:waste_app/utils/styles.dart';

class RevenuesComponent extends StatefulWidget {
  // RevenuesComponent({Key key}) : super(key: key);
  @override
  RevenuesComponentState createState() => RevenuesComponentState();
}

class RevenuesComponentState extends State<RevenuesComponent> {
  String localeLanguage =
      AuthService.currentUser.language == Constants.languages[0]
          ? Constants.ptLanguage
          : Constants.enLanguage;
  UserDto userDto = AuthService.currentUser;
  bool isPtLanguage;

  List<RevenueBlockDto> revenues = [];
  List<FilterOptionChip> filterOptions = [];
  int filterSelected;

  TransactionService transactionService;
  AuthService authService;

  RevenuesComponentState() {
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

    var oneMonthOpt = FilterOptionChip();
    oneMonthOpt.displayTextPt = '1 mês';
    oneMonthOpt.displayTextEn = '1 month';
    oneMonthOpt.id = 1;
    oneMonthOpt.enable = true;

    var threeMonthOpt = FilterOptionChip();
    threeMonthOpt.displayTextPt = '3 meses';
    threeMonthOpt.displayTextEn = '3 months';
    threeMonthOpt.id = 2;
    threeMonthOpt.enable = true;

    var sixMonthOpt = FilterOptionChip();
    sixMonthOpt.displayTextPt = '6 meses';
    sixMonthOpt.displayTextEn = '6 months';
    sixMonthOpt.id = 3;
    sixMonthOpt.enable = false;

    var oneYearOpt = FilterOptionChip();
    oneYearOpt.displayTextPt = '1 ano';
    oneYearOpt.displayTextEn = '1 year';
    oneYearOpt.id = 4;
    oneYearOpt.enable = false;

    var fiveYearOpt = FilterOptionChip();
    fiveYearOpt.displayTextPt = '5 anos';
    fiveYearOpt.displayTextEn = '5 years';
    fiveYearOpt.id = 5;
    fiveYearOpt.enable = false;

    filterOptions.add(oneMonthOpt);
    filterOptions.add(threeMonthOpt);
    filterOptions.add(sixMonthOpt);
    filterOptions.add(oneYearOpt);
    filterOptions.add(fiveYearOpt);
  }

  Widget createTileForRevenues(RevenueBlockDto item) {
    String totalAmount = '+' + item.totalIncome.toStringAsFixed(2);

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
                  totalAmount,
                  style: Styles.poppinsTextGrey,
                ),
              ],
            ),
          ),
          Container(
            child: Column(
              children: item.revenues
                  .map((item) => createTileForTransactions(item))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget createTileForTransactions(TransactionDto item) {
    String transactionDate =
        DateFormat.Md(this.localeLanguage).format(item.transactionDate);

    String amount = item.amount > 0
        ? '+' + item.amount.toStringAsFixed(2)
        : item.amount.toStringAsFixed(2);

    return Container(
      margin: EdgeInsets.only(top: 10),
      child: ListTile(
        trailing: Text(
          amount,
          style: TextStyle(
            color: Colors.grey.shade100,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        title: Text(
          item.reason,
          style: TextStyle(
              color: Colors.grey.shade100,
              fontSize: 14,
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
                          'Receitas',
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
                Container(
                  height: 300,
                  width: double.infinity,
                  child: BezierChart(
                    bezierChartScale: BezierChartScale.CUSTOM,
                    xAxisCustomValues: [1, 2, 3, 4, 5, 6, 7, 8],
                    footerValueBuilder: (double number) {
                      String value = '';

                      if (number == 1) {
                        value = 'Jan';
                      }

                      if (number == 2) {
                        value = 'Fev';
                      }

                      if (number == 3) {
                        value = 'Mar';
                      }

                      if (number == 4) {
                        value = 'Abr';
                      }

                      if (number == 5) {
                        value = 'Mai';
                      }

                      if (number == 6) {
                        value = 'Jun';
                      }

                      if (number == 7) {
                        value = 'Jul';
                      }

                      if (number == 8) {
                        value = 'Ago';
                      }

                      return value;
                    },
                    series: [
                      BezierLine(
                        lineColor: Colors.deepPurple,
                        label: 'Receita',
                        data: [
                          DataPoint<double>(value: 1500.00, xAxis: 1),
                          DataPoint<double>(value: 1500.00, xAxis: 2),
                          DataPoint<double>(value: 1510.00, xAxis: 3),
                          DataPoint<double>(value: 1550.00, xAxis: 4),
                          DataPoint<double>(value: 1300.00, xAxis: 5),
                          DataPoint<double>(value: 1350.00, xAxis: 6),
                          DataPoint<double>(value: 1600.00, xAxis: 7),
                          DataPoint<double>(value: 1580.00, xAxis: 8),
                        ],
                      ),
                      BezierLine(
                        lineColor: Colors.red.shade900,
                        label: 'Despesa',
                        data: [
                          DataPoint<double>(value: 1300.00, xAxis: 1),
                          DataPoint<double>(value: 1350.00, xAxis: 2),
                          DataPoint<double>(value: 1280.00, xAxis: 3),
                          DataPoint<double>(value: 1200.00, xAxis: 4),
                          DataPoint<double>(value: 1400.00, xAxis: 5),
                          DataPoint<double>(value: 1210.00, xAxis: 6),
                          DataPoint<double>(value: 1150.00, xAxis: 7),
                          DataPoint<double>(value: 1200.00, xAxis: 8),
                        ],
                      ),
                    ],
                    config: BezierChartConfig(
                      displayLinesXAxis: true,
                      xLinesColor: Colors.grey.shade900,
                      verticalIndicatorStrokeWidth: 2.0,
                      verticalIndicatorColor: Colors.grey,
                      showVerticalIndicator: true,
                      displayYAxis: true,
                      displayDataPointWhenNoValue: false,
                      startYAxisFromNonZeroValue: true,
                      backgroundColor: Styles.mainBackgroundColor,
                      stepsYAxis: 50,
                      snap: false,
                    ),
                  ),
                ),
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
                    children: revenues
                        .map((item) => createTileForRevenues(item))
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
    var revenueBlock1 = RevenueBlockDto();
    revenueBlock1.blockDate = DateTime(2020, 01);
    revenueBlock1.isMonthly = true;
    revenueBlock1.totalIncome = 1500;
    var transaction1ForBlock1 = TransactionDto();
    transaction1ForBlock1.amount = 1500;
    transaction1ForBlock1.reason = 'Pró-labore (empresa x)';
    transaction1ForBlock1.transactionDate = DateTime(2020, 01, 05);
    revenueBlock1.revenues.add(transaction1ForBlock1);

    var revenueBlock2 = RevenueBlockDto();
    revenueBlock2.blockDate = DateTime(2020, 02);
    revenueBlock2.isMonthly = true;
    revenueBlock2.totalIncome = 1550;
    var transaction1ForBlock2 = TransactionDto();
    transaction1ForBlock2.amount = 1500;
    transaction1ForBlock2.reason = 'Pró-labore (empresa x)';
    transaction1ForBlock2.transactionDate = DateTime(2020, 02, 05);
    var transaction2ForBlock2 = TransactionDto();
    transaction2ForBlock2.amount = 50;
    transaction2ForBlock2.reason = 'Dividendos';
    transaction2ForBlock2.transactionDate = DateTime(2020, 02, 15);
    revenueBlock2.revenues.add(transaction1ForBlock2);
    revenueBlock2.revenues.add(transaction2ForBlock2);

    revenues.add(revenueBlock1);
    revenues.add(revenueBlock2);
  }
}
