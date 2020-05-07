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
  SpendsComponent({Key key}) : super(key: key);
  @override
  SpendsComponentState createState() => SpendsComponentState();
}

class SpendsComponentState extends State<SpendsComponent>
    with TickerProviderStateMixin {
  List<SpendByMonthDto> spendsByMonthDtoList = [];

  List<SpendItem> spendList = [];

  double totalWaste = 0.0;

  DateTime dateSelected = DateTime.now();

  bool listLoading = true;
  bool spendsByMonthLoading = true;
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
        .addPostFrameCallback((_) => this._getCurrentSpends());
  }

  Future<void> _getSpendsByMonthDtoList() async {
    setState(() {
      this.spendsByMonthLoading = true;
      this.spendsByMonthDtoList = [];
    });

    this.spendsByMonthDtoList =
        await this.spendsService.getSpendsByMonthDtoList();

    setState(() {
      this.spendsByMonthLoading = false;
    });
  }

  _getCurrentSpends() {
    var now = DateTime.now();
    _getSpends(now);
  }

  void calculateTotalWaste() {
    double total = 0.0;

    spendList.forEach((item) {
      total = total + item.spent;
    });

    setState(() {
      this.totalWaste = total;
    });
  }

  Future<void> _getSpends(DateTime date) async {
    setState(() {
      this.listLoading = true;
      this.spendList = [];
    });

    this.spendList = await this.spendsService.getSpendsByMonth(date);

    if (spendList.isNotEmpty) {
      this.calculateTotalWaste();
      this.dateSelected = this.spendList.first.spendDate;
    }

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

    if (headerExpanded && this.spendsByMonthDtoList.isEmpty) {
      _getSpendsByMonthDtoList();
    }
  }

  void refreshData() {
    this.spendsByMonthDtoList = [];
    this._getSpends(dateSelected);

  }

  @override
  void dispose() {
    openController.dispose();
    closeController.dispose();
    super.dispose();
  }

  Widget createTile(SpendByMonthDto item) {
    return GestureDetector(
      onTap: () {
        setState(() {
          this.dateSelected = item.date;
          this.totalWaste = item.spent;
        });
        _handleHeaderPress();
        _getSpends(item.date);
      },
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
                    DateFormat.MMMM(Constants.ptLanguage).format(item.date),
                    style: Styles.dateAndSpendStyle,
                  ),
                ),
                Container(
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(right: 40, top: 10),
                  child: Text(
                    '-' + Constants.getAmountFormated(item.spent),
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
                            DateFormat.MMMM(Constants.ptLanguage)
                                .format(dateSelected),
                            style: Styles.dateAndSpendStyle,
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          margin: EdgeInsets.only(right: 40, top: 10),
                          child: Text(
                            '-' + Constants.getAmountFormated(totalWaste),
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
                        child: spendsByMonthLoading
                            ? Container(
                                width: double.infinity,
                                alignment: Alignment.center,
                                child: Theme(
                                  data: Theme.of(context)
                                      .copyWith(accentColor: Colors.white),
                                  child: new CircularProgressIndicator(),
                                ),
                              )
                            : SingleChildScrollView(
                                child: Padding(
                                  padding:
                                      EdgeInsets.only(left: 20.0, right: 20.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        data: Theme.of(context).copyWith(
                                            accentColor: Colors.deepPurple),
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
