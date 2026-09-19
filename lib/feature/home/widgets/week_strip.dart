import 'package:care_circle/core/utils/care_event_formatter.dart';
import 'package:flutter/material.dart';
import 'package:care_circle/core/theme/app_colors.dart';
import 'package:care_circle/core/theme/app_sizes.dart';
import 'package:care_circle/core/widgets/app_text.dart';

class WeekStrip extends StatefulWidget {
  final DateTime selectedDay;
  final Set<DateTime> daysWithData;
  final ValueChanged<DateTime> onSelect;
  final int days;

  const WeekStrip({
    super.key,
    required this.selectedDay,
    required this.daysWithData,
    required this.onSelect,
    this.days = 30,
  });

  @override
  State<WeekStrip> createState() => _WeekStripState();
}

class _WeekStripState extends State<WeekStrip> {
  static const _labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_controller.hasClients) {
        _controller.jumpTo(_controller.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final today = CareEventFormatter.dayKey(DateTime.now());
    final days = List.generate(
      widget.days,
      (i) => today.subtract(Duration(days: widget.days - 1 - i)),
    );

    return SizedBox(
      height: 84,
      child: ListView.separated(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSizes.sm),
        itemBuilder: (context, i) {
          final day = days[i];
          final selected = day == widget.selectedDay;
          final isToday = day == today;
          final hasData = widget.daysWithData.contains(day);

          return GestureDetector(
            onTap: () => widget.onSelect(day),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 52,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(
                  color: selected
                      ? AppColors.primary
                      : isToday
                      ? AppColors.primary.withValues(alpha: 0.5)
                      : AppColors.border,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppText.caption(
                    _labels[day.weekday - 1],
                    color: selected ? Colors.white70 : AppColors.textSecondary,
                  ),
                  const SizedBox(height: 4),
                  AppText.body(
                    '${day.day}',
                    color: selected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: hasData
                          ? (selected ? Colors.white : AppColors.primary)
                          : Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
