import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MedicalDisclaimerModal extends ConsumerWidget {
  const MedicalDisclaimerModal({super.key});

  static const String medicalDisclaimerText =
      'This app is an educational tool for students. It is NOT a clinical guideline and must NOT be used for patient care or medical decision-making.';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
        },
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Dialog(
              insetPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.medical_services,
                      size: 64,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Medical Disclaimer',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      medicalDisclaimerText,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 16,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.secondary,
                          foregroundColor: theme.colorScheme.onSecondary,
                        ),
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('has_seen_medical_disclaimer', true);
                          if (!context.mounted) return;
                          context.go('/home');
                        },
                        child: const Text(
                          'I Understand and Agree',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}