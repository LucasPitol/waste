import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:waste_app/models/spend_item_dto.dart';
import 'package:waste_app/utils/constants.dart';

class SpendsListComponent extends StatelessWidget {
  final List<SpendItem> spends;

  SpendsListComponent(this.spends);

  Widget createTile(SpendItem item) {

    String amount = Constants.getAmountFormated(item.spent);
    
    return Container(
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(item.reason),
            subtitle: Text(
              (DateFormat.yMd().format(item.spendDate) +
                  '  ' +
                  DateFormat.Hm().format(item.spendDate)),
            ),
            trailing: Text(amount),
          ),
          Divider(
            color: Colors.grey,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomPadding: true,
      body: Column(
        children: <Widget>[
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.only(left: 20.0, right: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: spends.map((item) => createTile(item)).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
