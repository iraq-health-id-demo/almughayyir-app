import 'package:flutter/material.dart';

/// رسالة سريعة أسفل الشاشة.
void showMessage(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}

/// نافذة تأكيد. تعيد `true` عند التأكيد.
Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'تأكيد',
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      final scheme = Theme.of(ctx).colorScheme;
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('تراجع'),
          ),
          FilledButton(
            style: destructive
                ? FilledButton.styleFrom(
                    backgroundColor: scheme.error,
                    foregroundColor: scheme.onError,
                  )
                : null,
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return result ?? false;
}

/// اختيار تاريخ ثم وقت. تعيد `null` إذا ألغى المستخدم.
Future<DateTime?> pickDateTime(BuildContext context, DateTime initial) async {
  final now = DateTime.now();
  final first = DateTime(now.year - 2);
  final last = DateTime(now.year + 5, 12, 31);
  DateTime initialDate = initial;
  if (initialDate.isBefore(first)) initialDate = first;
  if (initialDate.isAfter(last)) initialDate = last;

  final date = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: first,
    lastDate: last,
    helpText: 'اختر التاريخ',
    cancelText: 'إلغاء',
    confirmText: 'موافق',
  );
  if (date == null || !context.mounted) return null;

  final time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(initial),
    helpText: 'اختر الوقت',
    cancelText: 'إلغاء',
    confirmText: 'موافق',
  );
  if (time == null) return null;

  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}
