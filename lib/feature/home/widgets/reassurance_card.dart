import 'package:care_circle/core/models/care_circle_models.dart';
import 'package:care_circle/core/theme/app_colors.dart';
import 'package:care_circle/core/theme/app_sizes.dart';
import 'package:care_circle/core/widgets/app_text.dart';
import 'package:flutter/material.dart';

class ReassuranceCard extends StatelessWidget {
  final DailySummary? summary;
  final String residentName;

  const ReassuranceCard({
    super.key,
    required this.summary,
    required this.residentName,
  });

  ({IconData icon, Color color, String label}) get _visual {
    if (summary == null) {
      return (
        icon: Icons.help_outline,
        color: AppColors.statusUnknown,
        label: 'No update yet today',
      );
    }
    return switch (summary!.reassuranceState) {
      ReassuranceState.reassuring => (
        icon: Icons.check_circle,
        color: AppColors.statusGood,
        label: '$residentName is okay',
      ),
      ReassuranceState.needsAttention => (
        icon: Icons.info,
        color: AppColors.statusAttention,
        label: 'Worth a look today',
      ),
      ReassuranceState.notEnoughInformation => (
        icon: Icons.hourglass_empty,
        color: AppColors.statusUnknown,
        label: 'Not much to report yet',
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final v = _visual;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.xl),
      decoration: BoxDecoration(
        color: v.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: v.color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(v.icon, color: v.color, size: AppSizes.iconLg),
          const SizedBox(height: AppSizes.md),
          AppText.h2(v.label),
          if (summary?.headline != null) ...[
            const SizedBox(height: AppSizes.xs),
            AppText.secondary(summary!.headline),
          ],
          const SizedBox(height: AppSizes.xs),
          AppText.caption(_freshnessLabel(summary?.generatedAt)),
        ],
      ),
    );
  }

  String _freshnessLabel(DateTime? generatedAt) {
    if (generatedAt == null) return 'No update recorded';
    final hrs = DateTime.now().toUtc().difference(generatedAt.toUtc()).inHours;
    if (hrs < 1) return 'Updated less than an hour ago';
    if (hrs < 24) return 'Updated $hrs hour${hrs == 1 ? '' : 's'} ago';
    return 'Last updated more than a day ago';
  }
}
