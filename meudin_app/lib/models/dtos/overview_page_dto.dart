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
}