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

  OverviewPageDto.fromJson(Map<String, dynamic> transactionMap) {
    print(transactionMap);
    this.balance = (transactionMap['balance']).toDouble();
    this.income = (transactionMap['income']).toDouble();
    this.spends = (transactionMap['spends']).toDouble();
    print(transactionMap['spendsByCategoryMap']);
    this.spendsByCategoryMap =
        Map<String, double>.from(transactionMap['spendsByCategoryMap']);
    this.pieChartDataMap =
        Map<String, double>.from(transactionMap['pieChartDataMap']);
    print(this.spendsByCategoryMap);

  }
}
