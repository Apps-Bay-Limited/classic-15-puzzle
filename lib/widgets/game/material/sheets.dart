import 'dart:math';

import 'package:classic_15_puzzle/config/ui.dart';
import 'package:classic_15_puzzle/data/board.dart';
import 'package:classic_15_puzzle/l10n/generated/app_localizations.dart';
import 'package:classic_15_puzzle/theme/app_radii.dart';
import 'package:classic_15_puzzle/theme/app_spacing.dart';
import 'package:classic_15_puzzle/theme/app_typography.dart';
import 'package:classic_15_puzzle/theme/tile_theme.dart';
import 'package:classic_15_puzzle/widgets/game/board.dart';
import 'package:classic_15_puzzle/widgets/util/photo_theme_manager.dart';
import 'package:classic_15_puzzle/widgets/util/purchase_container.dart';
import 'package:classic_15_puzzle/widgets/util/theme_unlock_container.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Full-page settings screen, pushed onto the navigator so it gets a real
/// back button (a navigation stack) and its title sits below the status bar
/// in an AppBar. Tapping a grid size applies it and pops back to the game.
class SettingsPage extends StatelessWidget {
  final int currentGridSize;
  final void Function(int) onGridSizeSelected;

  const SettingsPage({
    super.key,
    required this.currentGridSize,
    required this.onGridSizeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ui = ConfigUiContainer.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget createBoard({required int size}) {
      final isSelected = size == currentGridSize;

      return Column(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.all(AppSpacing.xs),
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppRadii.sm),
              border: isSelected
                  ? Border.all(color: colorScheme.primary, width: 3)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Semantics(
              label: isSelected
                  ? l10n.gridSizeSelectedSemanticsLabel('$size')
                  : l10n.gridSizeSemanticsLabel('$size'),
              button: true,
              selected: isSelected,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadii.xs),
                onTap: () {
                  HapticFeedback.mediumImpact();
                  onGridSizeSelected(size);
                  Navigator.of(context).pop();
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
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
                    if (isSelected)
                      Positioned(
                        top: -6,
                        right: -6,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorScheme.surfaceContainerHigh,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            size: 12,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            l10n.gridSizeLabel('$size'),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w800,
                  color: isSelected ? colorScheme.primary : null,
                ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.settingsTitle,
          style: AppTypography.appBarTitle(context),
        ),
        // Set explicitly for the same reason the game page's AppBar does — so
        // the status bar icons contrast correctly and don't go stale after a
        // light/dark switch.
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),
      // Scaffold already provides a Material ancestor, so the ListTiles below
      // (Remove Ads, Restore Purchases, ...) paint ink splashes correctly.
      // SafeArea'd bottom-only (the AppBar already handles the top) so the
      // last row isn't obscured by the home indicator/gesture nav bar.
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
                infoTooltip: l10n.speedRunModeInfoTooltip,
                onInfoTap: () {
                  HapticFeedback.selectionClick();
                  showDialog<void>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(l10n.speedRunModeLabel),
                      content: Text(l10n.speedRunModeExplanation),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(l10n.close),
                        ),
                      ],
                    ),
                  );
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
              const _PrivacyOptionsRow(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsToggle extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  /// When set, shows a small "?" button next to [label] that calls this
  /// instead of toggling the switch — for settings whose mechanics need
  /// more than a one-line subtitle to explain.
  final VoidCallback? onInfoTap;
  final String? infoTooltip;

  const _SettingsToggle({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.onInfoTap,
    this.infoTooltip,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      secondary: Icon(icon, color: colorScheme.primary),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          if (onInfoTap != null) ...[
            const SizedBox(width: AppSpacing.xxs),
            Tooltip(
              message: infoTooltip ?? '',
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadii.xs),
                onTap: onInfoTap,
                child: Icon(
                  Icons.help_outline_rounded,
                  size: 16,
                  color: colorScheme.outline,
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: subtitle != null
          ? Text(subtitle!,
              style: TextStyle(color: colorScheme.onSurfaceVariant))
          : null,
      value: value,
      onChanged: onChanged,
    );
  }
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

/// Reopens the UMP ad-consent choices form. Only shown when the SDK reports
/// a privacy-options entry point is actually required (e.g. the user is in
/// the EEA/UK and has previously made a consent choice) — required by
/// Google's Consent Management Platform policy.
class _PrivacyOptionsRow extends StatefulWidget {
  const _PrivacyOptionsRow();

  @override
  State<_PrivacyOptionsRow> createState() => _PrivacyOptionsRowState();
}

class _PrivacyOptionsRowState extends State<_PrivacyOptionsRow> {
  bool _isRequired = false;

  @override
  void initState() {
    super.initState();
    ConsentInformation.instance.getPrivacyOptionsRequirementStatus().then((status) {
      if (mounted) {
        setState(() {
          _isRequired = status == PrivacyOptionsRequirementStatus.required;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isRequired) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Semantics(
      button: true,
      label: l10n.privacyOptionsTitle,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.privacy_tip_rounded, color: colorScheme.primary),
        title: Text(l10n.privacyOptionsTitle,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () {
          HapticFeedback.selectionClick();
          ConsentForm.showPrivacyOptionsForm((FormError? formError) {});
        },
      ),
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
        'Reset Remove Ads (Debug)',
        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red),
      ),
      onTap: () => _confirmReset(context),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset Remove Ads (Debug)'),
        content: const Text(
          "This clears the locally cached Remove Ads entitlement and "
          "re-enables ads. It can't revoke your real App Store purchase — "
          'tapping Restore Purchases afterwards will legitimately restore '
          'it.',
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

/// Tile palette swatches, a "watch an ad to unlock" row when not unlocked,
/// and a "Photo Mode" picker once unlocked. Unlike [_RemoveAdsSection], this
/// section is never hidden — the unlock is a rewarded ad, available on both
/// platforms regardless of Remove Ads status.
class _ThemesSection extends StatelessWidget {
  const _ThemesSection();

  @override
  Widget build(BuildContext context) {
    final themeUnlock = ThemeUnlockContainer.of(context);
    final ui = ConfigUiContainer.of(context);
    if (themeUnlock == null || ui == null) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isUnlocked = themeUnlock.isUnlocked;

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
                  isLocked: !isUnlocked && theme.id != TileThemeId.classic,
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
        if (!isUnlocked)
          Semantics(
            button: true,
            label: l10n.unlockThemesTitle,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.palette_rounded, color: colorScheme.primary),
              title: Text(l10n.unlockThemesTitle,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(l10n.unlockThemesSubtitle),
              trailing: _WatchAdTrailing(themeUnlock: themeUnlock),
              onTap: themeUnlock.isShowingAd
                  ? null
                  : () {
                      HapticFeedback.selectionClick();
                      themeUnlock.watchAdToUnlock();
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
        if (kDebugMode) _DebugResetThemeUnlockTile(themeUnlock: themeUnlock),
      ],
    );
  }
}

/// Debug-only: clears the locally persisted theme unlock so the watch-ad
/// flow can be re-tested without reinstalling. Compiled out of release
/// builds entirely via [kDebugMode].
class _DebugResetThemeUnlockTile extends StatelessWidget {
  final ThemeUnlockContainerState themeUnlock;

  const _DebugResetThemeUnlockTile({required this.themeUnlock});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.bug_report_rounded, color: Colors.red),
      title: const Text(
        'Reset Theme Unlock (Debug)',
        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red),
      ),
      onTap: () => themeUnlock.resetForDebug(),
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
                color: theme.color,
                borderRadius: BorderRadius.circular(AppRadii.sm),
                border: isSelected
                    ? Border.all(color: colorScheme.primary, width: 3)
                    : null,
              ),
              alignment: Alignment.center,
              child: isLocked
                  ? const Icon(Icons.lock_rounded,
                      color: Colors.white, size: 20)
                  : const Text(
                      '15',
                      style: TextStyle(
                        color: Colors.white,
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

class _WatchAdTrailing extends StatelessWidget {
  final ThemeUnlockContainerState themeUnlock;

  const _WatchAdTrailing({required this.themeUnlock});

  @override
  Widget build(BuildContext context) {
    if (themeUnlock.isShowingAd) {
      return const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (!themeUnlock.isAdAvailable) {
      return Text(
        AppLocalizations.of(context)!.unavailableLabel,
        style: TextStyle(color: Theme.of(context).colorScheme.outline),
      );
    }

    return Icon(
      Icons.play_circle_fill_rounded,
      color: Theme.of(context).colorScheme.primary,
    );
  }
}
