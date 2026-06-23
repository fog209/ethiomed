import 'package:flutter/material.dart';

/// Standard placeholder Privacy Policy content.
/// Replace/extend with your final legal text if available.
class PrivacyContent extends StatelessWidget {
  const PrivacyContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Privacy Policy\n\n'
      '1) Educational Use\n'
      'WardReady is an educational application. We do not provide medical advice.\n\n'
      '2) Data Handling\n'
      'If you use the app features that require authentication, your account data may '
      'be stored and used to provide the service.\n\n'
      '3) Offline Content\n'
      'Some educational content may be available offline. Offline use does not '
      'automatically transfer your personal data.\n\n'
      '4) No Guaranteed Anonymity\n'
      'Nothing in this policy guarantees complete anonymity while using online features.\n\n'
      '5) Updates\n'
      'We may update this Privacy Policy from time to time.\n',
      style: TextStyle(fontSize: 15, height: 1.6),
    );
  }
}
