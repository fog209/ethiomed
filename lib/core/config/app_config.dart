import 'package:flutter/material.dart';
import '../../app/env.dart';

class AppConfig {
  static const String appTitle = 'WardReady';

  static const String supabaseUrl = Env.supabaseUrl;

  static const String supabaseAnonKey = Env.supabaseAnonKey;

  static void debugConfig() {
    debugPrint('SUPABASE_URL configured = ${supabaseUrl.isNotEmpty}');
    debugPrint('SUPABASE_KEY configured = ${supabaseAnonKey.isNotEmpty}');
  }

  static const String internalMedicineCategory = 'Internal Medicine';

  static const List<Map<String, Object?>> clinicalCategories =
      <Map<String, Object?>>[
        {'name': internalMedicineCategory, 'icon': Icons.medical_services},
        {'name': 'Pulmonology', 'icon': Icons.air},
        {'name': 'Infectious Diseases', 'icon': Icons.bug_report},
        {'name': 'Gastroenterology', 'icon': Icons.restaurant},
        {'name': 'Endocrinology', 'icon': Icons.monitor_weight},
        {'name': 'Hematology', 'icon': Icons.bloodtype},
        {'name': 'OB/GYN', 'icon': Icons.pregnant_woman},
        {'name': 'Pediatrics', 'icon': Icons.child_care},
        {'name': 'General Surgery', 'icon': Icons.medical_services},
        {'name': 'Psychiatry', 'icon': Icons.psychology},
        {'name': 'Dermatology', 'icon': Icons.face},
        {'name': 'Ophthalmology', 'icon': Icons.remove_red_eye},
        {'name': 'ENT', 'icon': Icons.hearing},
        {'name': 'Pharmacology', 'icon': Icons.medication},
      ];

  static const List<Map<String, Object?>> preclinicalCategories =
      <Map<String, Object?>>[
        {'name': 'Microbiology', 'icon': Icons.bug_report},
        {'name': 'Physiology', 'icon': Icons.favorite},
        {'name': 'Biochemistry', 'icon': Icons.science},
        {'name': 'Pathology', 'icon': Icons.local_hospital_outlined},
        {'name': 'Anatomy', 'icon': Icons.accessibility_new},
      ];
}
