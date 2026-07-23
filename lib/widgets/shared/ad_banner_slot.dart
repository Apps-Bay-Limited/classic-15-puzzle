import 'package:classic_15_puzzle/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Banner ad slot that only takes up space once a real ad has loaded.
///
/// While the ad is still loading (or has failed / no-filled) the slot
/// collapses to nothing rather than reserving an empty bar with a bare
/// "advertisement" placeholder — that empty strip read as a broken ad. When
/// the ad does load it animates in from zero height.
class AdBannerSlot extends StatelessWidget {
  final bool isLoaded;
  final bool hasFailed;
  final Widget? adWidget;

  const AdBannerSlot({
    super.key,
    required this.isLoaded,
    required this.hasFailed,
    this.adWidget,
  });

  @override
  Widget build(BuildContext context) {
    final showAd = isLoaded && !hasFailed && adWidget != null;

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: showAd
          ? Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: SizedBox(
                height: AppSpacing.adBannerHeight,
                width: double.infinity,
                child: Center(child: adWidget),
              ),
            )
          : const SizedBox(width: double.infinity, height: 0),
    );
  }
}
