import 'package:flutter/material.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:spl_front/utils/dates/date_helper.dart';
import 'package:spl_front/utils/strings/order_strings.dart';

class CustomDateRangePicker extends StatefulWidget {
  final DateTimeRange? initialDateRange;
  final Function(DateTimeRange) onDateRangeSelected;
  final TextEditingController controller;

  const CustomDateRangePicker({
    super.key,
    this.initialDateRange,
    required this.onDateRangeSelected,
    required this.controller,
  });

  @override
  State<CustomDateRangePicker> createState() => _CustomDateRangePickerState();
}

class _CustomDateRangePickerState extends State<CustomDateRangePicker> {
  DateTimeRange? selectedDateRange;

  @override
  void initState() {
    super.initState();
    selectedDateRange = widget.initialDateRange;
    if (selectedDateRange != null) {
      widget.controller.text = "${DateHelper.formatDate(selectedDateRange!.start)} - ${DateHelper.formatDate(selectedDateRange!.end)}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          OrderStrings.searchByDate,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        TextField(
          controller: widget.controller,
          readOnly: true,
          decoration: InputDecoration(
            hintText: OrderStrings.selectDateRange,
            suffixIcon: Icon(Icons.calendar_today),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
          ),
          onTap: () async {
            final List<DateTime>? dateTimeList = await showOmniDateTimeRangePicker(
              context: context,
              startInitialDate: DateTime.now(),
              startFirstDate: DateTime(2000),
              startLastDate: DateTime.now().add(const Duration(days: 3652)),
              endInitialDate: DateTime.now(),
              endFirstDate: DateTime(2000),
              endLastDate: DateTime.now().add(const Duration(days: 3653)),
              isShowSeconds: false,
              is24HourMode: true,
              minutesInterval: 1,
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              constraints: const BoxConstraints(
                maxWidth: 350,
                maxHeight: 650,
              ),
              type: OmniDateTimePickerType.date,
              isForceEndDateAfterStartDate: true,
              theme: ThemeData(
                colorScheme: ColorScheme.light(primary: Colors.blue),
                buttonTheme: ButtonThemeData(
                  textTheme: ButtonTextTheme.primary,
                ),
              ),
            );
            if (dateTimeList != null) {
              final DateTimeRange newDateRange = DateTimeRange(
                start: dateTimeList[0],
                end: dateTimeList[1],
              );
              setState(() {
                selectedDateRange = newDateRange;
                widget.controller.text = "${DateHelper.formatDate(newDateRange.start)} - ${DateHelper.formatDate(newDateRange.end)}";
                widget.onDateRangeSelected(newDateRange);
              });
            }
          },
        ),
      ],
    );
  }
}