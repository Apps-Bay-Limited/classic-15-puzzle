// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '经典15拼图';

  @override
  String get close => '关闭';

  @override
  String tileLabel(String number) {
    return '方块 $number';
  }

  @override
  String get emptyTileLabel => '空白格';

  @override
  String get hallOfFameTitle => '名人堂';

  @override
  String gridSizeLabel(String size) {
    return '${size}x$size';
  }

  @override
  String gridSizeSemanticsLabel(String size) {
    return '${size}x$size 网格';
  }

  @override
  String gridSizeSelectedSemanticsLabel(String size) {
    return '${size}x$size 网格，已选中';
  }

  @override
  String get noGamesYet => '暂无记录';

  @override
  String get solveToSeeRecords => '完成拼图后即可在此查看记录';

  @override
  String get bestTimeLabel => '最佳用时';

  @override
  String get minMovesLabel => '最少步数';

  @override
  String get noDataPlaceholder => '--';

  @override
  String get recentLogLabel => '最近记录';

  @override
  String recentLogTimestamp(
      String day, String month, String hour, String minute) {
    return '$day/$month $hour:$minute';
  }

  @override
  String movesCount(String steps) {
    return '$steps 步';
  }

  @override
  String get photoLoadFailedMessage => '无法加载已保存的照片，已切换回经典主题。';

  @override
  String get productNameRemoveAds => '移除广告';

  @override
  String get productNameGeneric => '该购买项目';

  @override
  String get storeUnavailableMessage => 'App Store 当前不可用，请稍后再试。';

  @override
  String productUnavailableMessage(String productName) {
    return '$productName 当前不可用，请稍后再试。';
  }

  @override
  String get purchasePendingMessage => '您的购买正在等待批准。';

  @override
  String get purchaseCancelledMessage => '购买已取消。';

  @override
  String get purchaseFailedMessage => '购买失败，请重试。';

  @override
  String get removeAdsPurchaseSuccessMessage => '广告已移除，感谢您的支持！';

  @override
  String get rewardedAdUnavailableMessage => '广告暂时不可用，请稍后再试。';

  @override
  String get rewardedAdDismissedMessage => '看完整个广告才能解锁主题和照片模式。';

  @override
  String get themesUnlockedMessage => '主题和照片模式已解锁，尽情体验吧！';

  @override
  String alreadyOwnedMessage(String productName) {
    return '您已拥有$productName。';
  }

  @override
  String restoreSuccessMessage(String productName) {
    return '$productName已恢复。';
  }

  @override
  String get restoreEmptyMessage => '未找到可恢复的购买记录。';

  @override
  String get restoreFailedMessage => '恢复失败，请重试。';

  @override
  String get gameAppBarTitle => '经典15';

  @override
  String get settingsTitle => '设置';

  @override
  String get timeLabel => '用时';

  @override
  String get movesLabel => '步数';

  @override
  String get hintTooltip => '提示';

  @override
  String get undoTooltip => '撤销';

  @override
  String get pauseTooltip => '暂停';

  @override
  String get resumeTooltip => '继续';

  @override
  String get pausedTapToResumeLabel => '已暂停——点击继续';

  @override
  String get newGameTooltip => '新游戏';

  @override
  String get settingsSubtitle => '自定义你的拼图体验';

  @override
  String get gridSizeSectionHeader => '网格大小';

  @override
  String get darkModeLabel => '深色模式';

  @override
  String get speedRunModeLabel => '竞速模式';

  @override
  String get speedRunModeSubtitle => '动画更快，仅支持点击移动';

  @override
  String get speedRunModeInfoTooltip => '关于竞速模式';

  @override
  String get speedRunModeExplanation =>
      '在竞速模式下，点击任意方块即可将其滑向空白格——不需要只点击紧邻空白格的方块。动画也会更快，让你尽可能快速地完成拼图。';

  @override
  String get soundEffectsLabel => '音效';

  @override
  String get adsRemovedTitle => '广告已移除';

  @override
  String get adsRemovedSubtitle => '感谢您对本应用的支持！';

  @override
  String get removeAdsTitle => '移除广告';

  @override
  String get removeAdsSubtitle => '永久移除本应用中的广告。';

  @override
  String get restorePurchasesTitle => '恢复购买';

  @override
  String get unavailableLabel => '不可用';

  @override
  String get themesSectionHeader => '主题';

  @override
  String get unlockThemesTitle => '解锁主题';

  @override
  String get unlockThemesSubtitle => '额外的拼图主题和照片拼图模式。';

  @override
  String get photoModeTitle => '照片模式';

  @override
  String get photoModeSubtitle => '将照片变成你的拼图。';

  @override
  String themeSwatchLabel(String themeName) {
    return '$themeName主题';
  }

  @override
  String themeSwatchLockedLabel(String themeName) {
    return '$themeName主题，已锁定';
  }

  @override
  String get themeNameClassic => '经典';

  @override
  String get themeNameMidnight => '午夜';

  @override
  String get themeNameSunset => '日落';

  @override
  String get themeNameMint => '薄荷';

  @override
  String get tutorialStep1Title => '滑动即可解谜';

  @override
  String get tutorialStep1Description => '点击空白格旁边的方块即可将其滑入空位。将所有方块按顺序排列即可获胜。';

  @override
  String get tutorialStep2Title => '卡住了？获取提示';

  @override
  String get tutorialStep2Description => '随时点击提示按钮，查看最佳下一步。';

  @override
  String get tutorialStep3Title => '打造专属于你的拼图';

  @override
  String get tutorialStep3Description => '在设置中更改网格大小、拼图主题、音效等。';

  @override
  String get skipButton => '跳过';

  @override
  String get nextButton => '下一步';

  @override
  String get getStartedButton => '开始体验';

  @override
  String get shareButton => '分享';

  @override
  String shareText(String size, String time, String steps) {
    return '我用$steps步、耗时$time完成了${size}x$size的经典15拼图！';
  }

  @override
  String get rankingsButton => '排行榜';

  @override
  String get victoryTitle => '太棒了！';

  @override
  String victoryDescription(String size) {
    return '你以破纪录的速度完成了${size}x$size拼图。';
  }

  @override
  String get advertisementLabel => '广告';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get appTitle => '經典15拼圖';

  @override
  String get close => '關閉';

  @override
  String tileLabel(String number) {
    return '方塊 $number';
  }

  @override
  String get emptyTileLabel => '空白格';

  @override
  String get hallOfFameTitle => '名人堂';

  @override
  String gridSizeLabel(String size) {
    return '${size}x$size';
  }

  @override
  String gridSizeSemanticsLabel(String size) {
    return '${size}x$size 網格';
  }

  @override
  String gridSizeSelectedSemanticsLabel(String size) {
    return '${size}x$size 網格，已選取';
  }

  @override
  String get noGamesYet => '尚無記錄';

  @override
  String get solveToSeeRecords => '完成拼圖後即可在此查看記錄';

  @override
  String get bestTimeLabel => '最佳用時';

  @override
  String get minMovesLabel => '最少步數';

  @override
  String get noDataPlaceholder => '--';

  @override
  String get recentLogLabel => '最近記錄';

  @override
  String recentLogTimestamp(
      String day, String month, String hour, String minute) {
    return '$day/$month $hour:$minute';
  }

  @override
  String movesCount(String steps) {
    return '$steps 步';
  }

  @override
  String get photoLoadFailedMessage => '無法載入已儲存的照片，已切換回經典主題。';

  @override
  String get productNameRemoveAds => '移除廣告';

  @override
  String get productNameGeneric => '該購買項目';

  @override
  String get storeUnavailableMessage => 'App Store 目前無法使用，請稍後再試。';

  @override
  String productUnavailableMessage(String productName) {
    return '$productName 目前無法使用，請稍後再試。';
  }

  @override
  String get purchasePendingMessage => '您的購買正在等待核准。';

  @override
  String get purchaseCancelledMessage => '購買已取消。';

  @override
  String get purchaseFailedMessage => '購買失敗，請重試。';

  @override
  String get removeAdsPurchaseSuccessMessage => '廣告已移除，感謝您的支持！';

  @override
  String get rewardedAdUnavailableMessage => '廣告暫時無法使用，請稍後再試。';

  @override
  String get rewardedAdDismissedMessage => '看完整支廣告才能解鎖主題和照片模式。';

  @override
  String get themesUnlockedMessage => '主題和照片模式已解鎖，盡情體驗吧！';

  @override
  String alreadyOwnedMessage(String productName) {
    return '您已擁有$productName。';
  }

  @override
  String restoreSuccessMessage(String productName) {
    return '$productName已恢復。';
  }

  @override
  String get restoreEmptyMessage => '未找到可恢復的購買記錄。';

  @override
  String get restoreFailedMessage => '恢復失敗，請重試。';

  @override
  String get gameAppBarTitle => '經典15';

  @override
  String get settingsTitle => '設定';

  @override
  String get timeLabel => '用時';

  @override
  String get movesLabel => '步數';

  @override
  String get hintTooltip => '提示';

  @override
  String get undoTooltip => '復原';

  @override
  String get pauseTooltip => '暫停';

  @override
  String get resumeTooltip => '繼續';

  @override
  String get pausedTapToResumeLabel => '已暫停——點擊繼續';

  @override
  String get newGameTooltip => '新遊戲';

  @override
  String get settingsSubtitle => '自訂你的拼圖體驗';

  @override
  String get gridSizeSectionHeader => '網格大小';

  @override
  String get darkModeLabel => '深色模式';

  @override
  String get speedRunModeLabel => '競速模式';

  @override
  String get speedRunModeSubtitle => '動畫更快，僅支援點擊移動';

  @override
  String get speedRunModeInfoTooltip => '關於競速模式';

  @override
  String get speedRunModeExplanation =>
      '在競速模式下，點擊任意方塊即可將其滑向空白格——不需要只點擊緊鄰空白格的方塊。動畫也會更快，讓你盡可能快速地完成拼圖。';

  @override
  String get soundEffectsLabel => '音效';

  @override
  String get adsRemovedTitle => '廣告已移除';

  @override
  String get adsRemovedSubtitle => '感謝您對本應用的支持！';

  @override
  String get removeAdsTitle => '移除廣告';

  @override
  String get removeAdsSubtitle => '永久移除本應用中的廣告。';

  @override
  String get restorePurchasesTitle => '恢復購買';

  @override
  String get unavailableLabel => '無法使用';

  @override
  String get themesSectionHeader => '主題';

  @override
  String get unlockThemesTitle => '解鎖主題';

  @override
  String get unlockThemesSubtitle => '額外的拼圖主題和照片拼圖模式。';

  @override
  String get photoModeTitle => '照片模式';

  @override
  String get photoModeSubtitle => '將照片變成你的拼圖。';

  @override
  String themeSwatchLabel(String themeName) {
    return '$themeName主題';
  }

  @override
  String themeSwatchLockedLabel(String themeName) {
    return '$themeName主題，已鎖定';
  }

  @override
  String get themeNameClassic => '經典';

  @override
  String get themeNameMidnight => '午夜';

  @override
  String get themeNameSunset => '日落';

  @override
  String get themeNameMint => '薄荷';

  @override
  String get tutorialStep1Title => '滑動即可解謎';

  @override
  String get tutorialStep1Description => '點擊空白格旁邊的方塊即可將其滑入空位。將所有方塊按順序排列即可獲勝。';

  @override
  String get tutorialStep2Title => '卡住了？取得提示';

  @override
  String get tutorialStep2Description => '隨時點擊提示按鈕，查看最佳下一步。';

  @override
  String get tutorialStep3Title => '打造專屬於你的拼圖';

  @override
  String get tutorialStep3Description => '在設定中更改網格大小、拼圖主題、音效等。';

  @override
  String get skipButton => '略過';

  @override
  String get nextButton => '下一步';

  @override
  String get getStartedButton => '開始體驗';

  @override
  String get shareButton => '分享';

  @override
  String shareText(String size, String time, String steps) {
    return '我用$steps步、耗時$time完成了${size}x$size的經典15拼圖！';
  }

  @override
  String get rankingsButton => '排行榜';

  @override
  String get victoryTitle => '太棒了！';

  @override
  String victoryDescription(String size) {
    return '你以破紀錄的速度完成了${size}x$size拼圖。';
  }

  @override
  String get advertisementLabel => '廣告';
}
