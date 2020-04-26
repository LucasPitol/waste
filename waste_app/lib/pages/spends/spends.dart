import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:waste_app/models/spend_by_month_dto.dart';
import 'package:waste_app/models/spend_item_dto.dart';
import 'package:waste_app/pages/spends/spends_list.dart';
import 'package:waste_app/services/spends-service.dart';
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

  List<SpendItem> spendList = [];
  //   SpendItem('10', 'Salgado', DateTime(2020, 06, 23, 14, 30), -4.50),
  //   SpendItem('9', 'Passagem', DateTime(2020, 06, 23, 13, 00), -200.00),
  //   SpendItem('8', 'Estacionamento', DateTime(2020, 06, 23, 08, 30), -6.00),
  //   SpendItem('7', 'Zefa', DateTime(2020, 06, 22, 21, 30), -50.00),
  //   SpendItem('6', 'Benkei', DateTime(2020, 06, 21, 20, 00), -50.00),
  //   SpendItem('5', 'Sushurão', DateTime(2020, 06, 20, 20, 00), -50.00),
  //   SpendItem('4', 'Credito', DateTime(2020, 06, 20, 9, 00), -20.00),
  //   SpendItem('4', 'Café', DateTime(2020, 06, 20, 8, 00), -10.00),
  // ];

  bool listLoading = true;
  bool headerExpanded = false;
  double appbarHeight = 80.0;
  double menuHeight = 0.0;

  SpendsService spendsService = SpendsService();

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
      SchedulerBinding.instance
        .addPostFrameCallback((_) => this._getSpends());
  }

  Future<void> _getSpends() async {
    setState(() {
      this.listLoading = true;
      this.spendList = [];
    });

    var now = DateTime.now();

    this.spendList = await this.spendsService.getSpendsByMonth(now);

    setState(() {
      this.listLoading = false;
    });
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
                    style: Styles.dateAndSpendStyle,
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(top: 10),
                  child: Text(
                    DateFormat("MMMM").format(item.date),
                    style: Styles.dateAndSpendStyle,
                  ),
                ),
                Container(
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(right: 40, top: 10),
                  child: Text(
                    Constants.getAmountFormated(item.spent),
                    style: Styles.dateAndSpendStyle,
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
                            style: Styles.dateAndSpendStyle,
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          margin: EdgeInsets.only(right: 40, top: 10),
                          child: Text(
                            '-130,00',
                            style: Styles.dateAndSpendStyle,
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
                          Flexible(
                            child: Container(
                              alignment: Alignment.topCenter,
                              margin: EdgeInsets.only(left: 20, right: 20),
                              child: listLoading
                                  ? Container(
                                      width: double.infinity,
                                      alignment: Alignment.center,
                                      child: Theme(
                                        data: Theme.of(context)
                                            .copyWith(accentColor: Colors.deepPurple),
                                        child: new CircularProgressIndicator(),
                                      ),
                                    )
                                  : SpendsListComponent(spendList),
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
