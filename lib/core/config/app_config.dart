import 'package:flutter/material.dart';
import '../../app/env.dart';

class AppConfig {
  static const String appTitle = 'WardReady';

  static String get supabaseUrl => Env.supabaseUrl;

  static String get supabaseAnonKey => Env.supabaseAnonKey;

  static const String internalMedicineCategory = 'Internal Medicine';

  static const List<Map<String, Object?>> clinicalCategories =
      <Map<String, Object?>>[
        {'name': internalMedicineCategory, 'icon': Icons.medical_services},
        {'name': 'OB/GYN', 'icon': Icons.pregnant_woman},
        {'name': 'Pediatrics', 'icon': Icons.child_care},
        {'name': 'General Surgery', 'icon': Icons.medical_services},
        {'name': 'Psychiatry', 'icon': Icons.psychology},
        {'name': 'Dermatology', 'icon': Icons.face},
        {'name': 'Ophthalmology', 'icon': Icons.remove_red_eye},
        {'name': 'ENT', 'icon': Icons.hearing},
        {'name': 'Pharmacology', 'icon': Icons.medication},
        {'name': 'Radiology', 'icon': Icons.medical_services},
        {'name': 'Emergency Medicine', 'icon': Icons.emergency},
        {'name': 'Orthopedics', 'icon': Icons.accessibility},
        {'name': 'Anesthesiology', 'icon': Icons.airline_seat_flat},
        {'name': 'Public Health and Epidemiology', 'icon': Icons.public},
        {'name': 'Forensic Medicine', 'icon': Icons.gavel},
      ];

  static const List<Map<String, Object?>> preclinicalCategories =
      <Map<String, Object?>>[
        {'name': 'Microbiology', 'icon': Icons.bug_report},
        {'name': 'Physiology', 'icon': Icons.favorite},
        {'name': 'Biochemistry', 'icon': Icons.science},
        {'name': 'Pathology', 'icon': Icons.local_hospital_outlined},
        {'name': 'Anatomy', 'icon': Icons.accessibility_new},
      ];

  /// Canonical mapping of a subspecialty (legacy flat category) to the parent
  /// category it belongs to. This is the SINGLE source of truth — used by
  /// [Article.fromJson], the Drift migration backfill, and
  /// `migrateCategoryToParentCategory()`. Keep all legacy→parent mappings here
  /// ONLY; do not duplicate this map elsewhere.
  ///
  /// Cardiology, Neurology, and Nephrology are subspecialties of Internal
  /// Medicine (not top-level categories).
  static const Map<String, String> categoryToParent = {
    'Cardiology': 'Internal Medicine',
    'Neurology': 'Internal Medicine',
    'Nephrology': 'Internal Medicine',
    'Pulmonology': 'Internal Medicine',
    'Infectious Diseases': 'Internal Medicine',
    'Gastroenterology': 'Internal Medicine',
    'Endocrinology': 'Internal Medicine',
    'Neonatology': 'Pediatrics',
    'Developmental Milestones': 'Pediatrics',
    'Obstetrics': 'OB/GYN',
    'Gynecology': 'OB/GYN',
  };

  /// Subspecialties nested under each parent category, derived from
  /// [categoryToParent] so there is exactly one mapping to maintain.
  static Map<String, List<String>> get subspecialtiesByParent {
    final map = <String, List<String>>{};
    for (final entry in categoryToParent.entries) {
      map.putIfAbsent(entry.value, () => <String>[]).add(entry.key);
    }
    return map;
  }

  /// Top-level (parent) clinical categories to render in the Library grid.
  /// Subspecialties listed in [categoryToParent] are excluded so they appear
  /// as drill-down children of their parent instead of top-level tiles.
  static List<Map<String, Object?>> get topLevelClinicalCategories {
    final subspecialtyKeys = categoryToParent.keys.toSet();
    return [
      for (final cat in clinicalCategories)
        if (!subspecialtyKeys.contains(cat['name']?.toString() ?? '')) cat,
    ];
  }
}
