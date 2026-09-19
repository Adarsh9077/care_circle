import 'package:care_circle/core/models/care_circle_models.dart';
import 'package:care_circle/core/theme/app_colors.dart';
import 'package:care_circle/core/theme/app_sizes.dart';
import 'package:care_circle/core/widgets/app_text.dart';
import 'package:flutter/material.dart';

class SeeTodaySection extends StatefulWidget {
  final List<CareEvent> events;
  final bool initiallyExpanded;
  const SeeTodaySection({
    super.key,
    required this.events,
    this.initiallyExpanded = false,
  });

  @override
  State<SeeTodaySection> createState() => _SeeTodaySectionState();
}

class _SeeTodaySectionState extends State<SeeTodaySection> {
  late bool _expanded = widget.initiallyExpanded;
  bool _isToday(CareEvent e) {
    final t = _when(e);
    if (t == null) {
      return false;
    }
    final now = DateTime.now();
    return t.year == now.year && t.month == now.month && t.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final events = widget.events.where(_isToday).toList()..sort(_byTime);
    final attention = events.where((e) => _status(e).attention).length;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Row(
                  children: [
                    const Icon(Icons.today_outlined, color: AppColors.primary),
                    const SizedBox(width: AppSizes.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText.h3('Today'),
                          const SizedBox(height: 2),
                          if (events.isEmpty)
                            AppText.caption('No shared updates yet')
                          else
                            AppText.caption(
                              attention == 0
                                  ? '${events.length} update${events.length == 1 ? '' : 's'}'
                                  : '${events.length} updates · $attention need${attention == 1 ? 's' : ''} attention',
                              color: attention == 0
                                  ? AppColors.textSecondary
                                  : AppColors.statusAttention,
                            ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(
                        Icons.expand_more,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: !_expanded
                  ? const SizedBox(width: double.infinity)
                  : Column(
                      children: [
                        const Divider(height: 1, color: AppColors.divider),
                        if (events.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(AppSizes.lg),
                            child: AppText.secondary(
                              'Updates will appear here as they are shared.',
                            ),
                          )
                        else
                          for (var i = 0; i < events.length; i++) ...[
                            _TodayRow(event: events[i]),
                            if (i != events.length - 1)
                              const Divider(
                                height: 1,
                                indent: 68,
                                color: AppColors.divider,
                              ),
                          ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayRow extends StatelessWidget {
  final CareEvent event;
  const _TodayRow({required this.event});

  @override
  Widget build(BuildContext context) {
    final s = _status(event);
    final t = _when(event);
    final note = event.note?.trim();

    return Padding(
      padding: const EdgeInsets.all(AppSizes.md),
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
              _icon(event.category),
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
                        _name(event),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    AppText.caption(
                      t == null ? 'Time not recorded' : _clock(t),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _Pill(text: s.text, icon: s.icon, color: s.color),
                    if (event.durationMinutes != null)
                      _Pill(
                        text: '${event.durationMinutes} min',
                        icon: Icons.timer_outlined,
                        color: AppColors.textSecondary,
                      ),
                  ],
                ),
                if (note != null && note.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  AppText.secondary(note),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  const _Pill({required this.text, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Container(
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

// ---- helpers ----

DateTime? _when(CareEvent e) => (e.scheduledAt ?? e.recordedAt)?.toLocal();

int _byTime(CareEvent a, CareEvent b) {
  final x = _when(a), y = _when(b);
  if (x == null && y == null) return 0;
  if (x == null) return 1; // undated goes last
  if (y == null) return -1;
  return x.compareTo(y);
}

String _clock(DateTime t) {
  final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
  return '$h:${t.minute.toString().padLeft(2, '0')} ${t.hour < 12 ? 'AM' : 'PM'}';
}

String _name(CareEvent e) => switch (e.category) {
  EventCategory.medication => e.medicationLabel ?? 'Medication',
  EventCategory.meal => e.mealType ?? 'Meal',
  EventCategory.activity => e.activityType ?? 'Activity',
  EventCategory.unknown => 'Update',
};

IconData _icon(EventCategory c) => switch (c) {
  EventCategory.medication => Icons.medication_outlined,
  EventCategory.meal => Icons.restaurant_outlined,
  EventCategory.activity => Icons.directions_walk_outlined,
  EventCategory.unknown => Icons.help_outline,
};

const _knownStatuses = {
  EventCategory.medication: {'taken', 'missed', 'delayed'},
  EventCategory.meal: {'completed', 'partial', 'skipped'},
  EventCategory.activity: {'completed', 'cancelled'},
};

({String text, IconData icon, Color color, bool attention}) _status(
  CareEvent e,
) {
  if (!(_knownStatuses[e.category]?.contains(e.status) ?? false)) {
    // unrecognized or malformed: degrade quietly, never show raw text
    return (
      text: 'Recorded',
      icon: Icons.info_outline,
      color: AppColors.statusUnknown,
      attention: false,
    );
  }
  final text = e.status[0].toUpperCase() + e.status.substring(1);
  return switch (e.status) {
    'taken' || 'completed' => (
      text: text,
      icon: Icons.check_circle_outline,
      color: AppColors.statusGood,
      attention: false,
    ),
    'missed' || 'skipped' => (
      text: text,
      icon: Icons.error_outline,
      color: AppColors.statusUrgent,
      attention: true,
    ),
    'delayed' || 'partial' => (
      text: text,
      icon: Icons.schedule,
      color: AppColors.statusAttention,
      attention: true,
    ),
    _ => (
      text: text, // cancelled
      icon: Icons.cancel_outlined,
      color: AppColors.statusUnknown,
      attention: false,
    ),
  };
}
