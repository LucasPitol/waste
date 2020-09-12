import 'package:pie_chart/pie_chart.dart';
import 'package:flutter/material.dart';
import 'package:waste_app/utils/constants.dart';

class PieChartProfileComponent extends StatelessWidget {

  Map<String, double> spendsByCategoryMap;

  PieChartProfileComponent(this.spendsByCategoryMap);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      child: PieChart(
        dataMap: spendsByCategoryMap,
        animationDuration: Duration(milliseconds: 400),
        chartLegendSpacing: 32.0,
        chartRadius: MediaQuery.of(context).size.width / 2.6,
        colorList: Constants.chartColorList,
        legendOptions: LegendOptions(
          legendPosition: LegendPosition.right,
          legendShape: BoxShape.circle,
          legendTextStyle: TextStyle(color: Colors.grey.shade900),
          showLegendsInRow: false,
        ),
        chartValuesOptions: ChartValuesOptions(
          chartValueBackgroundColor: Colors.deepPurple.shade50,
          // chartValueStyle: 
          decimalPlaces: 1,
          showChartValues: true,
          showChartValuesInPercentage: true,
          showChartValuesOutside: false,
        ),

        // showLegends: true,
        // showChartValueLabel: true,
        // initialAngle: 0,
        // chartValueStyle: defaultChartValueStyle.copyWith(
        //   color: Colors.blueGrey[900].withOpacity(0.9),
        // ),
        chartType: ChartType.disc,
      ),
    );
  }
}
