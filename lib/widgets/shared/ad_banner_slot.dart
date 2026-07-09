import 'package:classic_15_puzzle/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Reserved banner ad slot with graceful collapse on load failure.
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
    if (hasFailed) {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      height: AppSpacing.adBannerHeight,
      width: double.infinity,
      alignment: Alignment.center,
      child: isLoaded && adWidget != null
          ? adWidget
          : Text(
              'ADVERTISEMENT',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.5),
                  ),
            ),
    );
  }
}
