import 'package:animations/animations.dart';
import 'package:waste_app/pages/edit_spend/edit_spend_component.dart';
import 'package:waste_app/models/dtos/spend_item_dto.dart';
import 'package:waste_app/services/auth_service.dart';
import 'package:waste_app/utils/constants.dart';
import 'package:waste_app/utils/layout.dart';
import 'package:waste_app/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SpendsListComponent extends StatefulWidget {
  final List<SpendItem> spends;
  final Function updateData;
  final GlobalKey<OverlayBuilderState> overlayBuilderStatelKey;

  SpendsListComponent(
      this.spends, this.updateData, this.overlayBuilderStatelKey);
  @override
  _SpendsListComponentState createState() =>
      _SpendsListComponentState(spends, updateData, overlayBuilderStatelKey);
}

class _SpendsListComponentState extends State<SpendsListComponent> {
  String localeLanguage =
      AuthService.currentUser.language == Constants.languages[0]
          ? Constants.ptLanguage
          : Constants.enLanguage;
  final List<SpendItem> spends;
  final Function updateData;
  final GlobalKey<OverlayBuilderState> overlayBuilderStatelKey;

  _SpendsListComponentState(
      this.spends, this.updateData, this.overlayBuilderStatelKey);

  void _goToEditWaste(SpendItem transactionId) async {
    this.overlayBuilderStatelKey.currentState.hideOverlay();

    var refresh = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditSpendComponent(
                transactionId, this.overlayBuilderStatelKey)));

    this.overlayBuilderStatelKey.currentState.showOverlay();

    if (refresh != null && refresh) {
      this.updateData();
    }
  }

  Widget createTile(SpendItem item) {
    String amount = Constants.getAmountFormated(item.spent);

    return Container(
      child: OpenContainer(
        closedElevation: 2,
        closedColor: Styles.mainBackgroundColor,
        openColor: Styles.mainBackgroundColor,
        closedShape:
            RoundedRectangleBorder(borderRadius: Styles.defaultBorderRadius),
        onClosed: (val) {
          this.overlayBuilderStatelKey.currentState.showOverlay();
          // if (refresh) {
          //   this.updatePageContent();
          //   this.refresh = false;
          // }
        },
        closedBuilder: (context, action) {
          return Container(
            margin: EdgeInsets.only(left: 20, right: 20, bottom: 15),
            decoration: Styles.spendCard,
            child: ListTile(
              title: Text(
                item.reason,
                style: TextStyle(
                    fontWeight: FontWeight.w500, color: Colors.grey.shade100),
              ),
              subtitle: Text(
                (DateFormat.E(localeLanguage).format(item.spendDate) +
                    ', ' +
                    DateFormat.d().format(item.spendDate) +
                    '  ' +
                    DateFormat.Hm().format(item.spendDate)),
                style:
                    TextStyle(fontWeight: FontWeight.w400, color: Colors.grey),
              ),
              trailing: Text(
                amount,
                style: TextStyle(
                    fontWeight: FontWeight.w500, color: Colors.grey.shade100),
              ),
            ),
          );
        },
        openBuilder: (contex, action) {
          // this.overlayBuilderStatelKey.currentState.hideOverlay();
          return EditSpendComponent(item, this.overlayBuilderStatelKey);
        },
      ),
    );

    // return Container(
    //   margin: EdgeInsets.only(left: 20, right: 20, bottom: 10),
    //   decoration: Styles.spendCard,
    //   child: Material(
    //     color: Styles.mainBackgroundColor,
    //     borderRadius: Styles.defaultBorderRadius,
    //     child: InkWell(
    //       borderRadius: Styles.defaultBorderRadius,
    //       splashColor: Colors.deepPurple.shade100,
    //       onLongPress: () {
    //         _goToEditWaste(item);
    //       },
    //       child: ListTile(
    //         title: Text(
    //           item.reason,
    //           style: TextStyle(
    //               fontWeight: FontWeight.w500, color: Colors.grey.shade100),
    //         ),
    //         subtitle: Text(
    //           (DateFormat.E(localeLanguage).format(item.spendDate) +
    //               ', ' +
    //               DateFormat.d().format(item.spendDate) +
    //               '  ' +
    //               DateFormat.Hm().format(item.spendDate)),
    //           style: TextStyle(fontWeight: FontWeight.w400, color: Colors.grey),
    //         ),
    //         trailing: Text(
    //           amount,
    //           style: TextStyle(
    //               fontWeight: FontWeight.w500, color: Colors.grey.shade100),
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return spends.isNotEmpty
        ? Column(
            children: <Widget>[
              Flexible(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  physics: const BouncingScrollPhysics(),
                  child: Container(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: spends.map((item) => createTile(item)).toList(),
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
          );
  }
}
