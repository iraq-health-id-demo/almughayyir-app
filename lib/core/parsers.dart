/// تحويل نص المبلغ المُدخل إلى رقم.
///
/// يدعم الأرقام العربية الهندية (٠-٩) والفارسية (۰-۹) والفواصل العربية،
/// ويعيد `null` إذا كان النص غير صالح أو سالبًا.
double? parseAmount(String input) {
  const arabicIndic = '٠١٢٣٤٥٦٧٨٩';
  const persian = '۰۱۲۳۴۵۶۷۸۹';

  final buffer = StringBuffer();
  for (final rune in input.trim().runes) {
    final ch = String.fromCharCode(rune);
    final fromArabic = arabicIndic.indexOf(ch);
    final fromPersian = persian.indexOf(ch);
    if (fromArabic >= 0) {
      buffer.write(fromArabic);
    } else if (fromPersian >= 0) {
      buffer.write(fromPersian);
    } else if (ch == '٫') {
      buffer.write('.');
    } else if (ch == ',' || ch == '٬' || ch == ' ') {
      // فواصل الآلاف: تُتجاهل.
    } else {
      buffer.write(ch);
    }
  }

  final value = double.tryParse(buffer.toString());
  if (value == null || value.isNaN || value.isInfinite || value < 0) {
    return null;
  }
  return value;
}
