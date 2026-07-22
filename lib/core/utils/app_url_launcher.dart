import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Uri? resolveHttpsTarget(Uri uri) {
  final scheme = uri.scheme.toLowerCase();
  if (scheme == 'http') {
    return uri.replace(scheme: 'https');
  }
  if (scheme == 'https') {
    return uri;
  }
  return null;
}

Future<void> launchHttpsUrl(
  BuildContext context,
  Uri uri, {
  LaunchMode mode = LaunchMode.externalApplication,
}) async {
  final target = resolveHttpsTarget(uri);
  if (target == null) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid or insecure link detected.')),
      );
    }
    return;
  }

  if (await canLaunchUrl(target)) {
    await launchUrl(target, mode: mode);
  }
}
