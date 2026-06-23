import 'package:flutter/material.dart';

/// Standard placeholder Terms of Service content.
/// Replace/extend with your final legal text if available.
class TermsContent extends StatelessWidget {
  const TermsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Terms of Service\n\n'
      '1) Use of the App\n'
      'WardReady provides educational information related to clinical learning. '
      'You agree to use the app only for educational purposes.\n\n'
      '2) No Medical Advice\n'
      'Content provided by the app does not constitute medical advice and does not '
      'replace clinical judgment, institutional protocols, or licensed clinical supervision.\n\n'
      '3) Offline Content\n'
      'Some content may be available offline. You are responsible for verifying information '
      'with current Ethiopian MoH / EFDA guidance before use.\n\n'
      '4) Limitation of Liability\n'
      'To the maximum extent permitted by law, WardReady is not liable for any damages arising '
      'from the use of or inability to use the app.\n\n'
      '5) Changes\n'
      'We may update these Terms of Service from time to time. Continued use of the app after '
      'changes are posted constitutes acceptance of the updated terms.\n',
      style: TextStyle(fontSize: 15, height: 1.6),
    );
  }
}
