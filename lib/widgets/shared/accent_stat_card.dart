import 'package:classic_15_puzzle/theme/app_colors.dart';
import 'package:classic_15_puzzle/theme/app_radii.dart';
import 'package:classic_15_puzzle/theme/app_spacing.dart';
import 'package:classic_15_puzzle/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Accent-highlighted stat card for Hall of Fame best records.
class AccentStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;

  const AccentStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
  });

  factory AccentStatCard.gold({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return AccentStatCard(
      label: label,
      value: value,
      icon: icon,
      accentColor: AppColors.accentGold,
    );
  }

  factory AccentStatCard.slate({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return AccentStatCard(
      label: label,
      value: value,
      icon: icon,
      accentColor: AppColors.accentSlate,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accentColor, size: 20),
          const SizedBox(height: AppSpacing.xs),
          Text(label, style: AppTypography.accentLabel(context, accentColor)),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: AppTypography.statValue(context).copyWith(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
