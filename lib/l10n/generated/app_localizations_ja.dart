// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'クラシック15パズル';

  @override
  String get close => '閉じる';

  @override
  String get aboutTitle => 'このアプリについて';

  @override
  String get aboutDescription1 =>
      'クラシック15パズルは、美しいアニメーション、触覚フィードバック、洗練されたインターフェースを備えた、プレミアムなオープンソースのパズル体験です。';

  @override
  String get aboutDescription2 => '友達とオンラインで競い合い、ベストタイムを記録しましょう。';

  @override
  String get aboutJoinDevelopment => '開発に参加する';

  @override
  String get aboutSendBugReport => '不具合を報告する';

  @override
  String aboutVersion(String version, String buildNumber) {
    return 'バージョン $version ($buildNumber)';
  }

  @override
  String tileLabel(String number) {
    return 'タイル $number';
  }

  @override
  String get emptyTileLabel => '空きマス';

  @override
  String get hallOfFameTitle => '殿堂';

  @override
  String gridSizeLabel(String size) {
    return '${size}x$size';
  }

  @override
  String gridSizeSemanticsLabel(String size) {
    return '${size}x$size グリッド';
  }

  @override
  String gridSizeSelectedSemanticsLabel(String size) {
    return '${size}x$size グリッド、選択中';
  }

  @override
  String get noGamesYet => 'まだ記録がありません';

  @override
  String get solveToSeeRecords => 'パズルを解くとここに記録が表示されます';

  @override
  String get bestTimeLabel => 'ベストタイム';

  @override
  String get minMovesLabel => '最少手数';

  @override
  String get noDataPlaceholder => '--';

  @override
  String get recentLogLabel => '最近の記録';

  @override
  String recentLogTimestamp(
      String day, String month, String hour, String minute) {
    return '$day/$month $hour:$minute';
  }

  @override
  String movesCount(String steps) {
    return '$steps 手';
  }

  @override
  String get photoLoadFailedMessage => '保存された写真を読み込めませんでした。クラシックテーマに戻しました。';

  @override
  String get productNameRemoveAds => '広告を削除';

  @override
  String get productNameGeneric => 'その購入';

  @override
  String get storeUnavailableMessage =>
      'App Storeは現在利用できません。しばらくしてからもう一度お試しください。';

  @override
  String productUnavailableMessage(String productName) {
    return '$productNameは現在ご利用いただけません。しばらくしてからもう一度お試しください。';
  }

  @override
  String get purchasePendingMessage => '購入は承認待ちです。';

  @override
  String get purchaseCancelledMessage => '購入がキャンセルされました。';

  @override
  String get purchaseFailedMessage => '購入に失敗しました。もう一度お試しください。';

  @override
  String get removeAdsPurchaseSuccessMessage => '広告が削除されました。ご支援ありがとうございます！';

  @override
  String get rewardedAdUnavailableMessage =>
      '広告は現在利用できません。しばらくしてからもう一度お試しください。';

  @override
  String get rewardedAdDismissedMessage => 'テーマと写真モードを解除するには、広告を最後まで視聴してください。';

  @override
  String get themesUnlockedMessage => 'テーマと写真モードのロックが解除されました。お楽しみください！';

  @override
  String alreadyOwnedMessage(String productName) {
    return '$productNameはすでに購入済みです。';
  }

  @override
  String restoreSuccessMessage(String productName) {
    return '$productNameを復元しました。';
  }

  @override
  String get restoreEmptyMessage => '復元できる購入履歴が見つかりませんでした。';

  @override
  String get restoreFailedMessage => '復元に失敗しました。もう一度お試しください。';

  @override
  String get gameAppBarTitle => 'クラシック15';

  @override
  String get settingsTitle => '設定';

  @override
  String get timeLabel => 'タイム';

  @override
  String get movesLabel => '手数';

  @override
  String get hintTooltip => 'ヒント';

  @override
  String get pauseTooltip => '一時停止';

  @override
  String get resumeTooltip => '再開';

  @override
  String get pausedTapToResumeLabel => '一時停止中 — タップして再開';

  @override
  String get newGameTooltip => '新しいゲーム';

  @override
  String get settingsSubtitle => 'パズル体験をカスタマイズ';

  @override
  String get gridSizeSectionHeader => 'グリッドサイズ';

  @override
  String get darkModeLabel => 'ダークモード';

  @override
  String get speedRunModeLabel => 'スピードランモード';

  @override
  String get speedRunModeSubtitle => 'アニメーションが速くなり、タップのみで操作します';

  @override
  String get speedRunModeInfoTooltip => 'スピードランモードについて';

  @override
  String get speedRunModeExplanation =>
      'スピードランモードでは、どのタイルをタップしても空きマスの方向へスライドします。空きマスに隣接するタイルだけをタップする必要はありません。アニメーションも高速化されるので、できるだけ早くパズルを解くことができます。';

  @override
  String get soundEffectsLabel => '効果音';

  @override
  String get adsRemovedTitle => '広告が削除されました';

  @override
  String get adsRemovedSubtitle => 'アプリを応援していただきありがとうございます！';

  @override
  String get removeAdsTitle => '広告を削除';

  @override
  String get removeAdsSubtitle => 'このアプリから広告を完全に削除します。';

  @override
  String get restorePurchasesTitle => '購入を復元';

  @override
  String get unavailableLabel => '利用不可';

  @override
  String get themesSectionHeader => 'テーマ';

  @override
  String get unlockThemesTitle => 'テーマのロックを解除';

  @override
  String get unlockThemesSubtitle => '追加のタイルテーマ＋写真パズルモード。';

  @override
  String get photoModeTitle => '写真モード';

  @override
  String get photoModeSubtitle => '写真をパズルにしましょう。';

  @override
  String themeSwatchLabel(String themeName) {
    return '$themeNameテーマ';
  }

  @override
  String themeSwatchLockedLabel(String themeName) {
    return '$themeNameテーマ（ロック中）';
  }

  @override
  String get themeNameClassic => 'クラシック';

  @override
  String get themeNameMidnight => 'ミッドナイト';

  @override
  String get themeNameSunset => 'サンセット';

  @override
  String get themeNameMint => 'ミント';

  @override
  String get tutorialStep1Title => 'スライドして解こう';

  @override
  String get tutorialStep1Description =>
      '空きマスの隣にあるタイルをタップしてスライドさせます。すべてのタイルを順番に並べればクリアです。';

  @override
  String get tutorialStep2Title => '行き詰まったらヒントを';

  @override
  String get tutorialStep2Description => 'ヒントボタンをタップすると、いつでも次の最適な一手を確認できます。';

  @override
  String get tutorialStep3Title => '自分好みにカスタマイズ';

  @override
  String get tutorialStep3Description => '設定を開いて、グリッドサイズ、テーマ、サウンドなどを変更できます。';

  @override
  String get skipButton => 'スキップ';

  @override
  String get nextButton => '次へ';

  @override
  String get getStartedButton => 'はじめる';

  @override
  String get shareButton => 'シェア';

  @override
  String shareText(String size, String time, String steps) {
    return 'クラシック15パズル ${size}x$size を$time、$steps手でクリアしました！';
  }

  @override
  String get rankingsButton => 'ランキング';

  @override
  String get victoryTitle => '見事です！';

  @override
  String victoryDescription(String size) {
    return '${size}x$sizeのパズルを記録的な速さでクリアしました。';
  }

  @override
  String get advertisementLabel => '広告';
}
