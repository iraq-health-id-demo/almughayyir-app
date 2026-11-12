import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/formatters.dart';
import '../core/ui.dart';
import '../models/appointment.dart';
import '../models/enums.dart';
import '../state/app_state.dart';
import '../widgets/appointment_card.dart';
import '../widgets/empty_state.dart';
import 'appointment_form_screen.dart';

enum _StatusFilter { active, cancelled, all }

/// قائمة حجوزات الطبيب لفئة عمرية وجنس محددين.
class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({
    super.key,
    required this.doctorId,
    required this.ageGroup,
    required this.gender,
  });

  final int doctorId;
  final AgeGroup ageGroup;
  final Gender gender;

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  _StatusFilter _status = _StatusFilter.active;
  AppointmentKind? _kind;
  bool _ascending = true;

  Future<void> _openForm({Appointment? existing}) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => AppointmentFormScreen(
          doctorId: widget.doctorId,
          initialAgeGroup: widget.ageGroup,
          initialGender: widget.gender,
          existing: existing,
        ),
      ),
    );
  }

  Future<void> _handleAction(
    Appointment appointment,
    AppointmentAction action,
  ) async {
    switch (action) {
      case AppointmentAction.edit:
        await _openForm(existing: appointment);
      case AppointmentAction.reschedule:
        await _reschedule(appointment);
      case AppointmentAction.toggleCancel:
        await _toggleCancel(appointment);
      case AppointmentAction.delete:
        await _delete(appointment);
    }
  }

  Future<bool> _confirmConflict() {
    return confirmDialog(
      context,
      title: 'تعارض في المواعيد',
      message: 'يوجد حجز آخر لنفس الطبيب في هذا الوقت. هل تريد المتابعة؟',
      confirmLabel: 'متابعة',
    );
  }

  Future<void> _reschedule(Appointment appointment) async {
    final state = context.read<AppState>();
    final picked = await pickDateTime(context, appointment.dateTime);
    if (picked == null || !mounted) return;
    if (picked.isAtSameMomentAs(appointment.dateTime)) return;

    if (state.hasConflict(
      appointment.doctorId,
      picked,
      excludeId: appointment.id,
    )) {
      final proceed = await _confirmConflict();
      if (!proceed || !mounted) return;
    }

    final ok = await state.rescheduleAppointment(appointment, picked);
    if (!mounted) return;
    showMessage(
      context,
      ok ? 'تم تغيير موعد الحجز' : 'تعذّر تغيير الموعد، حاول مرة أخرى',
    );
  }

  Future<void> _toggleCancel(Appointment appointment) async {
    final state = context.read<AppState>();
    final restoring = appointment.isCancelled;

    if (restoring) {
      if (state.hasConflict(
        appointment.doctorId,
        appointment.dateTime,
        excludeId: appointment.id,
      )) {
        final proceed = await _confirmConflict();
        if (!proceed || !mounted) return;
      }
    } else {
      final confirmed = await confirmDialog(
        context,
        title: 'إلغاء الحجز',
        message: 'هل تريد إلغاء حجز ${appointment.patientName}؟ '
            'يمكنك استعادته لاحقًا.',
        confirmLabel: 'إلغاء الحجز',
        destructive: true,
      );
      if (!confirmed || !mounted) return;
    }

    final ok = await state.setAppointmentStatus(
      appointment,
      restoring ? AppointmentStatus.active : AppointmentStatus.cancelled,
    );
    if (!mounted) return;
    showMessage(
      context,
      ok
          ? (restoring ? 'تمت استعادة الحجز' : 'تم إلغاء الحجز')
          : 'تعذّر تنفيذ العملية، حاول مرة أخرى',
    );
  }

  Future<void> _delete(Appointment appointment) async {
    final state = context.read<AppState>();
    final confirmed = await confirmDialog(
      context,
      title: 'حذف الحجز نهائيًا',
      message: 'سيتم حذف حجز ${appointment.patientName} نهائيًا '
          'ولا يمكن التراجع عن ذلك.',
      confirmLabel: 'حذف',
      destructive: true,
    );
    if (!confirmed || !mounted) return;

    final ok = await state.deleteAppointment(appointment.id!);
    if (!mounted) return;
    showMessage(context, ok ? 'تم حذف الحجز' : 'تعذّر حذف الحجز');
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final doctor = state.doctorById(widget.doctorId);

    final all = state.appointmentsFor(
      widget.doctorId,
      ageGroup: widget.ageGroup,
      gender: widget.gender,
    );

    final filtered = all.where((a) {
      switch (_status) {
        case _StatusFilter.active:
          if (a.isCancelled) return false;
        case _StatusFilter.cancelled:
          if (!a.isCancelled) return false;
        case _StatusFilter.all:
          break;
      }
      if (_kind != null && a.kind != _kind) return false;
      return true;
    }).toList()
      ..sort(
        (a, b) => _ascending
            ? a.dateTime.compareTo(b.dateTime)
            : b.dateTime.compareTo(a.dateTime),
      );

    final activeShown = filtered.where((a) => !a.isCancelled);
    final totalAmount = activeShown.fold<double>(0, (sum, a) => sum + a.amount);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${widget.ageGroup.label} • ${widget.gender.label}'),
            if (doctor != null)
              Text(
                doctor.name,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: _ascending
                ? 'الترتيب: الأقدم أولًا'
                : 'الترتيب: الأحدث أولًا',
            icon: Icon(
              _ascending
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
            ),
            onPressed: () => setState(() => _ascending = !_ascending),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('حجز جديد'),
      ),
      body: Column(
        children: [
          _FilterBar(
            status: _status,
            kind: _kind,
            onStatus: (v) => setState(() => _status = v),
            onKind: (v) => setState(() => _kind = v),
          ),
          if (filtered.isNotEmpty)
            _SummaryBar(
              count: filtered.length,
              total: totalAmount,
            ),
          Expanded(
            child: filtered.isEmpty
                ? EmptyState(
                    icon: Icons.event_available_outlined,
                    title: all.isEmpty
                        ? 'لا توجد حجوزات في هذا القسم'
                        : 'لا توجد حجوزات مطابقة للتصفية',
                    subtitle: all.isEmpty
                        ? 'اضغط على «حجز جديد» لإضافة أول حجز.'
                        : null,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final appointment = filtered[index];
                      return AppointmentCard(
                        key: ValueKey(appointment.id),
                        appointment: appointment,
                        onAction: (action) =>
                            _handleAction(appointment, action),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.status,
    required this.kind,
    required this.onStatus,
    required this.onKind,
  });

  final _StatusFilter status;
  final AppointmentKind? kind;
  final ValueChanged<_StatusFilter> onStatus;
  final ValueChanged<AppointmentKind?> onKind;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('النشطة'),
            selected: status == _StatusFilter.active,
            onSelected: (_) => onStatus(_StatusFilter.active),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('الملغاة'),
            selected: status == _StatusFilter.cancelled,
            onSelected: (_) => onStatus(_StatusFilter.cancelled),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('الكل'),
            selected: status == _StatusFilter.all,
            onSelected: (_) => onStatus(_StatusFilter.all),
          ),
          const SizedBox(width: 16),
          Container(
            width: 1,
            height: 24,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(width: 16),
          ChoiceChip(
            label: const Text('كل الأنواع'),
            selected: kind == null,
            onSelected: (_) => onKind(null),
          ),
          for (final k in AppointmentKind.values) ...[
            const SizedBox(width: 8),
            ChoiceChip(
              label: Text(k.pluralLabel),
              selected: kind == k,
              onSelected: (_) => onKind(k),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryBar extends StatelessWidget {
  const _SummaryBar({required this.count, required this.total});

  final int count;
  final double total;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'عدد الحجوزات: ${Fmt.count(count)}',
              style: TextStyle(
                color: scheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            'المجموع: ${Fmt.money(total)}',
            style: TextStyle(
              color: scheme.onPrimaryContainer,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
