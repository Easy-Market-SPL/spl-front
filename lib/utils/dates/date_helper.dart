import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateHelper {
  static const String mainDateFormat = 'dd/MM/yyyy';
  final DateFormat formatter = DateFormat(mainDateFormat);

  static DateTime? stringIsADate(String query) {
    List<String> dateFormats = [
      mainDateFormat,
      'yyyy-MM-dd',
      'MM/dd/yyyy',
      'dd-MM-yyyy',
    ];

    for (String format in dateFormats) {
      try {
        DateFormat dateFormat = DateFormat(format);
        return dateFormat.parseStrict(query);
      } catch (e) {
        // Continue to the next format
      }
    }

    return null;
  }

  static bool isDateMatchingQuery(DateTime date, String query) {
    final dateParsed = stringIsADate(query);
    if (dateParsed != null) {
      return DateUtils.isSameDay(date, dateParsed);
    } else {
      return false;
    }
  }

  static String formatDate(DateTime date, {String format = mainDateFormat}) {
    try{
      final DateFormat formatter = DateFormat(format);
      return formatter.format(date);
    } catch (e) {
      return '';
    }
  }

  static bool dateIsBetween(DateTime date, DateTimeRange dateRange) {
    return date.isAfter(dateRange.start) && date.isBefore(dateRange.end);
  }

  static bool dateIsBetweenAndSameDay(DateTime date, DateTimeRange dateRange) {
    return (date.isAfter(dateRange.start) || DateUtils.isSameDay(date, dateRange.start)) &&
      (date.isBefore(dateRange.end) || DateUtils.isSameDay(date, dateRange.end));
  }
}