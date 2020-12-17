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
  ProfitsComponent({Key key}) : super(key: key);
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
  List<BarChartGroupData> showingBarGroups = [];
  Map<int, String> graphSubtitleMap;
  int filterSelected;
  bool loading;
  double growth;
  double maxValueGraph;
  double midValueGraph;
  // String minValueGraph;
  double reservedSizeGraph;

  TransactionService transactionService;
  AuthService authService;

  ProfitsComponentState() {
    this.isPtLanguage = userDto.language == Constants.languages[0];
    this.transactionService = TransactionService();
    this.authService = AuthService();
    this.graphSubtitleMap = Map<int, String>();
  }

  void initState() {
    super.initState();
    this.updateAppBar();
    this._buildFilterChipsOptions();
    this.updateData();
    this.authService.userExists(context);
  }

  updateAppBar() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Styles.mainBackgroundColor,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  updateData() {
    setState(() {
      this.loading = true;
    });

    if (filterSelected == 1) {
      this.transactionService.getProfitsByMonth().then((value) {
        this.profitList = value;

        this.getProfitsGraphData();

        setState(() {
          this.loading = false;
        });
      });
    }
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
    yearlyOpt.enable = true;

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
                                  this.updateData();
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
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        children: filterOptions
                            .map((item) => createFilterOptionsChip(item))
                            .toList(),
                      ),
                    ),
                  ),
                ),
                loading
                    ? Container()
                    : Container(
                        margin: EdgeInsets.symmetric(vertical: 20),
                        child: BarChart(
                          BarChartData(
                            maxY: this.maxValueGraph,
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
                                  var index = value.toInt();

                                  return this.graphSubtitleMap[index];
                                },
                              ),
                              leftTitles: SideTitles(
                                showTitles: true,
                                getTextStyles: (value) => const TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                                margin: 32,
                                reservedSize: this.reservedSizeGraph,
                                getTitles: (value) {
                                  if (value == 0) {
                                    return '';
                                  } else if (value == midValueGraph) {
                                    return formatAmount(midValueGraph);
                                  } else if (value == maxValueGraph) {
                                    return formatAmount(maxValueGraph);
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
                loading
                    ? Container()
                    : Container(
                        alignment: Alignment.topRight,
                        child: Text(
                          growth.toStringAsFixed(1) + '% a.m',
                          style: TextStyle(
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.w600,
                              fontSize: 16),
                        ),
                      ),
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
                    : Container(
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

  getProfitsGraphData() {
    this.showingBarGroups = [];
    this.graphSubtitleMap.clear();

    double maxValue = 0;
    double midValue = 0;
    double minValue = 0;

    int index = 0;
    int itensLength = this.profitList.length;

    var profitsraw = this.profitList;

    var profitsReverse = profitsraw.reversed;

    double profitOfLastMonth = 0;
    double profitOfCurrentMonth = 0;

    profitsReverse.forEach((element) {
      double spendsPositive = (element.spends * -1);
      double revenue = element.revenue;

      // if (index == 0) {
      //   minValue = revenue >= spendsPositive ? spendsPositive : revenue;
      // }

      if (spendsPositive > maxValue) {
        maxValue = spendsPositive;
      }

      if (revenue > maxValue) {
        maxValue = revenue;
      }

      // if (spendsPositive < minValue) {
      //   minValue = spendsPositive;
      // }

      // if (revenue < minValue) {
      //   minValue = revenue;
      // }

      var barGroup = makeGroupData(index, spendsPositive, revenue);

      showingBarGroups.add(barGroup);

      String month =
          DateFormat.MMM(this.localeLanguage).format(element.blockDate);

      this.graphSubtitleMap.putIfAbsent(index, () => month);

      if (index == (itensLength - 3)) {
        profitOfLastMonth = element.profit;
      }

      if (index == itensLength - 2) {
        profitOfCurrentMonth = element.profit;
      }

      index++;
    });

    this.maxValueGraph = roundNumber(maxValue);

    midValue = (maxValue / 2);

    this.midValueGraph = roundNumber(midValue);

    this.reservedSizeGraph = (maxValue * 0.01);

    this.growth = _calculateGrowth(profitOfLastMonth, profitOfCurrentMonth);
  }

  double _calculateGrowth(double lastProfit, currentProfit) {
    double step1 = (currentProfit - lastProfit);

    double growthRaw = (step1 / lastProfit);

    return (growthRaw * 100);
  }

  double roundNumber(double number) {
    double rest = number % 50;

    if (rest != 0) {
      double missing = (50 - rest);
      number = (number + missing);
    }

    return number;
  }

  String formatAmount(double value) {
    return NumberFormat.compact().format(value);
  }
}
