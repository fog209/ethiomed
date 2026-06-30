import 'package:flutter/material.dart';

void showDiskFullBanner(BuildContext context) {
  if (!context.mounted) {
    return;
  }
  final theme = Theme.of(context);

  ScaffoldMessenger.of(context).showMaterialBanner(
    MaterialBanner(
      content: Text(
        'Storage full — some content may not save. Free up space and restart the app.',
        style: TextStyle(color: theme.colorScheme.onError),
      ),
      backgroundColor: theme.colorScheme.error,
      leading: Icon(Icons.storage, color: theme.colorScheme.onError),
      actions: const <Widget>[],
    ),
  );
}
