import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/formatters.dart';
import '../models/enums.dart';
import '../state/app_state.dart';
import 'appointments_screen.dart';

/// شاشة الطبيب: أقسام الكبار والصغار، وكل قسم مقسّم إلى ذكور وإناث.
class DoctorScreen extends StatelessWidget {
  const DoctorScreen({super.key, required this.doctorId});

  final int doctorId;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final doctor = state.doctorById(doctorId);

    if (doctor == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('الطبيب')),
        body: const Center(child: Text('هذا الطبيب غير موجود')),
      );
    }

    final scheme = Theme.of(context).colorScheme;
    final total = state.activeCount(doctorId);

    return Scaffold(
      appBar: AppBar(title: Text(doctor.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  child: const Icon(Icons.medical_services_rounded, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.name,
                        style:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: scheme.onPrimaryContainer,
                                ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        doctor.specialty,
                        style: TextStyle(color: scheme.onPrimaryContainer),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'إجمالي الحجوزات النشطة: ${Fmt.count(total)}',
                        style: TextStyle(
                          color: scheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          for (final group in AgeGroup.values) ...[
            _GroupCard(doctorId: doctorId, group: group),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.doctorId, required this.group});

  final int doctorId;
  final AgeGroup group;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final scheme = Theme.of(context).colorScheme;
    final total = state.activeCount(doctorId, ageGroup: group);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(group.icon, color: scheme.primary, size: 28),
                const SizedBox(width: 10),
                Text(
                  'المرضى ${group.label}',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                Text(
                  '${Fmt.count(total)} حجز',
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                for (final gender in Gender.values) ...[
                  Expanded(
                    child: _GenderTile(
                      doctorId: doctorId,
                      group: group,
                      gender: gender,
                    ),
                  ),
                  if (gender != Gender.values.last) const SizedBox(width: 12),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GenderTile extends StatelessWidget {
  const _GenderTile({
    required this.doctorId,
    required this.group,
    required this.gender,
  });

  final int doctorId;
  final AgeGroup group;
  final Gender gender;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final count = context
        .watch<AppState>()
        .activeCount(doctorId, ageGroup: group, gender: gender);

    return Material(
      color: scheme.surfaceContainerHighest.withAlpha(110),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => AppointmentsScreen(
              doctorId: doctorId,
              ageGroup: group,
              gender: gender,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(gender.icon, size: 30, color: scheme.primary),
              const SizedBox(height: 6),
              Text(
                gender.label,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                '${Fmt.count(count)} حجز نشط',
                style: TextStyle(
                  fontSize: 12.5,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
