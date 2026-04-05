import 'package:intl/intl.dart';

class CurrencyHelper {
  static final _mxn = NumberFormat.currency(
    locale: 'es_MX',
    symbol: '\$',
    decimalDigits: 2,
  );

  static String mxn(num value) {
    return _mxn.format(value);
  }

  static String compact(num value) {
    final formatter = NumberFormat.compact(locale: 'es_MX');
    return formatter.format(value);
  }
}