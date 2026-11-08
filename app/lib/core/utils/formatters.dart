import 'package:intl/intl.dart';

/// `3200` → `3,200` in the given locale.
String formatNumber(num value, String locale) =>
    NumberFormat.decimalPattern(locale).format(value);
