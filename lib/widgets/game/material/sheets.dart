import 'dart:math';
import 'dart:ui';

import 'package:classic_15_puzzle/config/ui.dart';
import 'package:classic_15_puzzle/data/board.dart';
import 'package:classic_15_puzzle/l10n/generated/app_localizations.dart';
import 'package:classic_15_puzzle/theme/app_radii.dart';
import 'package:classic_15_puzzle/theme/app_spacing.dart';
import 'package:classic_15_puzzle/theme/app_typography.dart';
import 'package:classic_15_puzzle/theme/tile_theme.dart';
import 'package:classic_15_puzzle/widgets/about/dialog.dart';
import 'package:classic_15_puzzle/widgets/game/board.dart';
import 'package:classic_15_puzzle/widgets/util/photo_theme_manager.dart';
import 'package:classic_15_puzzle/widgets/util/purchase_container.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide AboutDialog;
import 'package:flutter/services.dart';

Widget createSettingsBottomSheet(
  BuildContext context, {
  required void Function(int) onGridSizeSelected,
}) {
  final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
  final colorScheme = Theme.of(context).colorScheme;
  final ui = ConfigUiContainer.of(context);
  final l10n = AppLocalizations.of(context)!;

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
              label: l10n.gridSizeSemanticsLabel('$size'),
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
            l10n.gridSizeLabel('$size'),
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
      borderRadius:
          const BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
    ),
    // A Material ancestor so the ListTiles below (About, Remove Ads,
    // Restore Purchases, ...) paint ink splashes correctly instead of being
    // masked by this Container's own BoxDecoration. Scrollable because the
    // sheet's content can exceed the viewport on smaller screens.
    child: Material(
      type: MaterialType.transparency,
      child: SingleChildScrollView(
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
              l10n.settingsTitle,
              style: AppTypography.dialogTitle(context),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.settingsSubtitle,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.xl),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.gridSizeSectionHeader,
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
              label: l10n.darkModeLabel,
              value: ui?.useDarkTheme ?? false,
              onChanged: (value) {
                HapticFeedback.selectionClick();
                ui?.setUseDarkTheme(value, save: true);
              },
            ),
            _SettingsToggle(
              icon: Icons.bolt_rounded,
              label: l10n.speedRunModeLabel,
              subtitle: l10n.speedRunModeSubtitle,
              value: ui?.isSpeedRunModeEnabled ?? false,
              onChanged: (value) {
                HapticFeedback.selectionClick();
                ui?.setSpeedRunModeEnabled(value, save: true);
              },
            ),
            _SettingsToggle(
              icon: Icons.volume_up_rounded,
              label: l10n.soundEffectsLabel,
              value: ui?.isSoundEnabled ?? true,
              onChanged: (value) {
                HapticFeedback.selectionClick();
                ui?.setSoundEnabled(value, save: true);
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            const _RemoveAdsSection(),
            const SizedBox(height: AppSpacing.sm),
            const _ThemesSection(),
            const SizedBox(height: AppSpacing.sm),
            Semantics(
              button: true,
              label: l10n.aboutTitle,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.info_outline_rounded,
                    color: colorScheme.primary),
                title: Text(l10n.aboutTitle,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
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
      ),
    ),
  );

  if (isIOS) {
    content = ClipRRect(
      borderRadius:
          const BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
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
          ? Text(subtitle!,
              style: TextStyle(color: colorScheme.onSurfaceVariant))
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

/// Remove Ads purchase, Restore Purchases, and (debug builds only) a Reset
/// IAP control. Hidden entirely on platforms other than iOS.
class _RemoveAdsSection extends StatelessWidget {
  const _RemoveAdsSection();

  @override
  Widget build(BuildContext context) {
    final purchase = PurchaseContainer.of(context);
    if (purchase == null || !purchase.isSupported) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isAdsRemoved = purchase.isAdsRemoved;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isAdsRemoved)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading:
                Icon(Icons.check_circle_rounded, color: colorScheme.primary),
            title: Text(l10n.adsRemovedTitle,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(l10n.adsRemovedSubtitle),
          )
        else
          Semantics(
            button: true,
            label: l10n.removeAdsTitle,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.block_rounded, color: colorScheme.primary),
              title: Text(l10n.removeAdsTitle,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(l10n.removeAdsSubtitle),
              trailing: _RemoveAdsPrice(purchase: purchase),
              onTap: purchase.isPurchasePending
                  ? null
                  : () {
                      HapticFeedback.selectionClick();
                      purchase.buyRemoveAds();
                    },
            ),
          ),
        Semantics(
          button: true,
          label: l10n.restorePurchasesTitle,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.restore_rounded, color: colorScheme.primary),
            title: Text(l10n.restorePurchasesTitle,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            onTap: () {
              HapticFeedback.selectionClick();
              purchase.restorePurchases();
            },
          ),
        ),
        if (kDebugMode) _DebugResetIapTile(purchase: purchase),
      ],
    );
  }
}

class _RemoveAdsPrice extends StatelessWidget {
  final PurchaseContainerState purchase;

  const _RemoveAdsPrice({required this.purchase});

  @override
  Widget build(BuildContext context) {
    if (purchase.isPurchasePending || purchase.isLoadingProduct) {
      return const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    final product = purchase.removeAdsProduct;
    if (product == null) {
      return Text(
        AppLocalizations.of(context)!.unavailableLabel,
        style: TextStyle(color: Theme.of(context).colorScheme.outline),
      );
    }

    return Text(product.price,
        style: const TextStyle(fontWeight: FontWeight.w700));
  }
}

/// Debug-only: clears the locally persisted entitlement so ads behave as if
/// never purchased. Compiled out of release builds entirely via [kDebugMode].
class _DebugResetIapTile extends StatelessWidget {
  final PurchaseContainerState purchase;

  const _DebugResetIapTile({required this.purchase});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.bug_report_rounded, color: Colors.red),
      title: const Text(
        'Reset IAP (Debug)',
        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red),
      ),
      onTap: () => _confirmReset(context),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset IAP (Debug)'),
        content: const Text(
          'This clears the locally cached entitlements (Remove Ads and Theme '
          "Pack) and re-enables ads/re-locks themes. It can't revoke your "
          'real App Store purchases — tapping Restore Purchases afterwards '
          'will legitimately restore them.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              purchase.resetForDebug();
            },
            child: const Text('RESET'),
          ),
        ],
      ),
    );
  }
}

/// Tile palette swatches, an "Unlock Themes" purchase row when not owned,
/// and a "Photo Mode" picker when owned. Unlike [_RemoveAdsSection], this
/// section is never hidden: on platforms where [PurchaseContainerState.
/// isThemePackOwned] is unconditionally `true` (Android — there's no way to
/// charge for it), it renders directly in the owned state.
class _ThemesSection extends StatelessWidget {
  const _ThemesSection();

  @override
  Widget build(BuildContext context) {
    final purchase = PurchaseContainer.of(context);
    final ui = ConfigUiContainer.of(context);
    if (purchase == null || ui == null) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isOwned = purchase.isThemePackOwned;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(l10n.themesSectionHeader,
              style: AppTypography.sectionHeader(context)),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: TileTheme.all
              .map(
                (theme) => _ThemeSwatch(
                  theme: theme,
                  displayName: themeDisplayName(l10n, theme.id),
                  isLocked: !isOwned && theme.id != TileThemeId.classic,
                  isSelected: !ui.isPhotoModeEnabled &&
                      ui.selectedTileThemeId == theme.id,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    ui.setSelectedTileTheme(theme.id, save: true);
                  },
                ),
              )
              .toList(),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (!isOwned)
          Semantics(
            button: true,
            label: l10n.unlockThemesTitle,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading:
                  Icon(Icons.palette_rounded, color: colorScheme.primary),
              title: Text(l10n.unlockThemesTitle,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(l10n.unlockThemesSubtitle),
              trailing: _ThemePackPrice(purchase: purchase),
              onTap: purchase.isPurchasePending
                  ? null
                  : () {
                      HapticFeedback.selectionClick();
                      purchase.buyThemePack();
                    },
            ),
          )
        else
          Semantics(
            button: true,
            label: l10n.photoModeTitle,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                ui.isPhotoModeEnabled
                    ? Icons.check_circle_rounded
                    : Icons.image_rounded,
                color: colorScheme.primary,
              ),
              title: Text(l10n.photoModeTitle,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(l10n.photoModeSubtitle),
              trailing: Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.outline,
              ),
              onTap: () async {
                HapticFeedback.selectionClick();
                final filename = await PhotoThemeManager.pickAndSavePhoto();
                if (filename == null || !context.mounted) return;
                ui.setPhotoMode(true, filename: filename, save: true);
              },
            ),
          ),
      ],
    );
  }
}

/// Looks up the localized display name for a tile palette. Kept separate
/// from [TileTheme] itself since that model has no [BuildContext]/l10n
/// access.
String themeDisplayName(AppLocalizations l10n, TileThemeId id) {
  switch (id) {
    case TileThemeId.classic:
      return l10n.themeNameClassic;
    case TileThemeId.midnight:
      return l10n.themeNameMidnight;
    case TileThemeId.sunset:
      return l10n.themeNameSunset;
    case TileThemeId.mint:
      return l10n.themeNameMint;
  }
}

class _ThemeSwatch extends StatelessWidget {
  final TileTheme theme;
  final String displayName;
  final bool isLocked;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeSwatch({
    required this.theme,
    required this.displayName,
    required this.isLocked,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      button: true,
      selected: isSelected,
      label: isLocked
          ? l10n.themeSwatchLockedLabel(displayName)
          : l10n.themeSwatchLabel(displayName),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.sm),
        onTap: isLocked ? null : onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: theme.backgroundColor,
                borderRadius: BorderRadius.circular(AppRadii.sm),
                border: isSelected
                    ? Border.all(color: colorScheme.primary, width: 3)
                    : null,
              ),
              alignment: Alignment.center,
              child: isLocked
                  ? Icon(Icons.lock_rounded, color: theme.textColor, size: 20)
                  : Text(
                      '15',
                      style: TextStyle(
                        color: theme.textColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(displayName, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

class _ThemePackPrice extends StatelessWidget {
  final PurchaseContainerState purchase;

  const _ThemePackPrice({required this.purchase});

  @override
  Widget build(BuildContext context) {
    if (purchase.isPurchasePending || purchase.isLoadingProduct) {
      return const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    final product = purchase.themePackProduct;
    if (product == null) {
      return Text(
        AppLocalizations.of(context)!.unavailableLabel,
        style: TextStyle(color: Theme.of(context).colorScheme.outline),
      );
    }

    return Text(product.price,
        style: const TextStyle(fontWeight: FontWeight.w700));
  }
}
