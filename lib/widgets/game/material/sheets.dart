import 'dart:math';
import 'dart:ui';

import 'package:classic_15_puzzle/config/ui.dart';
import 'package:classic_15_puzzle/data/board.dart';
import 'package:classic_15_puzzle/theme/app_radii.dart';
import 'package:classic_15_puzzle/theme/app_spacing.dart';
import 'package:classic_15_puzzle/theme/app_typography.dart';
import 'package:classic_15_puzzle/widgets/about/dialog.dart';
import 'package:classic_15_puzzle/widgets/game/board.dart';
import 'package:flutter/material.dart' hide AboutDialog;
import 'package:flutter/services.dart';

Widget createSettingsBottomSheet(
  BuildContext context, {
  required void Function(int) onGridSizeSelected,
}) {
  final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
  final colorScheme = Theme.of(context).colorScheme;
  final ui = ConfigUiContainer.of(context);

  Widget createBoard({required int size}) => Column(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.all(AppSpacing.xs),
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppRadii.sm),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Semantics(
              label: '${size}x$size grid',
              button: true,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadii.xs),
                onTap: () {
                  HapticFeedback.mediumImpact();
                  onGridSizeSelected(size);
                  Navigator.of(context).pop();
                },
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final puzzleSize = min(
                      min(constraints.maxWidth, constraints.maxHeight),
                      80.0,
                    );

                    return Semantics(
                      excludeSemantics: true,
                      child: IgnorePointer(
                        child: BoardWidget(
                          board: Board.createNormal(size),
                          onTap: null,
                          showNumbers: false,
                          size: puzzleSize,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            '${size}x$size',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      );

  Widget content = Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.xl,
    ),
    decoration: BoxDecoration(
      color: isIOS
          ? colorScheme.surface.withValues(alpha: 0.7)
          : colorScheme.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (!isIOS)
          Container(
            width: 40,
            height: AppRadii.sheetHandle,
            margin: const EdgeInsets.only(bottom: AppSpacing.lg),
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(AppRadii.sheetHandle),
            ),
          ),
        Text(
          'Settings',
          style: AppTypography.dialogTitle(context),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Customize your puzzle experience',
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.xl),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'GRID SIZE',
            style: AppTypography.sectionHeader(context),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            createBoard(size: 3),
            createBoard(size: 4),
            createBoard(size: 5),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        _SettingsToggle(
          icon: Icons.dark_mode_rounded,
          label: 'Dark mode',
          value: ui?.useDarkTheme ?? false,
          onChanged: (value) {
            HapticFeedback.selectionClick();
            ui?.setUseDarkTheme(value, save: true);
          },
        ),
        _SettingsToggle(
          icon: Icons.bolt_rounded,
          label: 'Speed run mode',
          subtitle: 'Faster animations, tap-only tiles',
          value: ui?.isSpeedRunModeEnabled ?? false,
          onChanged: (value) {
            HapticFeedback.selectionClick();
            ui?.setSpeedRunModeEnabled(value, save: true);
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        Semantics(
          button: true,
          label: 'About',
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.info_outline_rounded, color: colorScheme.primary),
            title: const Text('About', style: TextStyle(fontWeight: FontWeight.w600)),
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.outline,
            ),
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).pop();
              showDialog(
                context: context,
                builder: (context) => const AboutDialog(),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
      ],
    ),
  );

  if (isIOS) {
    content = ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: content,
      ),
    );
  }

  return content;
}

class _SettingsToggle extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsToggle({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      secondary: Icon(icon, color: colorScheme.primary),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: subtitle != null
          ? Text(subtitle!, style: TextStyle(color: colorScheme.onSurfaceVariant))
          : null,
      value: value,
      onChanged: onChanged,
    );
  }
}

/// @deprecated Use [createSettingsBottomSheet] instead.
Widget createMoreBottomSheet(
  BuildContext context, {
  required void Function(int) call,
}) {
  return createSettingsBottomSheet(context, onGridSizeSelected: call);
}
