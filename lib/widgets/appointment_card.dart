import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../models/appointment.dart';
import '../models/enums.dart';

enum AppointmentAction { edit, reschedule, toggleCancel, delete }

/// بطاقة عرض حجز واحد مع قائمة الإجراءات.
class AppointmentCard extends StatelessWidget {
  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.onAction,
  });

  final Appointment appointment;
  final ValueChanged<AppointmentAction> onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final a = appointment;
    final cancelled = a.isCancelled;
    final isPast = !cancelled && a.dateTime.isBefore(DateTime.now());
    final muted = cancelled ? scheme.outline : null;

    return Card(
      margin: EdgeInsets.zero,
      elevation: cancelled ? 0 : 1,
      color: cancelled ? scheme.surfaceContainerHighest.withAlpha(120) : null,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 6, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    a.patientName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: muted,
                          decoration:
                              cancelled ? TextDecoration.lineThrough : null,
                        ),
                  ),
                ),
                if (cancelled)
                  _Tag(label: 'ملغي', color: scheme.error)
                else if (isPast)
                  _Tag(label: 'منتهي', color: scheme.outline),
                const SizedBox(width: 6),
                _Tag(
                  label: a.kind.label,
                  color: a.kind == AppointmentKind.surgery
                      ? Colors.deepOrange
                      : scheme.primary,
                ),
                _Menu(cancelled: cancelled, onAction: onAction),
              ],
            ),
            if (a.title.isNotEmpty) ...[
              const SizedBox(height: 4),
              _InfoRow(
                icon: a.kind.icon,
                text: a.title,
                color: muted,
              ),
            ],
            const SizedBox(height: 4),
            _InfoRow(
              icon: Icons.event_rounded,
              text: Fmt.dateTime(a.dateTime),
              color: muted,
            ),
            const SizedBox(height: 4),
            _InfoRow(
              icon: Icons.payments_outlined,
              text: Fmt.money(a.amount),
              color: muted,
              bold: true,
            ),
            if (a.notes.isNotEmpty) ...[
              const SizedBox(height: 4),
              _InfoRow(
                icon: Icons.sticky_note_2_outlined,
                text: a.notes,
                color: muted,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Menu extends StatelessWidget {
  const _Menu({required this.cancelled, required this.onAction});

  final bool cancelled;
  final ValueChanged<AppointmentAction> onAction;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<AppointmentAction>(
      tooltip: 'خيارات',
      onSelected: onAction,
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: AppointmentAction.edit,
          child: ListTile(
            leading: Icon(Icons.edit_outlined),
            title: Text('تعديل'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        if (!cancelled)
          const PopupMenuItem(
            value: AppointmentAction.reschedule,
            child: ListTile(
              leading: Icon(Icons.update_rounded),
              title: Text('تقديم / تأجيل الموعد'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        PopupMenuItem(
          value: AppointmentAction.toggleCancel,
          child: ListTile(
            leading: Icon(
              cancelled ? Icons.restore_rounded : Icons.event_busy_rounded,
            ),
            title: Text(cancelled ? 'استعادة الحجز' : 'إلغاء الحجز'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: AppointmentAction.delete,
          child: ListTile(
            leading: Icon(Icons.delete_outline),
            title: Text('حذف نهائي'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.text,
    this.color,
    this.bold = false,
  });

  final IconData icon;
  final String text;
  final Color? color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final effective = color ?? Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: effective),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: effective,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
