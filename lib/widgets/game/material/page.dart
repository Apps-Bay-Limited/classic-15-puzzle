import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:classic_15_puzzle/config/ui.dart';
import 'package:classic_15_puzzle/theme/app_radii.dart';
import 'package:classic_15_puzzle/theme/app_spacing.dart';
import 'package:classic_15_puzzle/theme/app_typography.dart';
import 'package:classic_15_puzzle/widgets/game/material/sheets.dart';
import 'package:classic_15_puzzle/widgets/game/board.dart';
import 'package:classic_15_puzzle/widgets/shared/ad_banner_slot.dart';
import 'package:classic_15_puzzle/widgets/shared/action_button.dart';
import 'package:classic_15_puzzle/widgets/shared/live_timer_text.dart';
import 'package:classic_15_puzzle/widgets/shared/stat_card.dart';
import 'package:classic_15_puzzle/widgets/game/hall_of_fame.dart';
import 'package:classic_15_puzzle/widgets/game/presenter/main.dart';
import 'package:classic_15_puzzle/widgets/util/ads_manager.dart';
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
  StreamSubscription<PurchaseFeedback>? _purchaseFeedbackSubscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final purchase = PurchaseContainer.of(context);
    final isAdsRemoved = purchase?.isAdsRemoved ?? false;

    _purchaseFeedbackSubscription ??=
        purchase?.feedback.listen(_showPurchaseFeedback);

    if (_lastKnownAdsRemoved == isAdsRemoved) return;
    _lastKnownAdsRemoved = isAdsRemoved;
    _isAdsRemoved = isAdsRemoved;

    if (isAdsRemoved) {
      _disposeAds();
    } else {
      _initAds();
    }
  }

  void _showPurchaseFeedback(PurchaseFeedback feedback) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(_purchaseFeedbackMessage(feedback))));
  }

  String _purchaseFeedbackMessage(PurchaseFeedback feedback) {
    switch (feedback) {
      case PurchaseFeedback.storeUnavailable:
        return 'The App Store is unavailable right now. Please try again later.';
      case PurchaseFeedback.productUnavailable:
        return 'Remove Ads is not available right now. Please try again later.';
      case PurchaseFeedback.purchasePending:
        return 'Your purchase is pending approval.';
      case PurchaseFeedback.purchaseCancelled:
        return 'Purchase cancelled.';
      case PurchaseFeedback.purchaseFailed:
        return 'Purchase failed. Please try again.';
      case PurchaseFeedback.purchaseSuccess:
        return 'Ads removed. Thank you for your support!';
      case PurchaseFeedback.alreadyOwned:
        return 'You already own Remove Ads.';
      case PurchaseFeedback.restoreSuccess:
        return 'Purchase restored. Ads removed.';
      case PurchaseFeedback.restoreEmpty:
        return 'No previous purchase found to restore.';
      case PurchaseFeedback.restoreFailed:
        return 'Restore failed. Please try again.';
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
        Future.delayed(const Duration(seconds: 1), () {
          presenter.play();
        });
      });
      _firstTime = false;
    }

    final appBar = AppBar(
      title: Text('Classic 15', style: AppTypography.appBarTitle(context)),
      elevation: 0,
      centerTitle: isIOS,
      backgroundColor:
          isIOS ? Colors.transparent : Theme.of(context).colorScheme.surface,
      flexibleSpace: isIOS
          ? ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.transparent),
              ),
            )
          : null,
      actions: [
        Tooltip(
          message: 'Hall of Fame',
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
          message: 'Settings',
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
                          label: 'TIME',
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
                          label: 'MOVES',
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
                        tooltip: 'Hint',
                        isLoading: presenter.isSolving,
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          presenter.hint();
                        },
                      ),
                      const SizedBox(width: AppSpacing.md),
                      GameActionButton(
                        icon: Icons.refresh_rounded,
                        tooltip: 'New game',
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
                onTap: (point) => presenter.tap(point: point),
              ),
            );
          },
        ),
      ),
    );
  }
}
