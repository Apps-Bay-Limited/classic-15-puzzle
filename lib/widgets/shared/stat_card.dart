import 'package:classic_15_puzzle/theme/app_radii.dart';
import 'package:classic_15_puzzle/theme/app_spacing.dart';
import 'package:classic_15_puzzle/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Displays a labeled stat with an icon — used for time, moves, etc.
class StatCard extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueChild;
  final IconData icon;

  const StatCard({
    super.key,
    required this.label,
    required this.icon,
    this.value,
    this.valueChild,
  }) : assert(value != null || valueChild != null);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    final valueWidget = valueChild ??
        Text(
          value!,
          style: AppTypography.statValue(context),
          maxLines: 1,
          softWrap: false,
        );

    return Semantics(
      label: value != null ? '$label: $value' : label,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isIOS
              ? colorScheme.surfaceContainer.withValues(alpha: 0.5)
              : colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: isIOS
              ? Border.all(color: Colors.white.withValues(alpha: 0.1))
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: colorScheme.primary, size: 16),
                const SizedBox(width: AppSpacing.xxs),
                Text(
                  label,
                  style: AppTypography.statLabel(context),
                  maxLines: 1,
                  softWrap: false,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxs),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: valueWidget,
            ),
          ],
        ),
      ),
    );
  }
}
