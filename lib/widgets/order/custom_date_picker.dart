import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

class CustomDateRangePicker extends StatefulWidget {
  final DateTimeRange? initialDateRange;
  final Function(DateTimeRange) onDateRangeSelected;

  const CustomDateRangePicker({
    super.key,
    this.initialDateRange,
    required this.onDateRangeSelected,
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
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Buscar por fechas:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        TextButton(
          onPressed: () async {
            final List<DateTime>? dateTimeList = await showOmniDateTimeRangePicker(
              context: context,
              startInitialDate: DateTime.now(),
              startFirstDate: DateTime(2000),
              startLastDate: DateTime.now().add(const Duration(days: 3652)),
              endInitialDate: DateTime.now(),
              endFirstDate: DateTime(2000),
              endLastDate: DateTime.now().add(const Duration(days: 3652)),
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
                widget.onDateRangeSelected(newDateRange);
              });
            }
          },
          child: Text(
            selectedDateRange == null
                ? "Seleccionar rango de fechas"
                : "${formatter.format(selectedDateRange!.start)} - ${formatter.format(selectedDateRange!.end)}",
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ],
    );
  }
}