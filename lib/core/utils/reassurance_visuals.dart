import 'package:care_circle/core/models/care_circle_models.dart';
import 'package:care_circle/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

({IconData icon, Color color, String label}) reassuranceVisual(
  ReassuranceState? state,
) => switch (state) {
  ReassuranceState.reassuring => (
    icon: Icons.check_circle,
    color: AppColors.statusGood,
    label: 'Doing okay',
  ),
  ReassuranceState.needsAttention => (
    icon: Icons.info,
    color: AppColors.statusAttention,
    label: 'Worth a look',
  ),
  ReassuranceState.notEnoughInformation => (
    icon: Icons.hourglass_empty,
    color: AppColors.statusUnknown,
    label: 'Not much yet',
  ),
  null => (
    icon: Icons.help_outline,
    color: AppColors.statusUnknown,
    label: 'No update yet',
  ),
};
