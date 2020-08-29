import 'package:flutter/material.dart';
import 'package:waste_app/models/spending_category.dart';
import 'package:waste_app/services/auth_service.dart';
import 'package:waste_app/utils/constants.dart';
import 'package:waste_app/utils/styles.dart';

class CategoryBottomSheetComponent extends StatefulWidget {
  List<SpendingCategory> spendingCategoryList;
  String previousCategorySelectedValue;

  CategoryBottomSheetComponent(
      this.spendingCategoryList, this.previousCategorySelectedValue);

  @override
  _CategoryBottomSheetComponentState createState() =>
      _CategoryBottomSheetComponentState(
          spendingCategoryList, previousCategorySelectedValue);
}

class _CategoryBottomSheetComponentState
    extends State<CategoryBottomSheetComponent> {
  List<SpendingCategory> spendingCategoryList;
  String previousCategorySelectedValue;
  bool isPtLanguage =
      AuthService.currentUser.language == Constants.languages[0];

  _CategoryBottomSheetComponentState(
      List<SpendingCategory> spendingCategoryList,
      String previousCategorySelectedValue) {
    this.spendingCategoryList = spendingCategoryList;
    this.previousCategorySelectedValue = previousCategorySelectedValue;
  }

  void _selectCategory(String value) {
    Navigator.pop(context, value);
  }

  Widget createTile(SpendingCategory item) {
    bool isCategorySelected = item.value == previousCategorySelectedValue;

    return GestureDetector(
      onTap: () {
        String itemValue = item.value;
        setState(() {
          previousCategorySelectedValue = itemValue;
        });
        this._selectCategory(itemValue);
      },
      child: Container(
        padding: EdgeInsets.only(top: 10, bottom: 10),
        decoration: BoxDecoration(
          // borderRadius: Styles.defaultBorderRadius,
          color: isCategorySelected
              ? Colors.deepPurple.shade100
              : Styles.mainBackgroundColor,
        ),
        child: Stack(
          children: [
            Container(
              margin: EdgeInsets.only(left: 20),
              alignment: Alignment.centerLeft,
              child: Icon(
                Icons.local_bar,
                color: Colors.deepPurple,
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: Text(
                isPtLanguage ? item.displayNamePt : item.displayNameEn,
                style: TextStyle(fontSize: 16),
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
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 10),
            child: Icon(
              Icons.maximize,
              color: Colors.grey.shade300,
              size: 50,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: this
                      .spendingCategoryList
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
