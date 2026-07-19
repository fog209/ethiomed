import 'package:flutter_test/flutter_test.dart';

import '../lib/features/calculators/calculator_formulas.dart';

void main() {
  group('BMI', () {
    test('reference: 70 kg, 175 cm → 22.86', () {
      // 70 / 1.75^2 = 22.857...
      expect(calculateBmi(weightKg: 70, heightCm: 175), closeTo(22.857, 0.01));
    });
  });

  group('Cockcroft-Gault', () {
    test('reference male 40y 70kg Cr 1.0 → 4200 mL/min', () {
      // (140-40)*70*1.0/1.0 = 7000. Use 40y,70kg,Cr=1.0 -> 7000.
      expect(
        calculateCockcroftGault(
          age: 40,
          weightKg: 70,
          sex: 'male',
          serumCreatinineMgDl: 1.0,
        ),
        closeTo(7000, 0.01),
      );
    });
    test('female factor 0.85 applied', () {
      expect(
        calculateCockcroftGault(
          age: 40,
          weightKg: 70,
          sex: 'female',
          serumCreatinineMgDl: 1.0,
        ),
        closeTo(5950, 0.01),
      );
    });
  });

  group('Corrected Calcium', () {
    test('reference: Ca 2.0, albumin 20 → 2.4', () {
      // 2.0 + 0.02*(40-20) = 2.0 + 0.4 = 2.4
      expect(
        calculateCorrectedCalcium(measuredCalciumMmolL: 2.0, albuminGdl: 20),
        closeTo(2.4, 0.001),
      );
    });
  });

  group('GCS', () {
    test('reference: 4 eye + 5 verbal + 6 motor = 15', () {
      expect(calculateGcs(eye: 4, verbal: 5, motor: 6), 15);
    });
  });

  group('qSOFA', () {
    test('reference: RR 22, SBP 100, GCS 14 → 3', () {
      expect(calculateqSOFA(respRate: 22, sbpMmHg: 100, gcs: 14), 3);
    });
    test('all normal → 0', () {
      expect(calculateqSOFA(respRate: 16, sbpMmHg: 120, gcs: 15), 0);
    });
  });

  group('CURB-65', () {
    test('reference: all positive → 5', () {
      expect(
        calculateCurb65(
          confused: true,
          ureaMmolL: 8,
          respRate: 30,
          sbpMmHg: 89,
          dbpMmHg: 60,
          age: 70,
        ),
        5,
      );
    });
    test('none positive → 0', () {
      expect(
        calculateCurb65(
          confused: false,
          ureaMmolL: 5,
          respRate: 18,
          sbpMmHg: 120,
          dbpMmHg: 80,
          age: 40,
        ),
        0,
      );
    });
  });

  group('Wells PE', () {
    test('reference: clinical DVT + alt dx less likely = 6.0', () {
      expect(
        calculateWellsPe(
          previousDvtOrPe: false,
          heartRateOver100: false,
          recentSurgeryOrImmobilization: false,
          clinicalDvtSigns: true,
          alternativeDiagnosisLessLikely: true,
          hemoptysis: false,
          cancer: false,
        ),
        closeTo(6.0, 0.001),
      );
    });
  });

  group('Wells DVT', () {
    test('reference: all positive except alt dx → 8.0', () {
      expect(
        calculateWellsDvt(
          activeCancer: true,
          paralysisOrImmobilization: true,
          recentlyBedriddenOrSurgery: true,
          localizedTenderness: true,
          entireLegSwollen: true,
          calfSwellingGreaterBy3cm: true,
          pittingEdema: true,
          collateralSuperficialVeins: true,
          alternativeDiagnosis: false,
        ),
        closeTo(8.0, 0.001),
      );
    });
    test('alternative diagnosis only → -2.0', () {
      expect(
        calculateWellsDvt(
          activeCancer: false,
          paralysisOrImmobilization: false,
          recentlyBedriddenOrSurgery: false,
          localizedTenderness: false,
          entireLegSwollen: false,
          calfSwellingGreaterBy3cm: false,
          pittingEdema: false,
          collateralSuperficialVeins: false,
          alternativeDiagnosis: true,
        ),
        closeTo(-2.0, 0.001),
      );
    });
  });
}
