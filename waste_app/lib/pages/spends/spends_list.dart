import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:waste_app/models/spend_item_dto.dart';
import 'package:waste_app/utils/constants.dart';
import 'package:waste_app/utils/styles.dart';

class SpendsListComponent extends StatelessWidget {
  final List<SpendItem> spends;

  SpendsListComponent(this.spends);

  Widget createTile(SpendItem item) {
    String amount = Constants.getAmountFormated(item.spent);

    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 5),
      decoration: Styles.loginBox,
      child: Material(
        borderRadius: Styles.defaultBorderRadius,
        child: InkWell(
          borderRadius: Styles.defaultBorderRadius,
          splashColor: Colors.deepPurple.shade100,
          onLongPress: () {
            print('aa');
          },
          child: ListTile(
            title: Text(
              item.reason,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              (DateFormat.E(Constants.ptLanguage).format(item.spendDate) +
                  ', ' +
                  DateFormat.d().format(item.spendDate) +
                  '  ' +
                  DateFormat.Hm().format(item.spendDate)),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: Text(
              '-' + amount,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomPadding: true,
      body: spends.isNotEmpty
          ? Column(
              children: <Widget>[
                Flexible(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                        padding: EdgeInsets.only(left: 10.0, right: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:
                              spends.map((item) => createTile(item)).toList(),
                        )),
                  ),
                ),
              ],
            )
          : Center(
              child: Text(
                'Nenhum gasto',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
  }
}
