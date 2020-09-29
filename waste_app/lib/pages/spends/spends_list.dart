import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:waste_app/models/dtos/spend_item_dto.dart';
import 'package:waste_app/pages/edit_spend/edit_spend_component.dart';
import 'package:waste_app/services/auth_service.dart';
import 'package:waste_app/utils/constants.dart';
import 'package:waste_app/utils/styles.dart';

class SpendsListComponent extends StatefulWidget {
  List<SpendItem> spends;
  Function updateData;
  SpendsListComponent(this.spends, this.updateData);
  @override
  _SpendsListComponentState createState() =>
      _SpendsListComponentState(spends, updateData);
}

class _SpendsListComponentState extends State<SpendsListComponent> {
  String localeLanguage =
      AuthService.currentUser.language == Constants.languages[0]
          ? Constants.ptLanguage
          : Constants.enLanguage;
  final List<SpendItem> spends;
  Function updateData;

  _SpendsListComponentState(this.spends, this.updateData);

  void _goToEditWaste(SpendItem spendId) async {
    var refresh = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => EditSpendComponent(spendId)));

    if (refresh != null && refresh) {
      this.updateData();
    }
  }

  Widget createTile(SpendItem item) {
    String amount = Constants.getAmountFormated(item.spent);

    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 5),
      decoration: Styles.spendCard,
      child: Material(
        color: Styles.mainBackgroundColor,
        borderRadius: Styles.defaultBorderRadius,
        child: InkWell(
          borderRadius: Styles.defaultBorderRadius,
          splashColor: Colors.deepPurple.shade100,
          onLongPress: () {
            _goToEditWaste(item);
          },
          child: ListTile(
            title: Text(
              item.reason,
              style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey.shade100),
            ),
            subtitle: Text(
              (DateFormat.E(localeLanguage).format(item.spendDate) +
                  ', ' +
                  DateFormat.d().format(item.spendDate) +
                  '  ' +
                  DateFormat.Hm().format(item.spendDate)),
              style: TextStyle(fontWeight: FontWeight.w400, color: Colors.grey),
            ),
            trailing: Text(
              '-' + amount,
              style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey.shade100),
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
                    child: Container(
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
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
    );
  }
}
