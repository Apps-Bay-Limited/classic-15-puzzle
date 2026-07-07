import 'dart:math';
import 'dart:ui';

import 'package:classic_15_puzzle/config/ui.dart';
import 'package:classic_15_puzzle/widgets/game/board.dart';
import 'package:classic_15_puzzle/widgets/game/material/sheets.dart';
import 'package:classic_15_puzzle/widgets/game/presenter/main.dart';
import 'package:classic_15_puzzle/widgets/util/ads_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class GameMaterialPage extends StatefulWidget {
  const GameMaterialPage({super.key});

  static const kMaxBoardSize = 600.0;
  static const kBoardMargin = 24.0;
  static const kBoardPadding = 12.0;

  @override
  GameMaterialPageState createState() => GameMaterialPageState();
}

class GameMaterialPageState extends State<GameMaterialPage> {
  final FocusNode _boardFocus = FocusNode();
  BannerAd? _ad;
  bool _isAdLoaded = false;
  bool _firstTime = true;

  @override
  void initState() {
    super.initState();
    _ad = BannerAd(
      adUnitId: AdsManager.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Ad load failed (code=${error.code} message=${error.message})');
        },
      ),
    );

    _ad?.load();

    AppOpenAdManager appOpenAdManager = AppOpenAdManager()..loadAd();
    WidgetsBinding.instance.addObserver(AppLifecycleReactor(appOpenAdManager: appOpenAdManager));
  }

  @override
  void dispose() {
    _ad?.dispose();
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
      title: const Text(
        "Classic 15",
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
      elevation: 0,
      centerTitle: isIOS,
      backgroundColor: isIOS ? Colors.transparent : Theme.of(context).colorScheme.surface,
      flexibleSpace: isIOS
          ? ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.transparent),
              ),
            )
          : null,
      actions: [
        IconButton(
          onPressed: () {
            HapticFeedback.selectionClick();
            showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (BuildContext context) => createMoreBottomSheet(context, call: (size) {
                presenter.resize(size);
                presenter.play();
              }),
            );
          },
          icon: const Icon(Icons.tune_rounded),
        )
      ],
    );

    return Scaffold(
      extendBodyBehindAppBar: isIOS,
      appBar: appBar,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: _StatCard(
                      label: "MOVES",
                      value: presenter.steps.toString(),
                      icon: Icons.numbers_rounded,
                    ),
                  ),
                  const SizedBox(width: 16),
                  _ActionButton(
                    icon: Icons.refresh_rounded,
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      presenter.play();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(child: boardWidget),
            const SizedBox(height: 16),
            // Dedicated Ad Space
            Container(
              height: 60,
              width: double.infinity,
              alignment: Alignment.center,
              child: _isAdLoaded && _ad != null
                  ? AdWidget(ad: _ad!)
                  : Text(
                      "ADVERTISEMENT",
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                          ),
                    ),
            ),
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
        margin: const EdgeInsets.all(GameMaterialPage.kBoardMargin),
        padding: const EdgeInsets.all(GameMaterialPage.kBoardPadding),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(24.0),
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
              GameMaterialPage.kMaxBoardSize - (GameMaterialPage.kBoardMargin + GameMaterialPage.kBoardPadding) * 2,
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
                if (tapPoint.x >= 0 && tapPoint.x < presenter.board.size &&
                    tapPoint.y >= 0 && tapPoint.y < presenter.board.size) {
                  presenter.tap(point: tapPoint);
                }
              },
              child: BoardWidget(
                isSpeedRunModeEnabled: config?.isSpeedRunModeEnabled ?? false,
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

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isIOS ? colorScheme.surfaceContainer.withValues(alpha: 0.5) : colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: isIOS ? Border.all(color: Colors.white.withValues(alpha: 0.1)) : null,
      ),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: colorScheme.outline,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ActionButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return IconButton.filledTonal(
      onPressed: onPressed,
      icon: Icon(icon, size: 28),
      padding: const EdgeInsets.all(16),
      style: IconButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
