import 'package:intl/intl.dart';

/// تنسيق التواريخ والمبالغ (بالعربية).
///
/// يجب استدعاء `initializeDateFormatting('ar')` قبل أول استخدام (يتم في main).
class Fmt {
  Fmt._();

  static const String currency = 'د.ع';

  static final DateFormat _date = DateFormat('EEEE d MMMM yyyy', 'ar');
  static final DateFormat _time = DateFormat('h:mm a', 'ar');
  static final NumberFormat _number = NumberFormat('#,##0.##', 'ar');

  static String date(DateTime value) => _date.format(value);

  static String time(DateTime value) => _time.format(value);

  static String dateTime(DateTime value) =>
      '${_date.format(value)} - ${_time.format(value)}';

  static String money(double value) => '${_number.format(value)} $currency';

  static String count(int value) => _number.format(value);
}
