import 'package:classic_15_puzzle/l10n/generated/app_localizations.dart';
import 'package:classic_15_puzzle/theme/app_radii.dart';
import 'package:classic_15_puzzle/theme/app_spacing.dart';
import 'package:classic_15_puzzle/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// A short first-run walkthrough. However it's dismissed (Skip, Get
/// Started, tapping outside, or the back button), the caller is
/// responsible for persisting that it's been seen — this widget only pops
/// itself.
class TutorialDialog extends StatefulWidget {
  const TutorialDialog({super.key});

  @override
  State<TutorialDialog> createState() => _TutorialDialogState();
}

class _TutorialDialogState extends State<TutorialDialog> {
  static const _icons = [
    Icons.touch_app_rounded,
    Icons.lightbulb_outline_rounded,
    Icons.tune_rounded,
  ];

  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next(int stepCount) {
    if (_page < stepCount - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final steps = [
      _TutorialStep(
        icon: _icons[0],
        title: l10n.tutorialStep1Title,
        description: l10n.tutorialStep1Description,
      ),
      _TutorialStep(
        icon: _icons[1],
        title: l10n.tutorialStep2Title,
        description: l10n.tutorialStep2Description,
      ),
      _TutorialStep(
        icon: _icons[2],
        title: l10n.tutorialStep3Title,
        description: l10n.tutorialStep3Description,
      ),
    ];
    final isLastPage = _page == steps.length - 1;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 220,
              child: PageView.builder(
                controller: _controller,
                itemCount: steps.length,
                onPageChanged: (page) => setState(() => _page = page),
                itemBuilder: (context, index) =>
                    _TutorialPage(step: steps[index]),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < steps.length; i++)
                  _PageDot(isActive: i == _page),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                isLastPage
                    ? const SizedBox(width: 64)
                    : TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(l10n.skipButton),
                      ),
                FilledButton(
                  onPressed: () => _next(steps.length),
                  child: Text(isLastPage ? l10n.getStartedButton : l10n.nextButton),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TutorialStep {
  final IconData icon;
  final String title;
  final String description;

  const _TutorialStep({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _TutorialPage extends StatelessWidget {
  final _TutorialStep step;

  const _TutorialPage({required this.step});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(step.icon, size: 36, color: colorScheme.primary),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          step.title,
          style: AppTypography.dialogTitle(context),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          step.description,
          textAlign: TextAlign.center,
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _PageDot extends StatelessWidget {
  final bool isActive;

  const _PageDot({required this.isActive});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 20 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: isActive ? colorScheme.primary : colorScheme.outlineVariant,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
