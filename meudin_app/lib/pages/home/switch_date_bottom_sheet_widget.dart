import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meudin_app/utils/constants.dart';
import 'package:meudin_app/utils/styles.dart';

class SwitchDateBottomSheetWidget extends StatefulWidget {
  final DateTime startDate;

  SwitchDateBottomSheetWidget({required this.startDate});

  @override
  _SwitchDateBottomSheetWidgetState createState() =>
      _SwitchDateBottomSheetWidgetState(startDate);
}

class _SwitchDateBottomSheetWidgetState
    extends State<SwitchDateBottomSheetWidget> {
  final DateTime startDate;
  late Map<int, String> months;
  late List<int> years;
  late String dropdownMonthValue;
  late String dropdownYearValue;

  _SwitchDateBottomSheetWidgetState(this.startDate) {
    months = Constants.monthDict;
    years = Constants.years;
    dropdownMonthValue = startDate.month.toString();
    dropdownYearValue = startDate.year.toString();
  }

  _switchMonth(String newValue) {
    setState(() {
      dropdownMonthValue = newValue;
    });
  }

  _switchYear(String newValue) {
    setState(() {
      dropdownYearValue = newValue;
    });
  }

  _filter() {
    int year = int.parse(dropdownYearValue);
    int month = int.parse(dropdownMonthValue);

    DateTime newDate = DateTime(year, month, 1);

    Navigator.pop(context, newDate);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              DropdownButton<String>(
                dropdownColor: Styles.cardColor,
                value: dropdownMonthValue,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey,
                ),
                iconSize: 24,
                elevation: 16,
                style: GoogleFonts.montserrat(
                  textStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Styles.mainTextColor,
                    fontSize: 14,
                  ),
                ),
                underline: Container(
                  height: 1,
                  color: Styles.cardColor,
                ),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    _switchMonth(newValue);
                  }
                },
                items: months.entries.map((e) {
                  return DropdownMenuItem<String>(
                    value: e.key.toString(),
                    child: Text(e.value),
                  );
                }).toList(),
              ),
              DropdownButton<String>(
                dropdownColor: Styles.cardColor,
                value: dropdownYearValue,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey,
                ),
                iconSize: 24,
                elevation: 16,
                style: GoogleFonts.montserrat(
                  textStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Styles.mainTextColor,
                    fontSize: 14,
                  ),
                ),
                underline: Container(
                  height: 1,
                  color: Styles.cardColor,
                ),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    _switchYear(newValue);
                  }
                },
                items: years.map<DropdownMenuItem<String>>((e) {
                  return DropdownMenuItem<String>(
                    value: e.toString(),
                    child: Text(e.toString()),
                  );
                }).toList(),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 20, top: 20),
            child: TextButton(
              onPressed: () {
                _filter();
              },
              child: Text(
                'Filtrar',
                style: TextStyle(
                  fontSize: 14.0,
                  color: Styles.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
