import 'dart:math';

import 'package:classic_15_puzzle/config/ui.dart';
import 'package:classic_15_puzzle/widgets/game/board.dart';
import 'package:classic_15_puzzle/widgets/game/material/sheets.dart';
import 'package:classic_15_puzzle/widgets/game/presenter/main.dart';
import 'package:classic_15_puzzle/widgets/util/ads_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

bool firstTime = true;

class GameMaterialPage extends StatefulWidget {
  const GameMaterialPage({Key key}) : super(key: key);

  static const kMaxBoardSize = 600.0;

  static const kBoardMargin = 16.0;

  static const kBoardPadding = 8.0;

  @override
  _GameMaterialPageState createState() => _GameMaterialPageState();
}

class _GameMaterialPageState extends State<GameMaterialPage> {
  final FocusNode _boardFocus = FocusNode();

  BannerAd _ad;

  bool _isAdLoaded = false;

  @override
  void initState() {
    _ad = BannerAd(
      adUnitId: AdsManager.bannerAdUnitId,
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          // Releases an ad resource when it fails to load
          ad.dispose();

          print('Ad load failed (code=${error.code} message=${error.message})');
        },
      ),
    );

    _ad.load();

    AppOpenAdManager appOpenAdManager = AppOpenAdManager()..loadAd();
    WidgetsBinding.instance.addObserver(AppLifecycleReactor(appOpenAdManager: appOpenAdManager));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final presenter = GamePresenterWidget.of(context);

    final boardWidget = _buildBoard(context);

    if (firstTime) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(Duration(seconds: 1), () {
          presenter.play();
        });
      });
    }
    firstTime = false;

    return Scaffold(
      appBar: AppBar(
        title: Text("Classic 15 Puzzle"),
        backgroundColor: Color(0xffA2907D),
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (BuildContext context) {
                  return createMoreBottomSheet(context, call: (size) {
                    presenter.resize(size);
                    presenter.play();
                  });
                },
              );
            },
            icon: Icon(
              Icons.settings_rounded,
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
                margin: EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                          color: Color(0xffA2907D),
                          borderRadius: BorderRadius.all(Radius.circular(18))),
                      child: Container(
                        width: 180.0,
                        height: 80.0,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "Moves",
                                style: TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Text(
                                presenter.steps.toString(),
                                style: TextStyle(
                                  fontSize: 21.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: ElevatedButton(
                        onPressed: () {
                          presenter.play();
                        },
                        child: Icon(
                          Icons.refresh_rounded,
                          size: 36,
                        ),
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Color(0xffA2907D)),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)))),
                      ),
                    )
                  ],
                )),
            Container(
              height: 20.0,
            ),
            boardWidget,
            Spacer(),
            if (_isAdLoaded)
              Container(
                margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: AdWidget(ad: _ad),
                height: 50.0,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoard(final BuildContext context) {
    final presenter = GamePresenterWidget.of(context);
    final config = ConfigUiContainer.of(context);
    final background = Color(0xffA2907D);
    return Center(
      child: Container(
        margin: EdgeInsets.all(GameMaterialPage.kBoardMargin),
        padding: EdgeInsets.all(GameMaterialPage.kBoardPadding),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final puzzleSize = min(
              min(
                constraints.maxWidth,
                constraints.maxHeight,
              ),
              GameMaterialPage.kMaxBoardSize -
                  (GameMaterialPage.kBoardMargin + GameMaterialPage.kBoardPadding) * 2,
            );

            return RawKeyboardListener(
              autofocus: true,
              focusNode: _boardFocus,
              onKey: (event) {
                if (!(event is RawKeyDownEvent)) {
                  return;
                }

                int offsetY = 0;
                int offsetX = 0;
                switch (event.logicalKey.keyId) {
                  case 0x100070052: // arrow up
                    offsetY = 1;
                    break;
                  case 0x100070050: // arrow left
                    offsetX = 1;
                    break;
                  case 0x10007004f: // arrow right
                    offsetX = -1;
                    break;
                  case 0x100070051: // arrow down
                    offsetY = -1;
                    break;
                  default:
                    return;
                }
                final tapPoint = presenter.board.blank + Point(offsetX, offsetY);
                if (tapPoint.x < 0 ||
                    tapPoint.x >= presenter.board.size ||
                    tapPoint.y < 0 ||
                    tapPoint.y >= presenter.board.size) {
                  return;
                }

                presenter.tap(point: tapPoint);
              },
              child: BoardWidget(
                isSpeedRunModeEnabled: config.isSpeedRunModeEnabled,
                board: presenter.board,
                size: puzzleSize,
                onTap: (point) {
                  presenter.tap(point: point);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
