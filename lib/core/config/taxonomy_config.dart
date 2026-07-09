import 'package:flutter/material.dart';

/// Per-specialty taxonomy definition for the Library tab.
///
/// Each top-level specialty MAY declare its own ordered list of child
/// sections/subspecialties. Specialties that are absent from
/// [specialtyChildren] (or that declare an empty list) render FLAT — the UI
/// sends the user straight to the article list with no drill-down.
///
/// The lists are fully independent per specialty: Internal Medicine uses a
/// formal subspecialty list, while Pediatrics / OB/GYN / ENT keep their own
/// (currently empty placeholders pending the confirmed curriculum lists).
/// There is intentionally NO shared global "subspecialty -> parent" map here;
/// each specialty owns its own structure.
///
/// This is the single source of truth for UI drill-down. The legacy
/// [AppConfig.categoryToParent] flat map is retained only for mapping old
/// string-form category rows during sync/migration.
class TaxonomyConfig {
  static const Map<String, List<String>> specialtyChildren = {
    'Internal Medicine': <String>[
      'Cardiology',
      'Neurology',
      'Nephrology',
      'Pulmonology',
      'Infectious Diseases',
      'Gastroenterology',
      'Endocrinology',
      'Hematology',
    ],
    // Pending confirmed curriculum lists — render flat for now.
    'Pediatrics': <String>[],
    'OB/GYN': <String>[],
    'ENT': <String>[],
  };

  /// Returns the direct children of [specialty], or an empty list if it has
  /// none (flat specialty).
  static List<String> childrenOf(String specialty) =>
      List.unmodifiable(specialtyChildren[specialty] ?? const <String>[]);

  /// True when [specialty] declares at least one child and should drill down
  /// to a subcategory screen instead of opening the article list directly.
  static bool hasChildren(String specialty) =>
      (specialtyChildren[specialty]?.isNotEmpty ?? false);

  /// Every known child section name across all specialties. Used to keep
  /// subspecialties out of the top-level Library grid so they only appear as
  /// drill-down children of their parent.
  static Set<String> get allChildNames => <String>{
    for (final list in specialtyChildren.values) ...list,
  };
}
