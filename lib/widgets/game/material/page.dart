import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:classic_15_puzzle/config/ui.dart';
import 'package:classic_15_puzzle/l10n/generated/app_localizations.dart';
import 'package:classic_15_puzzle/theme/app_radii.dart';
import 'package:classic_15_puzzle/theme/app_spacing.dart';
import 'package:classic_15_puzzle/theme/app_typography.dart';
import 'package:classic_15_puzzle/theme/tile_theme.dart';
import 'package:classic_15_puzzle/widgets/game/material/sheets.dart';
import 'package:classic_15_puzzle/widgets/game/board.dart';
import 'package:classic_15_puzzle/widgets/shared/ad_banner_slot.dart';
import 'package:classic_15_puzzle/widgets/shared/action_button.dart';
import 'package:classic_15_puzzle/widgets/shared/live_timer_text.dart';
import 'package:classic_15_puzzle/widgets/shared/stat_card.dart';
import 'package:classic_15_puzzle/widgets/game/hall_of_fame.dart';
import 'package:classic_15_puzzle/widgets/game/presenter/main.dart';
import 'package:classic_15_puzzle/widgets/util/ads_manager.dart';
import 'package:classic_15_puzzle/widgets/onboarding/tutorial_dialog.dart';
import 'package:classic_15_puzzle/widgets/util/photo_theme_manager.dart';
import 'package:classic_15_puzzle/widgets/util/purchase_container.dart';
import 'package:classic_15_puzzle/widgets/util/purchase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class GameMaterialPage extends StatefulWidget {
  const GameMaterialPage({super.key});

  @override
  GameMaterialPageState createState() => GameMaterialPageState();
}

class GameMaterialPageState extends State<GameMaterialPage> {
  final FocusNode _boardFocus = FocusNode();
  BannerAd? _ad;
  bool _isAdLoaded = false;
  bool _adLoadFailed = false;
  bool _firstTime = true;

  bool? _lastKnownAdsRemoved;
  bool _isAdsRemoved = false;
  AppLifecycleReactor? _appLifecycleReactor;
  AppOpenAdManager? _appOpenAdManager;
  StreamSubscription<PurchaseFeedbackEvent>? _purchaseFeedbackSubscription;

  ui.Image? _photoImage;
  String? _decodedPhotoFilename;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final purchase = PurchaseContainer.of(context);
    final isAdsRemoved = purchase?.isAdsRemoved ?? false;

    _purchaseFeedbackSubscription ??=
        purchase?.feedback.listen(_showPurchaseFeedback);

    if (_lastKnownAdsRemoved != isAdsRemoved) {
      _lastKnownAdsRemoved = isAdsRemoved;
      _isAdsRemoved = isAdsRemoved;

      if (isAdsRemoved) {
        _disposeAds();
      } else {
        _initAds();
      }
    }

    final config = ConfigUiContainer.of(context);
    final isThemePackOwned = purchase?.isThemePackOwned ?? false;
    final wantsPhoto = isThemePackOwned && (config?.isPhotoModeEnabled ?? false);
    _ensurePhotoDecoded(wantsPhoto ? config?.photoFilename : null);
  }

  /// Decodes the saved photo-mode image once per distinct filename, so it
  /// isn't re-decoded on every rebuild. Falls back to Classic (with a
  /// one-shot message) if the saved file is missing or corrupt.
  void _ensurePhotoDecoded(String? filename) {
    if (filename == null) {
      if (_photoImage != null || _decodedPhotoFilename != null) {
        setState(() {
          _photoImage = null;
          _decodedPhotoFilename = null;
        });
      }
      return;
    }
    if (_decodedPhotoFilename == filename) return;
    _decodedPhotoFilename = filename;

    PhotoThemeManager.decodeSavedPhoto(filename).then((image) {
      if (!mounted || _decodedPhotoFilename != filename) return;
      if (image == null) {
        _decodedPhotoFilename = null;
        ConfigUiContainer.of(context)?.setPhotoMode(false, save: true);
        _showSnackBarMessage(
          AppLocalizations.of(context)!.photoLoadFailedMessage,
        );
        return;
      }
      setState(() {
        _photoImage = image;
      });
    });
  }

  void _showSnackBarMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _showPurchaseFeedback(PurchaseFeedbackEvent event) {
    if (!mounted) return;
    _showSnackBarMessage(_purchaseFeedbackMessage(event));
  }

  String _purchaseFeedbackMessage(PurchaseFeedbackEvent event) {
    final l10n = AppLocalizations.of(context)!;
    final productName = switch (event.product) {
      PurchaseProduct.removeAds => l10n.productNameRemoveAds,
      PurchaseProduct.themePack => l10n.productNameThemePack,
      null => l10n.productNameGeneric,
    };

    switch (event.type) {
      case PurchaseFeedback.storeUnavailable:
        return l10n.storeUnavailableMessage;
      case PurchaseFeedback.productUnavailable:
        return l10n.productUnavailableMessage(productName);
      case PurchaseFeedback.purchasePending:
        return l10n.purchasePendingMessage;
      case PurchaseFeedback.purchaseCancelled:
        return l10n.purchaseCancelledMessage;
      case PurchaseFeedback.purchaseFailed:
        return l10n.purchaseFailedMessage;
      case PurchaseFeedback.purchaseSuccess:
        return event.product == PurchaseProduct.themePack
            ? l10n.themePackPurchaseSuccessMessage
            : l10n.removeAdsPurchaseSuccessMessage;
      case PurchaseFeedback.alreadyOwned:
        return l10n.alreadyOwnedMessage(productName);
      case PurchaseFeedback.restoreSuccess:
        return l10n.restoreSuccessMessage(productName);
      case PurchaseFeedback.restoreEmpty:
        return l10n.restoreEmptyMessage;
      case PurchaseFeedback.restoreFailed:
        return l10n.restoreFailedMessage;
    }
  }

  void _initAds() {
    _ad = BannerAd(
      adUnitId: AdsManager.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
              _adLoadFailed = false;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Ad load failed (code=${error.code} message=${error.message})');
          if (mounted) {
            setState(() {
              _isAdLoaded = false;
              _adLoadFailed = true;
            });
          }
        },
      ),
    );

    _ad?.load();

    final appOpenAdManager = AppOpenAdManager()..loadAd();
    _appOpenAdManager = appOpenAdManager;
    final reactor = AppLifecycleReactor(
      appOpenAdManager: appOpenAdManager,
      isPurchaseInProgress: () =>
          PurchaseContainer.of(context)?.isPurchasePending ?? false,
    );
    _appLifecycleReactor = reactor;
    WidgetsBinding.instance.addObserver(reactor);
  }

  /// Disposes already-loaded ads immediately, e.g. when the entitlement
  /// activates mid-session (fresh purchase or store reconciliation).
  void _disposeAds() {
    if (_appLifecycleReactor != null) {
      WidgetsBinding.instance.removeObserver(_appLifecycleReactor!);
      _appLifecycleReactor = null;
    }
    _appOpenAdManager?.dispose();
    _appOpenAdManager = null;
    _ad?.dispose();
    _ad = null;
    _isAdLoaded = false;
    _adLoadFailed = false;
  }

  @override
  void dispose() {
    _purchaseFeedbackSubscription?.cancel();
    if (_appLifecycleReactor != null) {
      WidgetsBinding.instance.removeObserver(_appLifecycleReactor!);
    }
    _appOpenAdManager?.dispose();
    _ad?.dispose();
    _photoImage?.dispose();
    _boardFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final presenter = GamePresenterWidget.of(context);
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final boardWidget = _buildBoard(context);

    if (_firstTime) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleFirstFrame(presenter);
      });
      _firstTime = false;
    }

    return _buildScaffold(context, presenter, isIOS, boardWidget);
  }

  /// Shows the first-run tutorial once (persisted, not per-instance), then
  /// falls into the existing delayed auto-play behavior either way.
  Future<void> _handleFirstFrame(GamePresenterWidgetState presenter) async {
    final config = ConfigUiContainer.of(context);
    if (config != null && !config.hasSeenTutorial) {
      await showDialog<void>(
        context: context,
        builder: (context) => const TutorialDialog(),
      );
      if (mounted) {
        ConfigUiContainer.of(context)?.setHasSeenTutorial(true, save: true);
      }
    }

    if (!mounted) return;
    await Future<void>.delayed(const Duration(seconds: 1));
    if (mounted) {
      presenter.play();
    }
  }

  Widget _buildScaffold(
    BuildContext context,
    GamePresenterWidgetState presenter,
    bool isIOS,
    Widget boardWidget,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final appBar = AppBar(
      title:
          Text(l10n.gameAppBarTitle, style: AppTypography.appBarTitle(context)),
      elevation: 0,
      centerTitle: isIOS,
      backgroundColor:
          isIOS ? Colors.transparent : Theme.of(context).colorScheme.surface,
      flexibleSpace: isIOS
          ? ClipRect(
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.transparent),
              ),
            )
          : null,
      actions: [
        Tooltip(
          message: l10n.hallOfFameTitle,
          child: IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) =>
                    HallOfFameDialog(history: presenter.history),
              );
            },
            icon: const Icon(Icons.emoji_events_rounded),
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ),
        Tooltip(
          message: l10n.settingsTitle,
          child: IconButton(
            onPressed: () {
              HapticFeedback.selectionClick();
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (BuildContext context) => createSettingsBottomSheet(
                  context,
                  onGridSizeSelected: (size) {
                    presenter.resize(size);
                    presenter.play();
                  },
                ),
              );
            },
            icon: const Icon(Icons.tune_rounded),
          ),
        ),
      ],
    );

    return Scaffold(
      extendBodyBehindAppBar: isIOS,
      appBar: appBar,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: StatCard(
                          label: l10n.timeLabel,
                          icon: Icons.timer_rounded,
                          valueChild: LiveTimerText(
                            getElapsedMs: () => presenter.elapsedMs,
                            isRunning: presenter.isTimerTicking,
                            style: AppTypography.statValue(context),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: StatCard(
                          label: l10n.movesLabel,
                          value: presenter.steps.toString(),
                          icon: Icons.numbers_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      GameActionButton(
                        icon: Icons.lightbulb_outline_rounded,
                        tooltip: l10n.hintTooltip,
                        isLoading: presenter.isSolving,
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          presenter.hint();
                        },
                      ),
                      const SizedBox(width: AppSpacing.md),
                      GameActionButton(
                        icon: Icons.refresh_rounded,
                        tooltip: l10n.newGameTooltip,
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          presenter.play();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(child: boardWidget),
            if (!_isAdsRemoved) ...[
              const SizedBox(height: AppSpacing.md),
              AdBannerSlot(
                isLoaded: _isAdLoaded,
                hasFailed: _adLoadFailed,
                adWidget: _ad != null ? AdWidget(ad: _ad!) : null,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBoard(final BuildContext context) {
    final presenter = GamePresenterWidget.of(context);
    final config = ConfigUiContainer.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    final isThemePackOwned =
        PurchaseContainer.of(context)?.isThemePackOwned ?? false;
    final effectiveTheme = isThemePackOwned
        ? TileTheme.byId(config?.selectedTileThemeId ?? TileThemeId.classic)
        : TileTheme.classic;
    final isPhotoActive =
        isThemePackOwned && (config?.isPhotoModeEnabled ?? false);

    return Center(
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.boardMargin),
        padding: const EdgeInsets.all(AppSpacing.boardPadding),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final puzzleSize = min(
              min(constraints.maxWidth, constraints.maxHeight),
              AppSpacing.maxBoardSize -
                  (AppSpacing.boardMargin + AppSpacing.boardPadding) * 2,
            );

            return KeyboardListener(
              autofocus: true,
              focusNode: _boardFocus,
              onKeyEvent: (event) {
                if (event is! KeyDownEvent) return;
                int dy = 0, dx = 0;
                if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                  dy = 1;
                } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                  dy = -1;
                } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                  dx = 1;
                } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                  dx = -1;
                } else {
                  return;
                }

                final tapPoint = presenter.board.blank + Point(dx, dy);
                if (tapPoint.x >= 0 &&
                    tapPoint.x < presenter.board.size &&
                    tapPoint.y >= 0 &&
                    tapPoint.y < presenter.board.size) {
                  presenter.tap(point: tapPoint);
                }
              },
              child: BoardWidget(
                isSpeedRunModeEnabled:
                    config?.isSpeedRunModeEnabled ?? false,
                board: presenter.board,
                size: puzzleSize,
                theme: effectiveTheme,
                photoImage: isPhotoActive ? _photoImage : null,
                onTap: (point) => presenter.tap(point: point),
              ),
            );
          },
        ),
      ),
    );
  }
}
