import 'package:flutter/material.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialBanner(
      backgroundColor: const Color(0xFFF9A825),
      content: const Text(
        "You're offline — showing saved content",
        style: TextStyle(color: Colors.black87),
      ),
      actions: const <Widget>[],
    );
  }
}
