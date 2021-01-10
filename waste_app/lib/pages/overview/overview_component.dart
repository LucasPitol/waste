import 'package:waste_app/services/transactions_service.dart';
import 'package:waste_app/models/dtos/overview_page_dto.dart';
import 'package:waste_app/pages/spends/pie_chart_spends.dart';
import 'package:waste_app/pages/shared/loading_block.dart';
import 'package:waste_app/services/auth_service.dart';
import 'package:waste_app/utils/constants.dart';
import 'package:waste_app/models/user_dto.dart';
import 'package:waste_app/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OverviewComponent extends StatefulWidget {
  OverviewComponent({Key key}) : super(key: key);
  @override
  OverviewComponentState createState() => OverviewComponentState();
}

class OverviewComponentState extends State<OverviewComponent> {
  AuthService authService;
  UserDto userDto = AuthService.currentUser;
  bool loading = true;
  bool isPtLanguage;
  OverviewPageDto overviewPageDto;
  TransactionService transactionService;

  OverviewComponentState() {
    this.isPtLanguage = userDto.language == Constants.languages[0];
    this.overviewPageDto = OverviewPageDto();
    this.authService = AuthService();
    this.transactionService = TransactionService();
  }

  void initState() {
    super.initState();
    this.updateAppBar();
    this.updateData();
    this.authService.userExists(context);
  }

  updateData() {
    setState(() {
      this.loading = true;
    });

    //mock
    DateTime startDate = DateTime(2020, 01, 01);
    DateTime endDate = DateTime(2020, 12, 31);

    this
        .transactionService
        .getOverviewPageData(startDate, endDate)
        .then((value) {
      this.overviewPageDto = value;

      setState(() {
        this.loading = false;
      });
    });
  }

  _infoBottomSheet() {
    print('info');
  }

  _openCalendar() {
    print('calendar');
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
          child: loading
              ? LoadingBlock(loading)
              : Container(
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
                                isPtLanguage ? 'Visão geral' : 'Overview',
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
                                      this._infoBottomSheet();
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            alignment: Alignment.topRight,
                            margin: EdgeInsets.symmetric(vertical: 20),
                            decoration: Styles.contentBox2,
                            width: 250,
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 15),
                              // alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '01/01/2020 - ',
                                    style: Styles.poppinsTextLight,
                                  ),
                                  Text(
                                    '21/12/2020',
                                    style: Styles.poppinsTextLight,
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 10),
                                    child: InkWell(
                                      borderRadius: Styles.circularBorderRadius,
                                      onTap: () {
                                        this._openCalendar();
                                      },
                                      child: Icon(
                                        Icons.calendar_today,
                                        color: Styles.primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isPtLanguage ? 'Saldo' : 'balance',
                              style: TextStyle(
                                color: Colors.grey.shade100,
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              Constants.getAmountFormated(
                                  overviewPageDto.balance),
                              style: TextStyle(
                                color: overviewPageDto.balance >= 0
                                    ? Styles.primaryColor
                                    : Colors.red,
                                fontWeight: FontWeight.w500,
                                fontSize: 21,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isPtLanguage ? 'Entradas' : 'Revenue',
                              style: Styles.poppinsTextGrey,
                            ),
                            Text(
                              '+ ' +
                                  Constants.getAmountFormated(
                                      overviewPageDto.income),
                              style: Styles.poppinsTextGrey,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isPtLanguage ? 'Saídas' : 'Spends',
                              style: Styles.poppinsTextGrey,
                            ),
                            Text(
                              Constants.getAmountFormated(
                                  overviewPageDto.spends),
                              style: Styles.poppinsTextGrey,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        child: PieChartSpendsComponent(),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
