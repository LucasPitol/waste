import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meudin_app/models/dtos/overview_page_dto.dart';
import 'package:meudin_app/pages/shared/info_bottom_sheet_widget.dart';
import 'package:meudin_app/pages/shared/loading_widget.dart';
import 'package:meudin_app/services/transaction_service.dart';
import 'package:meudin_app/services/user_service.dart';
import 'package:meudin_app/utils/styles.dart';
import 'package:meudin_app/utils/utils.dart';
import 'package:pie_chart/pie_chart.dart';

import 'calendar_range_component.dart';
import 'spending_category_list_bottom_sheet_widget.dart';

class OverviewComponent extends StatefulWidget {
  OverviewComponent({required Key key}) : super(key: key);

  @override
  OverviewComponentState createState() => OverviewComponentState();
}

class OverviewComponentState extends State<OverviewComponent> {
  bool _loading = false;
  bool _isShowingCalendar = false;
  late OverviewPageDto _overviewPageDto;
  late TransactionService _transactionService;
  late DateTime startDate;
  late DateTime endDate;

  OverviewComponentState() {
    _overviewPageDto = OverviewPageDto();
    _transactionService = TransactionService();
  }

  @override
  void initState() {
    super.initState();
    _setUpDate();
    updatePageData();
  }

  _setUpDate() {
    DateTime now = DateTime.now();

    startDate = DateTime(now.year, 1, 1);
    endDate = DateTime(now.year, now.month, now.day, 23, 59);
  }

  updatePageData() async {
    setState(() {
      _loading = true;
    });

    String walletId = UserService.currentUser!.currentWalletId;

    _transactionService
        .getOverviewPageDto(walletId, startDate, endDate)
        .then((res) {
      if (res.success) {
        _overviewPageDto = res.data;
      } else {
        String title = 'Ops...';
        String message = res.errorMsg;

        _openInfoBottomSheet(title, message);
      }

      setState(() {
        _loading = false;
      });
    });
  }

  void _openInfoBottomSheet(String title, String message) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Styles.cardColor,
        builder: (builder) {
          return InfoBottomSheetWidget(title: title, message: message);
        });
  }

  Widget _buildAppBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Visão geral',
            style: Styles.montTextTitle,
          ),
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
        ],
      ),
    );
  }

  Widget _buildHeaderContent() {
    return _loading
        ? Container()
        : Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: SizedBox(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      // alignment: Alignment.topRight,
                      decoration: Styles.cardDecoration,
                      width: 270,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 10),
                            child: Text(
                              Utils.formatDateDDMMYY(startDate),
                              style: Styles.montText,
                            ),
                          ),
                          Text(
                            ' - ',
                            style: Styles.montTextGrey,
                          ),
                          Text(
                            Utils.formatDateDDMMYY(endDate),
                            style: Styles.montText,
                          ),
                          IconButton(
                            icon: FaIcon(
                              FontAwesomeIcons.calendar,
                              color: Styles.primaryColor,
                              size: 18,
                            ),
                            onPressed: () {
                              showCalendar();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Balanço',
                          style: Styles.montText,
                        ),
                        Text(
                          Utils.getAmountFormated(_overviewPageDto.balance),
                          style: TextStyle(
                            color: _overviewPageDto.balance >= 0
                                ? Styles.mainTextColor
                                : Colors.red,
                            fontWeight: FontWeight.w500,
                            fontSize: 21,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Entrada',
                          style: Styles.montSubText,
                        ),
                        Text(
                          '+' +
                              Utils.getAmountFormated(_overviewPageDto.income),
                          style: Styles.montSubText,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Saída',
                          style: Styles.montSubText,
                        ),
                        Text(
                          Utils.getAmountFormated(_overviewPageDto.spends),
                          style: Styles.montSubText,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  showCalendar() {
    setState(() {
      _isShowingCalendar = !_isShowingCalendar;
    });
  }

  selectDateRange(List<DateTime>? dates) async {
    showCalendar();

    if (dates != null && dates.isNotEmpty) {
      startDate = dates[0];
      endDate = dates[1];

      updatePageData();
    }
  }

  _showSpendingCategoryListBottomSheet() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Styles.cardColor,
        builder: (builder) {
          return SpendingCategoryListSheetWidget(
              spendsByCategoryMap: _overviewPageDto.spendsByCategoryMap);
        });
  }

  Widget _buildExpensesContent() {
    return _loading
        ? Container()
        : SizedBox(
            child: Column(
              children: [
                Container(
                  alignment: Alignment.topLeft,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Saídas',
                        style: Styles.montTextTitle,
                      ),
                      IconButton(
                        icon: FaIcon(
                          FontAwesomeIcons.list,
                          color: Styles.primaryColor,
                          size: 18,
                        ),
                        onPressed: () {
                          _showSpendingCategoryListBottomSheet();
                        },
                      ),
                    ],
                  ),
                ),
                _overviewPageDto.pieChartDataMap.isNotEmpty
                    ? Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        child: PieChart(
                          dataMap: _overviewPageDto.pieChartDataMap,
                          animationDuration: const Duration(milliseconds: 800),
                          chartLegendSpacing: 32,
                          chartRadius: MediaQuery.of(context).size.width / 3.2,
                          colorList: Styles.pieChartColorList,
                          initialAngleInDegree: 0,
                          chartType: ChartType.disc,
                          ringStrokeWidth: 32,
                          // centerText: "Categorias",
                          legendOptions: LegendOptions(
                            showLegendsInRow: false,
                            legendPosition: LegendPosition.right,
                            showLegends: true,
                            legendShape: BoxShape.circle,
                            legendTextStyle: Styles.montSubText,
                          ),
                          chartValuesOptions: const ChartValuesOptions(
                            showChartValueBackground: true,
                            showChartValues: true,
                            showChartValuesInPercentage: true,
                            showChartValuesOutside: false,
                            decimalPlaces: 1,
                          ),
                          // gradientList: ---To add gradient colors---
                          // emptyColorGradient: ---Empty Color gradient---
                        ),
                      )
                    : Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        alignment: Alignment.topCenter,
                        child: Text(
                          'Sem informações de gastos',
                          style: Styles.montTextGrey,
                        ),
                      ),
              ],
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              _buildAppBar(),
              _buildHeaderContent(),
              _buildExpensesContent(),
            ],
          ),
        ),
        _isShowingCalendar
            ? CalendarRangeComponent(
                previousStartDate: startDate,
                previousEndDate: endDate,
                functionHandler: selectDateRange,
                demissCalendar: showCalendar,
              )
            : Container(),
        _loading ? Center(child: LoadingWidget()) : Container(),
      ],
    );
  }
}
