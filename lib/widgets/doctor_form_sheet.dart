import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/ui.dart';
import '../models/doctor.dart';
import '../state/app_state.dart';

/// نافذة سفلية لإضافة طبيب جديد أو تعديل بيانات طبيب.
Future<void> showDoctorForm(BuildContext context, {Doctor? doctor}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _DoctorForm(doctor: doctor),
  );
}

class _DoctorForm extends StatefulWidget {
  const _DoctorForm({this.doctor});

  final Doctor? doctor;

  @override
  State<_DoctorForm> createState() => _DoctorFormState();
}

class _DoctorFormState extends State<_DoctorForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _specialty;
  bool _saving = false;

  bool get _isEditing => widget.doctor != null;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.doctor?.name ?? '');
    _specialty = TextEditingController(text: widget.doctor?.specialty ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _specialty.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _saving = true);
    final state = context.read<AppState>();
    final name = _name.text.trim();
    final specialty = _specialty.text.trim();

    final ok = _isEditing
        ? await state.updateDoctor(
            widget.doctor!.copyWith(name: name, specialty: specialty),
          )
        : await state.addDoctor(name: name, specialty: specialty);

    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
    } else {
      setState(() => _saving = false);
      showMessage(context, 'تعذّر حفظ بيانات الطبيب. حاول مرة أخرى.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _isEditing ? 'تعديل بيانات الطبيب' : 'إضافة طبيب',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _name,
                textInputAction: TextInputAction.next,
                maxLength: 60,
                decoration: const InputDecoration(
                  labelText: 'اسم الطبيب',
                  prefixIcon: Icon(Icons.person_outline),
                  counterText: '',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'أدخل اسم الطبيب' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _specialty,
                textInputAction: TextInputAction.done,
                maxLength: 60,
                decoration: const InputDecoration(
                  labelText: 'الاختصاص',
                  prefixIcon: Icon(Icons.medical_services_outlined),
                  counterText: '',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'أدخل الاختصاص' : null,
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: _saving ? null : _submit,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_rounded),
                label: Text(_isEditing ? 'حفظ التعديلات' : 'إضافة'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
