class OverviewPageDto {
  late double balance;
  late double income;
  late double spends;
  late Map<String, double> spendsByCategoryMap;
  late Map<String, double> pieChartDataMap;

  OverviewPageDto() {
    balance = 0;
    income = 0;
    spends = 0;
    spendsByCategoryMap = <String, double>{};
    pieChartDataMap = <String, double>{};
  }

  OverviewPageDto.fromJson(Map<String, dynamic> overviewPageDtoMap) {
    print(overviewPageDtoMap);
    this.balance = (overviewPageDtoMap['balance']).toDouble();
    this.income = (overviewPageDtoMap['income']).toDouble();
    this.spends = (overviewPageDtoMap['spends']).toDouble();

    this.spendsByCategoryMap = Map<String, double>();
    this.pieChartDataMap = Map<String, double>();

    List<dynamic> spendByCategoryDynamicList =
        (overviewPageDtoMap['spendsByCategory']);

    spendByCategoryDynamicList.forEach((element) {
      spendsByCategoryMap.putIfAbsent(
          element['a'], () => double.parse(element['b'].toString()));
    });

    List<dynamic> pieChartDataDynamicList =
        (overviewPageDtoMap['pieChartData']);

    pieChartDataDynamicList.forEach((element) {
      pieChartDataMap.putIfAbsent(
          element['a'], () => double.parse(element['b'].toString()));
    });
  }
}
