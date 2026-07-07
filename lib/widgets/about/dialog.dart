import 'package:classic_15_puzzle/links.dart';
import 'package:classic_15_puzzle/utils/url.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutDialog extends StatelessWidget {
  const AboutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('About Game', style: TextStyle(fontWeight: FontWeight.w800)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Game of Fifteen is a premium, open-source puzzle experience. It features beautiful animations, haptic feedback, and a clean interface.',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Text(
              'Compete with friends online and track your best times.',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            _AboutLink(
              icon: Icons.code_rounded,
              label: 'Join development',
              url: urlRepository,
            ),
            _AboutLink(
              icon: Icons.bug_report_rounded,
              label: 'Send bug report',
              url: urlFeedback,
            ),
            const SizedBox(height: 24),
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                final text = snapshot.hasData
                    ? 'Version ${snapshot.data!.version} (${snapshot.data!.buildNumber})'
                    : 'Classic 15 Puzzle';
                return Text(
                  text,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.outline,
                        fontWeight: FontWeight.w700,
                      ),
                );
              },
            )
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CLOSE'),
        ),
      ],
    );
  }
}

class _AboutLink extends StatelessWidget {
  final IconData icon;
  final String label;
  final String url;

  const _AboutLink({required this.icon, required this.label, required this.url});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => launchUrl(url: url),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Icon(icon, size: 22, color: colorScheme.primary),
            const SizedBox(width: 16),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: colorScheme.outline),
          ],
        ),
      ),
    );
  }
}
