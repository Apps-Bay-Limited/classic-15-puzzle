import 'package:classic_15_puzzle/links.dart';
import 'package:classic_15_puzzle/utils/url.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutDialog extends StatelessWidget {
  const AboutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    const padding = EdgeInsets.symmetric(horizontal: 24);

    Padding horizontalPadding(Widget child) {
      return Padding(
        padding: padding,
        child: child,
      );
    }

    return SimpleDialog(
      title: const Text('About'),
      children: <Widget>[
        horizontalPadding(
            const Text('Game of Fifteen is a free and open source app '
                'written with Flutter. It features beautiful design and '
                'smooth animations.')),
        const SizedBox(height: 8),
        horizontalPadding(
            const Text('You can compete with your friends online. '
                'The complexity of puzzles is similar from game to game.')),
        const SizedBox(height: 24),
        ListTile(
          leading: const Icon(Icons.code, size: 24),
          contentPadding: padding,
          title: const Text('Join development'),
          onTap: () {
            launchUrl(url: urlRepository);
          },
        ),
        ListTile(
          leading: const Icon(Icons.bug_report, size: 24),
          contentPadding: padding,
          title: const Text('Send bug report'),
          onTap: () {
            launchUrl(url: urlFeedback);
          },
        ),
        const SizedBox(height: 24),
        FutureBuilder<PackageInfo>(
          future: PackageInfo.fromPlatform(),
          builder: (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
            String text;
            final data = snapshot.data;
            if (data != null) {
              final buildVersion = data.version;
              final buildNumber = data.buildNumber;
              text = 'Game of Fifteen v$buildVersion-$buildNumber';
            } else {
              text = 'Game of Fifteen, web version';
            }
            return horizontalPadding(
              Semantics(
                label: "App version",
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            );
          },
        )
      ],
    );
  }
}
