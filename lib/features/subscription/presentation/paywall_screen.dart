import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/app_url_launcher.dart';
import '../data/subscription_repository.dart';

class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  // CHANGE THIS TO YOUR REAL TELEBIRR NUMBER
  static const String telebirrNumber = "0983313922";
  static const String telegramAdmin = "https://t.me/thyk07";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.stars_rounded, size: 100, color: theme.colorScheme.secondary),
              const SizedBox(height: 20),
              Text(
                "WardReady Premium",
                style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "Unlock 267+ clinical articles, diagrams, and offline access.",
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 16),
              ),
              const SizedBox(height: 30),
              
              // PAYMENT INSTRUCTIONS CARD
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
Text("HOW TO ACTIVATE",
                          style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                      const SizedBox(height: 15),
                      Text("1. Pay 500 ETB via Telebirr to:", textAlign: TextAlign.center,
                          style: TextStyle(color: theme.colorScheme.onSurface)),
                      const SizedBox(height: 5),
                      SelectableText(
                        telebirrNumber,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.copy),
                        label: const Text("Copy Number"),
                        onPressed: () {
                          Clipboard.setData(const ClipboardData(text: telebirrNumber));
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Number copied to clipboard!")));
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // TELEGRAM BUTTON
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.secondary,
                  side: BorderSide(color: theme.colorScheme.secondary),
                  minimumSize: const Size(double.infinity, 50),
                ),
                icon: const Icon(Icons.send),
                label: const Text("SEND PAYMENT SCREENSHOT (TELEGRAM)"),
                onPressed: () async {
                  final uri = Uri.parse(telegramAdmin);
                  await launchHttpsUrl(context, uri);
                },
              ),
              
              const SizedBox(height: 40),
              
              // REFRESH BUTTON
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondary,
                  foregroundColor: theme.colorScheme.onSecondary,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => ref.refresh(isSubscribedProvider),
                child: const Text("I HAVE PAID - CHECK STATUS", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}