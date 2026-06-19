import 'package:flutter/material.dart';

class AppConfig {
  static const String chapaPublicKey =
      'CHAPUBK_TEST-bzVPZFrR882oqCj9porT9A6qQ1BrLIhg';

  static const String appTitle = 'WardReady';

  static const String supabaseUrl = 'https://kxcdzlyirdonkipcymvc.supabase.co';

  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt4Y2R6bHlpcmRvbmtpcGN5bXZjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEwMTgxNzcsImV4cCI6MjA5NjU5NDE3N30.S70lUuSwgQBb05BFdcjRAP8F4x2ydeVppljuS6yKlQY';

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
