import 'package:classic_15_puzzle/theme/app_radii.dart';
import 'package:classic_15_puzzle/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Tonal icon button for secondary game actions (hint, refresh).
class GameActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final bool isLoading;

  /// Small count shown in the corner, e.g. hints remaining. Hidden while
  /// [isLoading].
  final String? badge;

  /// Draws [badge] in the error color instead of the primary one, to mark an
  /// exhausted resource.
  final bool isBadgeDepleted;

  const GameActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.isLoading = false,
    this.badge,
    this.isBadgeDepleted = false,
  });

  @override
  Widget build(BuildContext context) {
    final button = _buildButton(context);
    final badge = this.badge;
    if (badge == null || isLoading) return button;

    final colorScheme = Theme.of(context).colorScheme;
    final background =
        isBadgeDepleted ? colorScheme.error : colorScheme.primary;
    final foreground =
        isBadgeDepleted ? colorScheme.onError : colorScheme.onPrimary;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        button,
        Positioned(
          top: -2,
          right: -2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            constraints: const BoxConstraints(minWidth: 18),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(AppRadii.sm),
              border: Border.all(
                color: colorScheme.surface,
                width: 1.5,
              ),
            ),
            child: Text(
              badge,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: foreground,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButton(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: tooltip,
      child: IconButton.filledTonal(
        onPressed: isLoading ? () {} : onPressed,
        icon: isLoading
            ? SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              )
            : Icon(icon, size: 28),
        padding: const EdgeInsets.all(AppSpacing.sm),
        constraints: const BoxConstraints(
          minWidth: AppSpacing.minTouchTarget,
          minHeight: AppSpacing.minTouchTarget,
        ),
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ),
      ),
    );
  }
}
