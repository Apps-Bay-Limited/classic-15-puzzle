import 'package:url_launcher/url_launcher.dart' as launcher;

void launchUrl({required String url}) async {
  final uri = Uri.parse(url);
  if (await launcher.canLaunchUrl(uri)) {
    await launcher.launchUrl(uri);
  } else {
    throw 'Could not launch $url';
  }
}
