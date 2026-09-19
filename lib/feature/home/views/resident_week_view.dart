import 'package:care_circle/core/models/care_circle_models.dart';
import 'package:care_circle/core/theme/app_colors.dart';
import 'package:care_circle/core/utils/care_event_formatter.dart';
import 'package:care_circle/core/widgets/app_scaffold.dart';
import 'package:care_circle/core/theme/app_sizes.dart';
import 'package:care_circle/core/widgets/app_text.dart';
import 'package:care_circle/feature/home/providers/home_providers.dart';
import 'package:care_circle/feature/home/widgets/week_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResidentWeekView extends ConsumerStatefulWidget {
  final String residentId;
  const ResidentWeekView({super.key, required this.residentId});

  @override
  ConsumerState<ResidentWeekView> createState() => _ResidentWeekViewState();
}

class _ResidentWeekViewState extends ConsumerState<ResidentWeekView> {
  late DateTime _selectedDay = CareEventFormatter.dayKey(DateTime.now());

  static const _parts = [
    (label: 'Morning', icon: Icons.wb_sunny_outlined, from: 0, to: 12),
    (label: 'Afternoon', icon: Icons.wb_cloudy_outlined, from: 12, to: 17),
    (label: 'Evening', icon: Icons.nights_stay_outlined, from: 17, to: 24),
  ];

  @override
  Widget build(BuildContext context) {
    final resident = ref.watch(residentByIdProvider(widget.residentId));
    final grouped = ref.watch(careEventsByDayProvider(widget.residentId));
    final undated = ref.watch(undatedCareEventsProvider(widget.residentId));
    final dayEvents = grouped[_selectedDay] ?? const <CareEvent>[];

    return AppScaffold(
      scrollable: false,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText.h3(resident?.name ?? 'Resident'),
            AppText.caption('Shared updates'),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSizes.xl),
        children: [
          const SizedBox(height: AppSizes.sm),
          WeekStrip(
            selectedDay: _selectedDay,
            daysWithData: grouped.keys.toSet(),
            onSelect: (d) => setState(() => _selectedDay = d),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.lg,
              AppSizes.lg,
              AppSizes.lg,
              AppSizes.md,
            ),
            child: _DayHeader(day: _selectedDay, count: dayEvents.length),
          ),
          if (dayEvents.isEmpty)
            const _EmptyDay()
          else
            for (final p in _parts)
              _PartSection(
                label: p.label,
                icon: p.icon,
                events: (dayEvents.where(
                  (e) {
                    final t = _timeOf(e);
                    return t != null && t.hour >= p.from && t.hour < p.to;
                  },
                ).toList()..sort((a, b) => _timeOf(a)!.compareTo(_timeOf(b)!))),
              ),
          if (undated.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
              child: Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: AppText.body(
                    'Undated updates (${undated.length})',
                    fontWeight: FontWeight.w600,
                  ),
                  subtitle: AppText.caption(
                    "Recorded without a usable time, so can't be placed on a day.",
                  ),
                  children: undated.map((e) => _EventCard(event: e)).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

DateTime? _timeOf(CareEvent e) => (e.scheduledAt ?? e.recordedAt)?.toLocal();

String _hm(DateTime t) {
  final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
  final m = t.minute.toString().padLeft(2, '0');
  return '$h:$m ${t.hour < 12 ? 'AM' : 'PM'}';
}

const _weekdays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];
const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

class _DayHeader extends StatelessWidget {
  final DateTime day;
  final int count;
  const _DayHeader({required this.day, required this.count});

  @override
  Widget build(BuildContext context) {
    final isToday = day == CareEventFormatter.dayKey(DateTime.now());
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.h3(
                '${_weekdays[day.weekday - 1]}, ${day.day} ${_months[day.month - 1]}',
              ),
              const SizedBox(height: 2),
              AppText.caption(
                count == 0
                    ? 'Nothing shared'
                    : '$count update${count == 1 ? '' : 's'}',
              ),
            ],
          ),
        ),
        if (isToday)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: AppText.caption('Today', color: AppColors.primary),
          ),
      ],
    );
  }
}

class _PartSection extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<CareEvent> events;
  const _PartSection({
    required this.label,
    required this.icon,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.lg,
        AppSizes.md,
        AppSizes.lg,
        AppSizes.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: AppSizes.sm),
              AppText.body(label, fontWeight: FontWeight.w700),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          ...events.map((e) => _EventCard(event: e)),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final CareEvent event;
  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final t = _timeOf(event);
    final s = _statusStyle(event.status);
    final note = event.note?.trim();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _categoryIcon(event.category),
              size: 20,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AppText.body(
                        CareEventFormatter.label(event),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (t != null) AppText.caption(_hm(t)),
                  ],
                ),
                if (note != null && note.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  AppText.secondary(note),
                ],
                const SizedBox(height: AppSizes.sm),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _Chip(
                      text: _statusText(event.status),
                      icon: s.icon,
                      color: s.color,
                    ),
                    if (event.durationMinutes != null)
                      _Chip(
                        text: '${event.durationMinutes} min',
                        icon: Icons.timer_outlined,
                        color: AppColors.textSecondary,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  const _Chip({required this.text, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          AppText.caption(text, color: color),
        ],
      ),
    );
  }
}

IconData _categoryIcon(EventCategory c) => switch (c) {
  EventCategory.medication => Icons.medication_outlined,
  EventCategory.meal => Icons.restaurant_outlined,
  EventCategory.activity => Icons.directions_walk_outlined,
  _ => Icons.help_outline,
};

// Every status has an icon and text as well as a color, per your accessibility note.
({Color color, IconData icon}) _statusStyle(String s) =>
    switch (s.toLowerCase()) {
      'given' ||
      'taken' ||
      'completed' ||
      'eaten' ||
      'done' => (color: AppColors.statusGood, icon: Icons.check_circle_outline),
      'missed' ||
      'refused' ||
      'skipped' => (color: AppColors.statusUrgent, icon: Icons.error_outline),
      'partial' ||
      'late' ||
      'delayed' => (color: AppColors.statusAttention, icon: Icons.schedule),
      _ => (color: AppColors.statusUnknown, icon: Icons.help_outline),
    };

String _statusText(String s) {
  if (s.isEmpty) return 'Unknown';
  final x = s.replaceAll('_', ' ');
  return x[0].toUpperCase() + x.substring(1);
}

class _EmptyDay extends StatelessWidget {
  const _EmptyDay();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xl),
      child: Column(
        children: [
          Icon(
            Icons.event_available_outlined,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSizes.sm),
          AppText.secondary('No shared updates for this day.'),
        ],
      ),
    );
  }
}
