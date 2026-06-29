import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CalculatorsScreen extends ConsumerWidget {
  const CalculatorsScreen({super.key});

  static const List<String> _calculators = [
    'BMI',
    'Creatinine Clearance (Cockcroft–Gault)',
    'Corrected Calcium',
    'Glasgow Coma Scale',
    'qSOFA',
    'CURB-65',
    'Wells Score (PE)',
    'Wells Score (DVT)',
  ];

  static const List<IconData> _icons = [
    Icons.monitor_weight_outlined,
    Icons.waterfall_chart,
    Icons.water_drop_outlined,
    Icons.psychology_outlined,
    Icons.monitor_heart_outlined,
    Icons.score_outlined,
    Icons.favorite_outlined,
    Icons.favorite_outlined,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinical Calculators'),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _calculators.length,
        itemBuilder: (context, index) => _buildCalculatorCard(
          context,
          _calculators[index],
          _icons[index],
        ),
      ),
    );
  }

  Widget _buildCalculatorCard(BuildContext context, String name, IconData icon) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.secondary),
        title: Text(
          name,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: theme.colorScheme.onSurfaceVariant,
          size: 16,
        ),
        onTap: () => context.push('/calculator-detail', extra: name),
      ),
    );
  }
}

class CalculatorDetailScreen extends StatelessWidget {
  const CalculatorDetailScreen({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction_outlined,
              size: 72,
              color: theme.colorScheme.secondary,
            ),
            const SizedBox(height: 24),
            Text(
              'Coming Soon',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This calculator will be available in a future update.',
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}