import 'package:flutter_riverpod/flutter_riverpod.dart';

final examDateProvider = StateProvider<DateTime?>((ref) {
  return null;
});

final studyPlanProvider = FutureProvider<({String? currentSpecialty, int dayNumber, int totalDays, int daysRemaining})>((ref) async {
  final examDate = ref.read(examDateProvider);
  if (examDate == null) {
    return (
      currentSpecialty: null,
      dayNumber: 0,
      totalDays: 0,
      daysRemaining: 0,
    );
  }

  final now = DateTime.now();
  final daysRemaining = examDate.difference(now).inDays;
  if (daysRemaining <= 0) {
    return (
      currentSpecialty: null,
      dayNumber: 0,
      totalDays: 0,
      daysRemaining: 0,
    );
  }

  final specialtyDays = <String, int>{
    'Internal Medicine': 30,
    'Pediatrics': 20,
    'Surgery': 15,
    'OB/GYN': 10,
    'Psychiatry': 8,
    'Medicine Subspecialties': 12,
    'Preclinical': 15,
  };

  final mixedReviewDays = 14;
  final studyDays = daysRemaining - mixedReviewDays;

  return _calculatePlan(specialtyDays, studyDays);
});

({String? currentSpecialty, int dayNumber, int totalDays, int daysRemaining}) _calculatePlan(
  Map<String, int> specialtyDays,
  int totalStudyDays,
) {
  int cumulativeDays = 0;
  String? currentSpecialty;
  int dayNumber = 0;

  for (final entry in specialtyDays.entries) {
    final specialty = entry.key;
    final days = entry.value;
    if (dayNumber + days >= totalStudyDays) {
      currentSpecialty = specialty;
      dayNumber = totalStudyDays - cumulativeDays;
      break;
    }
    cumulativeDays += days;
    dayNumber += days;
  }

  if (currentSpecialty == null && specialtyDays.isNotEmpty) {
    currentSpecialty = specialtyDays.keys.last;
    dayNumber = specialtyDays.values.last;
  }

  return (
    currentSpecialty: currentSpecialty,
    dayNumber: dayNumber,
    totalDays: totalStudyDays + 14,
    daysRemaining: totalStudyDays + 14,
  );
}