import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meudin_app/models/spending_category.dart';
import 'package:meudin_app/utils/constants.dart';
import 'package:meudin_app/utils/styles.dart';

class CategoryBottomSheetWidget extends StatefulWidget {
  final List<SpendingCategory> spendingCategoryList;
  final String previousCategorySelectedValue;

  CategoryBottomSheetWidget(
      this.spendingCategoryList, this.previousCategorySelectedValue);

  @override
  _CategoryBottomSheetWidgetState createState() =>
      _CategoryBottomSheetWidgetState(
          spendingCategoryList, previousCategorySelectedValue);
}

class _CategoryBottomSheetWidgetState extends State<CategoryBottomSheetWidget> {
  final List<SpendingCategory> spendingCategoryList;
  late String previousCategorySelectedValue;

  _CategoryBottomSheetWidgetState(
      this.spendingCategoryList, this.previousCategorySelectedValue);

  void _selectCategory(String value) {
    Navigator.pop(context, value);
  }

  Widget createTile(SpendingCategory item) {
    bool isCategorySelected = item.value == previousCategorySelectedValue;

    return InkWell(
      onTap: () {
        String itemValue = item.value;
        setState(() {
          previousCategorySelectedValue = itemValue;
        });
        _selectCategory(itemValue);
      },
      child: Container(
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        decoration: BoxDecoration(
          // borderRadius: Styles.defaultBorderRadius,
          color: isCategorySelected ? Styles.primaryColor : Styles.cardColor,
        ),
        child: Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(left: 20),
              alignment: Alignment.centerLeft,
              child: FaIcon(
                Constants.getCategoryIcon(item.value),
                color:
                    isCategorySelected ? Styles.cardColor : Styles.primaryColor,
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: Text(
                item.name,
                style: TextStyle(
                  fontSize: 16,
                  color: isCategorySelected
                      ? Styles.cardColor
                      : Styles.mainTextColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Styles.cardColor,
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
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: spendingCategoryList
                      .map((item) => createTile(item))
                      .toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
