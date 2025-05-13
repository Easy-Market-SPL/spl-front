import 'package:intl/intl.dart';

class TimeHelper {
  static String getFormattedTime(DateTime dateTime, {String format = 'HH:mm', bool is24HourFormat = true}) {
    try{
      if (is24HourFormat) {
        return DateFormat(format).format(dateTime);
      } else {
        return DateFormat('h:mm a').format(dateTime);
      }
    } catch (e) {
      return '';
    }
  }
}