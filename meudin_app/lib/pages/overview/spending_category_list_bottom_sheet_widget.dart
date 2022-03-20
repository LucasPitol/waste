import 'package:flutter/material.dart';
import 'package:meudin_app/utils/styles.dart';
import 'package:meudin_app/utils/utils.dart';

class SpendingCategoryListSheetWidget extends StatefulWidget {
  final Map<String, double> spendsByCategoryMap;

  SpendingCategoryListSheetWidget({required this.spendsByCategoryMap});

  @override
  _SpendingCategoryListSheetWidgetState createState() =>
      _SpendingCategoryListSheetWidgetState(spendsByCategoryMap);
}

class _SpendingCategoryListSheetWidgetState
    extends State<SpendingCategoryListSheetWidget> {
  final Map<String, double> spendsByCategoryMap;
  late double _totalSpend;

  _SpendingCategoryListSheetWidgetState(this.spendsByCategoryMap) {
    _totalSpend = 0.0;
  }

  @override
  void initState() {
    super.initState();
    _calculateData();
  }

  _calculateData() {
    spendsByCategoryMap.forEach((key, value) {
      _totalSpend = _totalSpend + value;
    });
  }

  Widget _buildTile(MapEntry<String, double> item) {
    double amount = item.value;
    String amountStr = Utils.getAmountFormated(amount);

    String percentageTemp = Utils.getPercentageStr(amount, _totalSpend);
    String percentage = ' ($percentageTemp)';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: TextSpan(
              style: Styles.montText,
              children: [
                TextSpan(text: item.key, style: Styles.montText),
                TextSpan(text: percentage, style: Styles.montSubText),
              ],
            ),
          ),
          Text(
            amountStr,
            style: Styles.montText,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // height: 240,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10),
            child: Icon(
              Icons.maximize,
              color: Styles.darkModeEnabled()
                  ? Colors.grey.shade800
                  : Colors.grey.shade300,
              size: 50,
            ),
          ),
          spendsByCategoryMap.isNotEmpty
              ? Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: spendsByCategoryMap.entries
                          .map((e) => _buildTile(e))
                          .toList(),
                    ),
                  ),
                )
              : Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
}
