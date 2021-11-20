import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meudin_app/utils/styles.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class CalendarRangeComponent extends StatefulWidget {
  final DateTime previousStartDate;
  final DateTime previousEndDate;
  final Function functionHandler;
  final Function demissCalendar;

  CalendarRangeComponent(
      {required this.previousStartDate,
      required this.previousEndDate,
      required this.functionHandler,
      required this.demissCalendar});

  @override
  _CalendarRangeComponentState createState() => _CalendarRangeComponentState(
      previousStartDate, previousEndDate, functionHandler, demissCalendar);
}

class _CalendarRangeComponentState extends State<CalendarRangeComponent> {
  final DateTime previousStartDate;
  final DateTime previousEndDate;
  final Function functionHandler;
  final Function demissCalendar;

  final DateTime now = DateTime.now();
  DateRangePickerController _dateRangePickerController =
      DateRangePickerController();

  late DateTime startDate;
  late DateTime endDate;

  _CalendarRangeComponentState(this.previousStartDate, this.previousEndDate,
      this.functionHandler, this.demissCalendar) {
    startDate = previousStartDate;
    endDate = previousEndDate;
  }

  _goBack() {
    demissCalendar();
  }

  _selectDateRange(Object selectedRange) {
    DateTime? startDateTemp =
        _dateRangePickerController.selectedRange!.startDate;
    DateTime? endDateTemp = _dateRangePickerController.selectedRange!.endDate;

    if (startDateTemp != null && endDateTemp != null) {
      startDate = startDateTemp;
      endDate = endDateTemp;

      List<DateTime> rangeList = [startDate, endDate];

      functionHandler(rangeList);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Styles.cardColor,
      child: Column(
        children: [
          Container(
            alignment: Alignment.topRight,
            margin: const EdgeInsets.only(top: 10, right: 20),
            child: IconButton(
              onPressed: () {
                _goBack();
              },
              icon: FaIcon(
                FontAwesomeIcons.times,
                color: Styles.mainTextColor,
                size: 22,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: SfDateRangePicker(
              view: DateRangePickerView.month,
              backgroundColor: Styles.cardColor,
              controller: _dateRangePickerController,
              confirmText: 'Filtrar',
              initialDisplayDate: startDate,
              cancelText: 'Cancelar',
              allowViewNavigation: true,
              rangeTextStyle: Styles.montText,
              selectionTextStyle: Styles.montText,
              headerStyle: DateRangePickerHeaderStyle(
                textStyle: Styles.montTextTitle,
              ),
              // initialSelectedDates: [this._startDate, this._endDate],
              minDate: DateTime(2018, 01, 01),
              maxDate: DateTime(now.year, now.month, now.day),
              initialSelectedRange: PickerDateRange(startDate, endDate),
              selectionMode: DateRangePickerSelectionMode.range,
              showActionButtons: true,
              onSubmit: _selectDateRange,
              onCancel: _goBack,
            ),
          ),
        ],
      ),
    );
  }
}
