import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/formatters.dart';
import '../core/parsers.dart';
import '../core/ui.dart';
import '../models/appointment.dart';
import '../models/enums.dart';
import '../state/app_state.dart';

/// نموذج إضافة حجز جديد أو تعديل حجز موجود.
class AppointmentFormScreen extends StatefulWidget {
  const AppointmentFormScreen({
    super.key,
    required this.doctorId,
    this.initialAgeGroup,
    this.initialGender,
    this.existing,
  });

  final int doctorId;
  final AgeGroup? initialAgeGroup;
  final Gender? initialGender;
  final Appointment? existing;

  @override
  State<AppointmentFormScreen> createState() => _AppointmentFormScreenState();
}

class _AppointmentFormScreenState extends State<AppointmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _patient;
  late final TextEditingController _title;
  late final TextEditingController _amount;
  late final TextEditingController _notes;

  late AgeGroup _ageGroup;
  late Gender _gender;
  late AppointmentKind _kind;
  late DateTime _dateTime;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _patient = TextEditingController(text: e?.patientName ?? '');
    _title = TextEditingController(text: e?.title ?? '');
    _amount = TextEditingController(
      text: e == null || e.amount == 0 ? '' : _plainNumber(e.amount),
    );
    _notes = TextEditingController(text: e?.notes ?? '');
    _ageGroup = e?.ageGroup ?? widget.initialAgeGroup ?? AgeGroup.adult;
    _gender = e?.gender ?? widget.initialGender ?? Gender.male;
    _kind = e?.kind ?? AppointmentKind.review;

    if (e != null) {
      _dateTime = e.dateTime;
    } else {
      final now = DateTime.now();
      _dateTime = DateTime(now.year, now.month, now.day, now.hour + 1);
    }
  }

  @override
  void dispose() {
    _patient.dispose();
    _title.dispose();
    _amount.dispose();
    _notes.dispose();
    super.dispose();
  }

  /// يحوّل رقمًا إلى نص بسيط قابل للتحرير (بدون فواصل، وبدون كسر زائد).
  static String _plainNumber(double value) {
    return value == value.truncateToDouble()
        ? value.toInt().toString()
        : value.toString();
  }

  Future<void> _pickDateTime() async {
    final picked = await pickDateTime(context, _dateTime);
    if (picked != null && mounted) {
      setState(() => _dateTime = picked);
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final state = context.read<AppState>();

    if (state.hasConflict(
      widget.doctorId,
      _dateTime,
      excludeId: widget.existing?.id,
    )) {
      final proceed = await confirmDialog(
        context,
        title: 'تعارض في المواعيد',
        message: 'يوجد حجز آخر لنفس الطبيب في هذا الوقت. هل تريد المتابعة؟',
        confirmLabel: 'متابعة',
      );
      if (!proceed || !mounted) return;
    }

    setState(() => _saving = true);

    final amount = parseAmount(_amount.text) ?? 0;
    final existing = widget.existing;
    final appointment = Appointment(
      id: existing?.id,
      doctorId: widget.doctorId,
      patientName: _patient.text.trim(),
      ageGroup: _ageGroup,
      gender: _gender,
      kind: _kind,
      title: _title.text.trim(),
      dateTime: _dateTime,
      amount: amount,
      notes: _notes.text.trim(),
      status: existing?.status ?? AppointmentStatus.active,
      createdAt: existing?.createdAt ?? DateTime.now(),
    );

    final ok = _isEditing
        ? await state.updateAppointment(appointment)
        : await state.addAppointment(appointment);

    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _saving = false);
      showMessage(context, 'تعذّر حفظ الحجز. حاول مرة أخرى.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isSurgery = _kind == AppointmentKind.surgery;

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'تعديل الحجز' : 'حجز جديد')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_rounded),
            label: Text(_isEditing ? 'حفظ التعديلات' : 'حفظ الحجز'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _patient,
              textInputAction: TextInputAction.next,
              maxLength: 80,
              decoration: const InputDecoration(
                labelText: 'اسم المريض',
                prefixIcon: Icon(Icons.person_outline),
                counterText: '',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'أدخل اسم المريض' : null,
            ),
            const SizedBox(height: 16),
            const _SectionLabel('الفئة العمرية'),
            SegmentedButton<AgeGroup>(
              showSelectedIcon: false,
              segments: [
                for (final g in AgeGroup.values)
                  ButtonSegment<AgeGroup>(
                    value: g,
                    label: Text(g.label),
                    icon: Icon(g.icon),
                  ),
              ],
              selected: {_ageGroup},
              onSelectionChanged: (s) => setState(() => _ageGroup = s.first),
            ),
            const SizedBox(height: 16),
            const _SectionLabel('الجنس'),
            SegmentedButton<Gender>(
              showSelectedIcon: false,
              segments: [
                for (final g in Gender.values)
                  ButtonSegment<Gender>(
                    value: g,
                    label: Text(g.singularLabel),
                    icon: Icon(g.icon),
                  ),
              ],
              selected: {_gender},
              onSelectionChanged: (s) => setState(() => _gender = s.first),
            ),
            const SizedBox(height: 16),
            const _SectionLabel('نوع الموعد'),
            SegmentedButton<AppointmentKind>(
              showSelectedIcon: false,
              segments: [
                for (final k in AppointmentKind.values)
                  ButtonSegment<AppointmentKind>(
                    value: k,
                    label: Text(k.label),
                    icon: Icon(k.icon),
                  ),
              ],
              selected: {_kind},
              onSelectionChanged: (s) => setState(() => _kind = s.first),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _title,
              textInputAction: TextInputAction.next,
              maxLength: 100,
              decoration: InputDecoration(
                labelText: isSurgery ? 'نوع العملية' : 'سبب / نوع المراجعة',
                hintText: isSurgery
                    ? 'مثال: استئصال الزائدة الدودية'
                    : 'مثال: متابعة، استشارة (اختياري)',
                prefixIcon: Icon(_kind.icon),
                counterText: '',
              ),
              validator: (v) {
                if (isSurgery && (v == null || v.trim().isEmpty)) {
                  return 'أدخل نوع العملية';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const _SectionLabel('الموعد'),
            Material(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: scheme.outline),
              ),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                leading: Icon(Icons.event_rounded, color: scheme.primary),
                title: Text(Fmt.date(_dateTime)),
                subtitle: Text(Fmt.time(_dateTime)),
                trailing: const Icon(Icons.edit_calendar_outlined),
                onTap: _pickDateTime,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amount,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.next,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩۰-۹.,٫٬]')),
              ],
              decoration: const InputDecoration(
                labelText: 'المبلغ المترتب',
                suffixText: Fmt.currency,
                prefixIcon: Icon(Icons.payments_outlined),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                return parseAmount(v) == null ? 'أدخل مبلغًا صحيحًا' : null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notes,
              minLines: 2,
              maxLines: 4,
              maxLength: 300,
              textInputAction: TextInputAction.newline,
              decoration: const InputDecoration(
                labelText: 'ملاحظات (اختياري)',
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 36),
                  child: Icon(Icons.sticky_note_2_outlined),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .labelLarge
            ?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}
