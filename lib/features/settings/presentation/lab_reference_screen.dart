import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LabReferenceScreen extends StatefulWidget {
  const LabReferenceScreen({super.key});

  @override
  State<LabReferenceScreen> createState() => _LabReferenceScreenState();
}

class _LabReferenceScreenState extends State<LabReferenceScreen> {
  Map<String, dynamic> _references = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReferences();
  }

  Future<void> _loadReferences() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/lab_references.json');
      _references = json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error loading lab references: $e');
    }
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab References'),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _references.isEmpty
              ? const Center(child: Text('No references available'))
              : ListView(
                  children: _references.entries.map((entry) {
                    final key = entry.key;
                    final data = entry.value;
                    return _buildReferenceSection(key, data, theme);
                  }).toList(),
                ),
    );
  }

  Widget _buildReferenceSection(
    String key,
    dynamic data,
    ThemeData theme,
  ) {
    if (data == null || data is! Map) {
      return const SizedBox.shrink();
    }

    final title = data['title'] as String? ?? key;

    if (key == 'common_drugs') {
      final drugs = data['drugs'] as List<dynamic>? ?? [];
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              ...drugs.map((drug) {
                final name = drug['name'] as String? ?? '';
                final dose = drug['dose'] as String? ?? '';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• ', style: TextStyle(color: theme.colorScheme.secondary)),
                      Expanded(
                        child: Text(
                          '$name: $dose',
                          style: TextStyle(color: theme.colorScheme.onSurface),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      );
    }

    final values = data['values'] as List<dynamic>? ?? [];
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 24,
                headingRowColor: WidgetStateProperty.all(
                  theme.colorScheme.surfaceContainerHighest,
                ),
                columns: const [
                  DataColumn(label: Text('Test')),
                  DataColumn(label: Text('Normal Range')),
                  DataColumn(label: Text('Units')),
                ],
                rows: values.map((v) {
                  final name = v['name'] as String? ?? '';
                  final normal = v['normal'] as String? ?? '';
                  final units = v['units'] as String? ?? '';
                  return DataRow(
                    cells: [
                      DataCell(Text(name)),
                      DataCell(Text(normal)),
                      DataCell(Text(units)),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}