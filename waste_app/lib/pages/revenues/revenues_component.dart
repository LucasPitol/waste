import 'package:bezier_chart/bezier_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}
