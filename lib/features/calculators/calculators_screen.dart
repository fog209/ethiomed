import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'calculator_definitions.dart';

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

class CalculatorDetailScreen extends ConsumerStatefulWidget {
  const CalculatorDetailScreen({super.key, required this.name});

  final String name;

  @override
  ConsumerState<CalculatorDetailScreen> createState() =>
      _CalculatorDetailScreenState();
}

class _CalculatorDetailScreenState extends ConsumerState<CalculatorDetailScreen> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _boolValues = {};
  String? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    final def = findCalculatorDef(widget.name);
    for (final field in def?.fields ?? const []) {
      if (field.isBool) {
        _boolValues[field.key] = false;
      } else {
        _controllers[field.key] = TextEditingController();
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _calculate() {
    final def = findCalculatorDef(widget.name);
    if (def == null) return;
    setState(() {
      _error = null;
      _result = null;
    });
    final values = <String, dynamic>{};
    try {
      for (final field in def.fields) {
        if (field.isBool) {
          values[field.key] = _boolValues[field.key] ?? false;
        } else if (field.isInt) {
          values[field.key] = int.parse(_controllers[field.key]!.text.trim());
        } else {
          values[field.key] = _controllers[field.key]!.text.trim();
        }
      }
      setState(() {
        _result = def.compute(values);
      });
    } catch (e) {
      setState(() {
        _error = 'Check your inputs (numbers only).';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final def = findCalculatorDef(widget.name);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: def == null
          ? const Center(child: Text('Calculator not found.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  def.description,
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                for (final field in def.fields) ...[
                  if (field.isBool)
                    SwitchListTile(
                      title: Text(field.label),
                      value: _boolValues[field.key] ?? false,
                      onChanged: (v) =>
                          setState(() => _boolValues[field.key] = v),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TextField(
                        controller: _controllers[field.key],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: field.label,
                          suffixText: field.unit,
                          hintText: field.hint,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                ],
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: _calculate,
                  icon: const Icon(Icons.calculate),
                  label: const Text('Calculate'),
                ),
                const SizedBox(height: 16),
                if (_error != null)
                  Text(
                    _error!,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                if (_result != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: theme.colorScheme.secondary),
                    ),
                    child: Text(
                      _result!,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
    );
  }
}