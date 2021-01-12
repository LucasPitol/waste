import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:waste_app/utils/styles.dart';

class PieChartSpendsComponent extends StatelessWidget {
  Map<String, double> spendsByCategoryMap;

  PieChartSpendsComponent(this.spendsByCategoryMap);

  ///

  List<Color> colorList = [
    Colors.deepPurple[900],
    Colors.deepPurple,
    Colors.deepPurple[300],
    Colors.deepPurple[100],
  ];

  @override
  Widget build(BuildContext context) {
    return (spendsByCategoryMap != null && spendsByCategoryMap.isNotEmpty)
        ? Container(
            // width: double.infinity,
            alignment: Alignment.topCenter,
            margin: EdgeInsets.only(top: 20),
            child: PieChart(
              dataMap: spendsByCategoryMap,
              animationDuration: Duration(milliseconds: 800),
              chartLegendSpacing: 32.0,
              chartRadius: MediaQuery.of(context).size.width / 2.6,
              colorList: colorList,
              chartValuesOptions: ChartValuesOptions(
                showChartValuesInPercentage: true,
                showChartValues: true,
                showChartValuesOutside: false,
                chartValueBackgroundColor: Colors.deepPurple[50],
                decimalPlaces: 1,
                chartValueStyle: defaultChartValueStyle.copyWith(
                  color: Colors.blueGrey[900].withOpacity(0.9),
                ),
              ),
              legendOptions: LegendOptions(
                legendTextStyle: Styles.poppinsTextLight,
                showLegends: true,
              ),
              // showChartValuesInPercentage: true,
              // showChartValues: true,
              // showChartValuesOutside: false,
              // chartValueBackgroundColor: Colors.deepPurple[50],
              // colorList: colorList,
              // showLegends: true,
              // legendPosition: LegendPosition.right,
              // decimalPlaces: 1,
              // showChartValueLabel: true,
              // initialAngle: 0,
              // chartValueStyle: defaultChartValueStyle.copyWith(
              //   color: Colors.blueGrey[900].withOpacity(0.9),
              // ),
              chartType: ChartType.disc,
            ),
          )
        : Container();
  }
}
