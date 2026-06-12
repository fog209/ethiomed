import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/subscription_repository.dart';

class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A237E),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 100, color: Color(0xFFFFB300)),
            const SizedBox(height: 20),
            const Text(
              "Premium Access Required",
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              "To unlock 200+ articles and offline mode, please pay 500 ETB via Telebirr.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              "Telebirr: 0911 22 33 44",
              style: TextStyle(color: Color(0xFFFFB300), fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB300),
                foregroundColor: const Color(0xFF1A237E),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () => ref.refresh(isSubscribedProvider),
              child: const Text("I HAVE PAID - REFRESH"),
            ),
          ],
        ),
      ),
    );
  }
}