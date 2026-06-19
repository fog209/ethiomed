import 'package:flutter/material.dart';

class DisclaimerScreen extends StatelessWidget {
  static const String disclaimerText =
      'WardReady is for educational purposes only. It does not replace clinical judgment, institutional protocols, or licensed clinical supervision. Always verify drug doses with Ethiopian MoH / EFDA guidelines.';

  final VoidCallback onAccepted;

  const DisclaimerScreen({super.key, required this.onAccepted});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 72,
                  color: Color(0xFF1A237E),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Medical Disclaimer',
                  style: TextStyle(
                    color: Color(0xFF1A237E),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Text(
                  disclaimerText,
                  style: TextStyle(fontSize: 17, height: 1.6),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFB300),
                      foregroundColor: const Color(0xFF1A237E),
                    ),
                    onPressed: onAccepted,
                    child: const Text(
                      'I UNDERSTAND',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
