import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:waste_app/models/spend_by_month_dto.dart';
import 'package:waste_app/models/spend_item_dto.dart';
import 'package:waste_app/pages/spends/pie_chart_spends.dart';
import 'package:waste_app/pages/spends/spends_list.dart';
import 'package:waste_app/utils/constants.dart';
import 'package:waste_app/utils/styles.dart';

class SpendsComponent extends StatefulWidget {
  @override
  _SpendsComponentState createState() => _SpendsComponentState();
}

class _SpendsComponentState extends State<SpendsComponent>
    with TickerProviderStateMixin {
  //Mock
  List<SpendByMonthDto> spendsByMonthDtoList = [
    SpendByMonthDto(DateTime(2020, 4), -120.0),
    SpendByMonthDto(DateTime(2020, 3), -110.0),
    SpendByMonthDto(DateTime(2020, 2), -150.0),
    SpendByMonthDto(DateTime(2020, 1), -155.0),
    SpendByMonthDto(DateTime(2019, 12), -170.0),
  ];

  List<SpendItem> spendList = [
    SpendItem('10', 'Salgado', DateTime(2020, 06, 23, 14, 30), -4.50),
    SpendItem('9', 'Passagem', DateTime(2020, 06, 23, 13, 00), -200.00),
    SpendItem('8', 'Estacionamento', DateTime(2020, 06, 23, 08, 30), -6.00),
    SpendItem('7', 'Zefa', DateTime(2020, 06, 22, 21, 30), -50.00),
    SpendItem('6', 'Benkei', DateTime(2020, 06, 21, 20, 00), -50.00),
    SpendItem('5', 'Sushurão', DateTime(2020, 06, 20, 20, 00), -50.00),
    SpendItem('4', 'Credito', DateTime(2020, 06, 20, 9, 00), -20.00),
  ];

  bool headerExpanded = false;
  double appbarHeight = 80.0;
  double menuHeight = 0.0;

  Animation<double> openAnimation, closeAnimation;
  AnimationController openController, closeController;

  void initState() {
    super.initState();
    openController = AnimationController(
      duration: const Duration(
        milliseconds: 200,
      ),
      vsync: this,
    );
    closeController = AnimationController(
      duration: const Duration(
        milliseconds: 200,
      ),
      vsync: this,
    );
    openAnimation = Tween(begin: 0.0, end: 1.0).animate(openController)
      ..addListener(() {
        setState(() {
          menuHeight = openAnimation.value;
        });
      });
    closeAnimation = Tween(begin: 1.0, end: 0.0).animate(closeController)
      ..addListener(
        () {
          setState(() {
            menuHeight = closeAnimation.value;
          });
        },
      );
  }

  _handleHeaderPress() {
    setState(() {
      openController.reset();
      closeController.reset();
      headerExpanded = !headerExpanded;
      headerExpanded ? openController.forward() : closeController.forward();
    });
  }

  @override
  void dispose() {
    openController.dispose();
    closeController.dispose();
    super.dispose();
  }

  Widget createTile(SpendByMonthDto item) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.only(left: 40, top: 10),
                  child: Text(
                    DateFormat("y").format(item.date),
                    style: Styles.datehAndSpendStyle,
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(top: 10),
                  child: Text(
                    DateFormat("MMMM").format(item.date),
                    style: Styles.datehAndSpendStyle,
                  ),
                ),
                Container(
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(right: 40, top: 10),
                  child: Text(
                    Constants.getAmountFormated(item.spent),
                    style: Styles.datehAndSpendStyle,
                  ),
                ),
              ],
            ),
            Divider(
              color: Colors.deepPurple.shade700,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            GestureDetector(
              onTap: _handleHeaderPress,
              child: Container(
                color: Colors.deepPurple,
                height: menuHeight,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      width: double.infinity,
                      height: 10.0,
                    ),
                    Stack(
                      children: <Widget>[
                        Container(
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.only(left: 40, top: 10),
                          child: Text(
                            'Junho',
                            style: Styles.datehAndSpendStyle,
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          margin: EdgeInsets.only(right: 40, top: 10),
                          child: Text(
                            '-130,00',
                            style: Styles.datehAndSpendStyle,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Expanded(
                      child: Container(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.only(left: 20.0, right: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: spendsByMonthDtoList
                                  .map((item) => createTile(item))
                                  .toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _handleHeaderPress,
                      child: Container(
                        alignment: Alignment.bottomCenter,
                        margin: EdgeInsets.only(bottom: 30),
                        child: Icon(
                          Icons.arrow_drop_up,
                          color: Colors.deepPurple.shade100,
                          size: 60,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  margin: EdgeInsets.only(
                      top: menuHeight * (constraints.maxHeight - 60) + 60),
                  color: Colors.transparent,
                  child: Material(
                    elevation: 16.0,
                    child: Center(
                      child: Column(
                        children: <Widget>[
                          GestureDetector(
                            child: PieChartSpendsComponent(),
                          ),
                          Flexible(
                            child: Container(
                              alignment: Alignment.topCenter,
                              margin: EdgeInsets.only(
                                  top: 20, bottom: 40, left: 20, right: 20),
                              decoration: Styles.loginBox,
                              child: SpendsListComponent(spendList),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
