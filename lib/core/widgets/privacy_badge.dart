import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';
import 'app_text.dart';

enum SharingLevel { visible, limited, hidden }

class PrivacyBadge extends StatelessWidget {
  final SharingLevel level;
  final String label;

  const PrivacyBadge({super.key, required this.level, required this.label});

  IconData get _icon => switch (level) {
    SharingLevel.visible => Icons.visibility_outlined,
    SharingLevel.limited => Icons.visibility_off_outlined,
    SharingLevel.hidden => Icons.lock_outline,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: AppSizes.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.privacyBadgeBg,
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: AppSizes.iconSm, color: AppColors.privacyBadgeText),
          const SizedBox(width: AppSizes.xs),
          AppText.caption(label), // uses badge-like caption
        ],
      ),
    );
  }
}
