import 'package:flutter/material.dart';

void showDiskFullBanner(BuildContext context) {
  if (!context.mounted) {
    return;
  }

  ScaffoldMessenger.of(context).showMaterialBanner(
    MaterialBanner(
      content: const Text(
        'Storage full — some content may not save. Free up space and restart the app.',
      ),
      backgroundColor: Colors.red.shade700,
      leading: const Icon(Icons.storage, color: Colors.white),
      actions: const <Widget>[],
    ),
  );
}
