import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DisclaimerScreen extends StatelessWidget {
  static const String disclaimerText =
      'WardReady is for educational purposes only. Does not replace clinical judgment or licensed supervision. Always verify doses with Ethiopian MoH / EFDA guidelines.';

  const DisclaimerScreen({super.key});

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
                  Icons.medical_services,
                  size: 72,
                  color: Color(0xFFFFB300),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Important Notice',
                  style: TextStyle(
                    color: Color(0xFF1A237E),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Text(
                  'WardReady is for educational purposes only. Does not replace clinical judgment or licensed supervision. Always verify doses with Ethiopian MoH / EFDA guidelines.',
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
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('hasSeenDisclaimer', true);
                      if (!context.mounted) return;
                      context.go('/home');
                    },
                    child: const Text(
                      'I Understand',
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
