import 'package:waste_app/pages/shared/info_bottom_sheet_component.dart';
import 'package:waste_app/services/transactions_service.dart';
import 'package:waste_app/models/dtos/profits_block_dto.dart';
import 'package:waste_app/models/filter-option-chip.dart';
import 'package:waste_app/services/auth_service.dart';
import 'package:waste_app/utils/constants.dart';
import 'package:waste_app/models/user_dto.dart';
import 'package:waste_app/utils/layout.dart';
import 'package:waste_app/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ProfitsComponent extends StatefulWidget {
  final GlobalKey<OverlayBuilderState> overlayBuilderStatelKey;

  ProfitsComponent({Key key, this.overlayBuilderStatelKey}) : super(key: key);
  @override
  ProfitsComponentState createState() =>
      ProfitsComponentState(overlayBuilderStatelKey);
}

class ProfitsComponentState extends State<ProfitsComponent> {
  final GlobalKey<OverlayBuilderState> overlayBuilderStatelKey;

  String localeLanguage =
      AuthService.currentUser.language == Constants.languages[0]
          ? Constants.ptLanguage
          : Constants.enLanguage;
  UserDto userDto = AuthService.currentUser;
  bool isPtLanguage;

  List<FilterOptionChip> filterOptions = [];
  List<ProfitsBlockDto> profitList = [];
  Map<int, String> graphSubtitleMap;
  int filterSelected;
  bool loading;
  double growth;
  double maxValueGraph;
  double midValueGraph;
  // String minValueGraph;
  double reservedSizeGraph;

  TransactionService transactionService;
  AuthService authService;

  ProfitsComponentState(this.overlayBuilderStatelKey) {
    this.isPtLanguage = userDto.language == Constants.languages[0];
    this.transactionService = TransactionService();
    this.authService = AuthService();
    this.graphSubtitleMap = Map<int, String>();
  }

  void initState() {
    super.initState();
    this.updateAppBar();
    this._buildFilterChipsOptions();
    this.updateData();
    this.authService.userExists(context);
  }

  updateAppBar() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Styles.mainBackgroundColor,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  updateData() {
    setState(() {
      this.loading = true;
    });
  }

  Future<void> _infoBottomSheet() async {
    String info = isPtLanguage
        ? 'O grafico indica a relação entre as receitas e despesas dos respectivos meses, a barra roxa indica o total de receitas, a barra rosa indica as despesas. \n \n'
            'Abaixo do grafico é possivel visualizar a porcentagem de crescimento com base nos lucros, o calculo é feito com a relação entre o mês passado com o retrasado. \n \n'
            'Na listagem abaixo, cada bloco exibe o lucro do mês, a receita e despesa total do mês. \n \n'
        : 'The graph indicates the relationship between income and expenses for the respective months, the purple bar indicates the total income, the pink bar indicates the expenses. \n \n'
            'Below the graph it is possible to see the percentage of growth based on profits, the calculation is made with the relationship between last month and the delay. \n \n'
            'In the list below, each block displays the month\'s profit, the month\'s total income and expense. \n \n';

    this.overlayBuilderStatelKey.currentState.hideOverlay();

    await showModalBottomSheet(
        context: context,
        builder: (builder) {
          return InfoBottomSheetComponent(info);
        });

    this.overlayBuilderStatelKey.currentState.showOverlay();
  }

  _buildFilterChipsOptions() {
    filterSelected = 1;

    var monthlyOpt = FilterOptionChip();
    monthlyOpt.displayTextPt = 'Mensal';
    monthlyOpt.displayTextEn = 'Monthly';
    monthlyOpt.id = 1;
    monthlyOpt.enable = true;

    var yearlyOpt = FilterOptionChip();
    yearlyOpt.displayTextPt = 'Anual';
    yearlyOpt.displayTextEn = 'Yearly';
    yearlyOpt.id = 2;
    yearlyOpt.enable = true;

    filterOptions.add(monthlyOpt);
    filterOptions.add(yearlyOpt);
  }

  Widget createTileForProfits(ProfitsBlockDto item) {
    String profit = item.profit > 0
        ? '+' + item.profit.toStringAsFixed(2)
        : item.profit.toStringAsFixed(2);

    String revenue = item.revenue > 0
        ? '+' + item.revenue.toStringAsFixed(2)
        : item.revenue.toStringAsFixed(2);

    String spend = item.spends.toStringAsFixed(2);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  DateFormat.yMMM(this.localeLanguage).format(item.blockDate),
                  style: Styles.montText,
                ),
                Text(
                  profit,
                  style: Styles.montText,
                ),
              ],
            ),
          ),
          Container(
            child: Column(
              children: [
                ListTile(
                  title: Container(
                    margin: EdgeInsets.only(top: 10),
                    child: ListTile(
                      trailing: Text(
                        revenue,
                        style: Styles.poppinsTextGrey,
                      ),
                      title: Text(
                        isPtLanguage ? 'Receita' : 'Revenue',
                        style: Styles.poppinsTextGrey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            child: Column(
              children: [
                ListTile(
                  title: Container(
                    child: ListTile(
                      trailing: Text(
                        spend,
                        style: Styles.poppinsTextGrey,
                      ),
                      title: Text(
                        isPtLanguage ? 'Despesa' : 'Expense',
                        style: Styles.poppinsTextGrey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget createFilterOptionsChip(FilterOptionChip item) {
    bool isOptionSelected = item.id == this.filterSelected;

    bool enabled = item.enable;

    String displayText = isPtLanguage ? item.displayTextPt : item.displayTextEn;

    Color textColor;

    if (enabled) {
      textColor = isOptionSelected ? Styles.mainBackgroundColor : Colors.grey;
    } else {
      textColor = Colors.grey.shade900;
    }

    TextStyle displayTextStyle = TextStyle(fontSize: 14, color: textColor);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (enabled) {
            this.filterSelected = item.id;
          }
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color:
              isOptionSelected ? Colors.deepPurple : Styles.mainBackgroundColor,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Text(
          displayText,
          style: displayTextStyle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.mainBackgroundColor,
      resizeToAvoidBottomInset: true,
      body: Container(),
    );
  }

  double roundNumber(double number) {
    double rest = number % 50;

    if (rest != 0) {
      double missing = (50 - rest);
      number = (number + missing);
    }

    return number;
  }

  String formatAmount(double value) {
    return NumberFormat.compact().format(value);
  }
}
