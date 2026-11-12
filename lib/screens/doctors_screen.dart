import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/formatters.dart';
import '../core/ui.dart';
import '../models/doctor.dart';
import '../state/app_state.dart';
import '../widgets/doctor_form_sheet.dart';
import '../widgets/empty_state.dart';
import 'doctor_screen.dart';

enum _DoctorAction { edit, delete }

/// الشاشة الرئيسية: قائمة الأطباء واختصاصاتهم.
class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({super.key});

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _delete(Doctor doctor) async {
    final state = context.read<AppState>();
    final count = state.appointmentsFor(doctor.id!).length;
    final confirmed = await confirmDialog(
      context,
      title: 'حذف الطبيب',
      message: count == 0
          ? 'هل تريد حذف ${doctor.name}؟'
          : 'سيتم حذف ${doctor.name} مع جميع حجوزاته '
              '(${Fmt.count(count)} حجز). لا يمكن التراجع عن ذلك.',
      confirmLabel: 'حذف',
      destructive: true,
    );
    if (!confirmed || !mounted) return;

    final ok = await state.deleteDoctor(doctor.id!);
    if (!mounted) return;
    showMessage(context, ok ? 'تم حذف الطبيب' : 'تعذّر حذف الطبيب');
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final query = _query.trim().toLowerCase();
    final doctors = state.doctors.where((d) {
      if (query.isEmpty) return true;
      return d.name.toLowerCase().contains(query) ||
          d.specialty.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('المُغير')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDoctorForm(context),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('إضافة طبيب'),
      ),
      body: _buildBody(state, doctors),
    );
  }

  Widget _buildBody(AppState state, List<Doctor> doctors) {
    if (state.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null && state.doctors.isEmpty) {
      return EmptyState(
        icon: Icons.error_outline_rounded,
        title: state.error!,
        action: FilledButton(
          onPressed: () => context.read<AppState>().load(),
          child: const Text('إعادة المحاولة'),
        ),
      );
    }
    if (state.doctors.isEmpty) {
      return const EmptyState(
        icon: Icons.local_hospital_outlined,
        title: 'لا يوجد أطباء بعد',
        subtitle: 'اضغط على «إضافة طبيب» للبدء بتنظيم الحجوزات.',
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _search,
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'ابحث باسم الطبيب أو الاختصاص',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        _search.clear();
                        setState(() => _query = '');
                      },
                    ),
            ),
          ),
        ),
        Expanded(
          child: doctors.isEmpty
              ? const EmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'لا توجد نتائج مطابقة',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  itemCount: doctors.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final doctor = doctors[index];
                    return _DoctorTile(
                      doctor: doctor,
                      activeCount: state.activeCount(doctor.id!),
                      onOpen: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => DoctorScreen(doctorId: doctor.id!),
                        ),
                      ),
                      onAction: (action) {
                        switch (action) {
                          case _DoctorAction.edit:
                            showDoctorForm(context, doctor: doctor);
                          case _DoctorAction.delete:
                            _delete(doctor);
                        }
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _DoctorTile extends StatelessWidget {
  const _DoctorTile({
    required this.doctor,
    required this.activeCount,
    required this.onOpen,
    required this.onAction,
  });

  final Doctor doctor;
  final int activeCount;
  final VoidCallback onOpen;
  final ValueChanged<_DoctorAction> onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: scheme.primaryContainer,
                foregroundColor: scheme.onPrimaryContainer,
                child: const Icon(Icons.medical_services_rounded),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      doctor.specialty,
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${Fmt.count(activeCount)} حجز نشط',
                      style: TextStyle(
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<_DoctorAction>(
                tooltip: 'خيارات',
                onSelected: onAction,
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: _DoctorAction.edit,
                    child: ListTile(
                      leading: Icon(Icons.edit_outlined),
                      title: Text('تعديل'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: _DoctorAction.delete,
                    child: ListTile(
                      leading: Icon(Icons.delete_outline),
                      title: Text('حذف'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
