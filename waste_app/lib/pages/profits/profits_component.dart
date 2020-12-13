import 'package:fl_chart/fl_chart.dart';
import 'package:waste_app/services/transactions_service.dart';
import 'package:waste_app/models/dtos/profits_block_dto.dart';
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
  List<BarChartGroupData> rawBarGroups;
  List<BarChartGroupData> showingBarGroups;
  BarChartData chartData;
  int filterSelected;
  bool graphLoading;
  bool profitListLoading;

  TransactionService transactionService;
  AuthService authService;

  ProfitsComponentState() {
    this.isPtLanguage = userDto.language == Constants.languages[0];
    this.transactionService = TransactionService();
    this.authService = AuthService();
    this.chartData = BarChartData();
  }

  void initState() {
    super.initState();
    this.updateAppBar();
    this._buildFilterChipsOptions();
    this._buildGraphMock();
    this._updateData();
    this.authService.userExists(context);
  }

  updateAppBar() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Styles.mainBackgroundColor,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  _updateData() {
    setState(() {
      this.graphLoading = true;
      this.profitListLoading = true;
    });

    if (filterSelected == 1) {
      this.transactionService.getProfitsByMonth().then((value) {

        this.profitList = value;

        setState(() {
          this.profitListLoading = false;
        });
      });

    }

    setState(() {
      this.graphLoading = false;
    });
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
    String profit = item.profit > 0
        ? '+' + item.profit.toStringAsFixed(2)
        : item.profit.toStringAsFixed(2);

    String revenue = item.revenue > 0
        ? '+' + item.revenue.toStringAsFixed(2)
        : item.revenue.toStringAsFixed(2);

    String spend = item.spends.toStringAsFixed(2);

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
                  style: Styles.poppinsText,
                ),
                Text(
                  profit,
                  style: Styles.poppinsText,
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
                        style: Styles.poppinsTextGrey,
                      ),
                      title: Text(
                        isPtLanguage ? 'Receita' : 'Revenue',
                        style: Styles.poppinsTextGrey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            child: Column(
              children: [
                ListTile(
                  title: Container(
                    child: ListTile(
                      trailing: Text(
                        spend,
                        style: Styles.poppinsTextGrey,
                      ),
                      title: Text(
                        isPtLanguage ? 'Despesa' : 'Expense',
                        style: Styles.poppinsTextGrey,
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
                        margin: EdgeInsets.only(top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              margin: EdgeInsets.only(right: 15),
                              child: InkWell(
                                borderRadius: Styles.circularBorderRadius,
                                onTap: () {
                                  print('update');
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
                                print('info');
                              },
                              child: Icon(
                                Icons.help_outline,
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
                  margin: EdgeInsets.symmetric(vertical: 20),
                  child: BarChart(
                    BarChartData(
                      maxY: 20,
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBgColor: Colors.grey,
                          getTooltipItem: (_a, _b, _c, _d) => null,
                        ),
                        // touchCallback: (response) {
                        //   if (response.spot == null) {
                        //     setState(() {
                        //       touchedGroupIndex = -1;
                        //       showingBarGroups = List.of(rawBarGroups);
                        //     });
                        //     return;
                        //   }

                        //   touchedGroupIndex =
                        //       response.spot.touchedBarGroupIndex;

                        //   setState(
                        //     () {
                        //       if (response.touchInput is FlLongPressEnd ||
                        //           response.touchInput is FlPanEnd) {
                        //         touchedGroupIndex = -1;
                        //         showingBarGroups = List.of(rawBarGroups);
                        //       } else {
                        //         showingBarGroups = List.of(rawBarGroups);
                        //         if (touchedGroupIndex != -1) {
                        //           double sum = 0;
                        //           for (BarChartRodData rod
                        //               in showingBarGroups[touchedGroupIndex]
                        //                   .barRods) {
                        //             sum += rod.y;
                        //           }
                        //           final avg = sum /
                        //               showingBarGroups[touchedGroupIndex]
                        //                   .barRods
                        //                   .length;

                        //           showingBarGroups[touchedGroupIndex] =
                        //               showingBarGroups[touchedGroupIndex]
                        //                   .copyWith(
                        //             barRods: showingBarGroups[touchedGroupIndex]
                        //                 .barRods
                        //                 .map((rod) {
                        //               return rod.copyWith(y: avg);
                        //             }).toList(),
                        //           );
                        //         }
                        //       }
                        //     },
                        //   );
                        // },
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: SideTitles(
                          showTitles: true,
                          getTextStyles: (value) => const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 14),
                          margin: 20,
                          getTitles: (double value) {
                            switch (value.toInt()) {
                              case 0:
                                return 'Jul';
                              case 1:
                                return 'Ago';
                              case 2:
                                return 'Set';
                              case 3:
                                return 'Out';
                              case 4:
                                return 'Nov';
                              case 5:
                                return 'Dez';
                              default:
                                return '';
                            }
                          },
                        ),
                        leftTitles: SideTitles(
                          showTitles: true,
                          getTextStyles: (value) => const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 14),
                          margin: 32,
                          reservedSize: 14,
                          getTitles: (value) {
                            if (value == 0) {
                              return '1K';
                            } else if (value == 10) {
                              return '5K';
                            } else if (value == 19) {
                              return '10K';
                            } else {
                              return '';
                            }
                          },
                        ),
                      ),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      barGroups: showingBarGroups,
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

  BarChartGroupData makeGroupData(int x, double y1, double y2) {
    return BarChartGroupData(barsSpace: 4, x: x, barRods: [
      BarChartRodData(
        y: y1,
        colors: [Colors.pink.shade700],
        width: 7,
      ),
      BarChartRodData(
        y: y2,
        colors: [Styles.primaryColor],
        width: 7,
      ),
    ]);
  }

  _buildGraphMock() {
    final barGroup1 = makeGroupData(0, 16, 15);
    final barGroup2 = makeGroupData(1, 16, 15);
    final barGroup3 = makeGroupData(2, 12, 15);
    final barGroup4 = makeGroupData(3, 9, 16);
    final barGroup5 = makeGroupData(4, 10, 15);
    final barGroup6 = makeGroupData(5, 8, 19);

    final items = [
      barGroup1,
      barGroup2,
      barGroup3,
      barGroup4,
      barGroup5,
      barGroup6,
    ];

    rawBarGroups = items;

    showingBarGroups = rawBarGroups;
  }

  // _buildRevenuesMock() {
  //   var revenueBlock1 = ProfitsBlockDto();
  //   revenueBlock1.blockDate = DateTime(2020, 01);
  //   revenueBlock1.profit = 1050;
  //   revenueBlock1.revenue = 2000;
  //   revenueBlock1.spends = -950;

  //   var revenueBlock2 = ProfitsBlockDto();
  //   revenueBlock2.blockDate = DateTime(2020, 02);
  //   revenueBlock2.profit = 1050;
  //   revenueBlock2.revenue = 2000;
  //   revenueBlock2.spends = -950;

  //   profitList.add(revenueBlock1);
  //   profitList.add(revenueBlock2);
  // }
}
