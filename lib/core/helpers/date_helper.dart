import 'package:intl/intl.dart';

class DateHelper {
  static String formatDate(DateTime? date, {String pattern = 'dd/MM/yyyy'}) {
    if (date == null) return '';
    return DateFormat(pattern).format(date);
  }

  static String formatDateTime(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  static String formatMonthYear(DateTime? date) {
    if (date == null) return '';
    return DateFormat('MMMM yyyy', 'es_MX').format(date);
  }

  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59);
  }
}