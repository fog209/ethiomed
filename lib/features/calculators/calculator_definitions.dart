import 'calculator_formulas.dart';

/// Field spec for a single numeric/boolean input in a calculator form.
class CalcField {
  const CalcField({
    required this.key,
    required this.label,
    this.unit,
    this.isBool = false,
    this.isInt = false,
    this.hint,
  });

  final String key;
  final String label;
  final String? unit;
  final bool isBool;
  final bool isInt;
  final String? hint;
}

/// Declarative definition of each of the 8 calculators: its fields and a
/// function that maps resolved field values to a result string.
class CalculatorDef {
  CalculatorDef({
    required this.name,
    required this.description,
    required this.fields,
    required this.compute,
  });

  final String name;
  final String description;
  final List<CalcField> fields;

  /// [values] keys match [CalcField.key].
  final String Function(Map<String, dynamic> values) compute;
}

final List<CalculatorDef> calculatorDefs = [
  CalculatorDef(
    name: 'BMI',
    description: 'Body Mass Index = weight (kg) / height² (m).',
    fields: [
      CalcField(key: 'weight', label: 'Weight', unit: 'kg', hint: '70'),
      CalcField(key: 'height', label: 'Height', unit: 'cm', hint: '175'),
    ],
    compute: (v) {
      final bmi = calculateBmi(
        weightKg: double.parse(v['weight']),
        heightCm: double.parse(v['height']),
      );
      final cat = bmi < 18.5
          ? 'Underweight'
          : bmi < 25
              ? 'Normal'
              : bmi < 30
                  ? 'Overweight'
                  : 'Obese';
      return '${bmi.toStringAsFixed(1)} kg/m² — $cat';
    },
  ),
  CalculatorDef(
    name: 'Creatinine Clearance (Cockcroft–Gault)',
    description: 'CrCl = (140 − age) × weight × sex / serum creatinine.',
    fields: [
      CalcField(key: 'age', label: 'Age', unit: 'years', isInt: true, hint: '40'),
      CalcField(key: 'weight', label: 'Weight', unit: 'kg', hint: '70'),
      CalcField(key: 'sex', label: 'Sex (male/female)'),
      CalcField(key: 'cr', label: 'Serum creatinine', unit: 'mg/dL', hint: '1.0'),
    ],
    compute: (v) {
      final crcl = calculateCockcroftGault(
        age: int.parse(v['age']),
        weightKg: double.parse(v['weight']),
        sex: v['sex'],
        serumCreatinineMgDl: double.parse(v['cr']),
      );
      return '${crcl.toStringAsFixed(0)} mL/min';
    },
  ),
  CalculatorDef(
    name: 'Corrected Calcium',
    description: 'Corrected Ca = measured + 0.02 × (40 − albumin).',
    fields: [
      CalcField(key: 'ca', label: 'Measured calcium', unit: 'mmol/L', hint: '2.0'),
      CalcField(key: 'alb', label: 'Albumin', unit: 'g/dL', hint: '20'),
    ],
    compute: (v) {
      final ca = calculateCorrectedCalcium(
        measuredCalciumMmolL: double.parse(v['ca']),
        albuminGdl: double.parse(v['alb']),
      );
      return '${ca.toStringAsFixed(2)} mmol/L';
    },
  ),
  CalculatorDef(
    name: 'Glasgow Coma Scale',
    description: 'GCS = eye + verbal + motor (3–15).',
    fields: [
      CalcField(key: 'eye', label: 'Eye (1–4)', isInt: true, hint: '4'),
      CalcField(key: 'verbal', label: 'Verbal (1–5)', isInt: true, hint: '5'),
      CalcField(key: 'motor', label: 'Motor (1–6)', isInt: true, hint: '6'),
    ],
    compute: (v) {
      final gcs = calculateGcs(
        eye: int.parse(v['eye']),
        verbal: int.parse(v['verbal']),
        motor: int.parse(v['motor']),
      );
      return '$gcs / 15';
    },
  ),
  CalculatorDef(
    name: 'qSOFA',
    description: 'Resp ≥22, SBP ≤100, or GCS <15 → 1 each (0–3).',
    fields: [
      CalcField(key: 'rr', label: 'Respiratory rate', unit: '/min', isInt: true, hint: '16'),
      CalcField(key: 'sbp', label: 'Systolic BP', unit: 'mmHg', isInt: true, hint: '120'),
      CalcField(key: 'gcs', label: 'GCS', isInt: true, hint: '15'),
    ],
    compute: (v) {
      final s = calculateqSOFA(
        respRate: int.parse(v['rr']),
        sbpMmHg: int.parse(v['sbp']),
        gcs: int.parse(v['gcs']),
      );
      return '$s / 3';
    },
  ),
  CalculatorDef(
    name: 'CURB-65',
    description: 'Confusion, Urea>7, RR≥30, BP low, Age≥65 → 1 each (0–5).',
    fields: [
      CalcField(key: 'conf', label: 'Confused?', isBool: true),
      CalcField(key: 'urea', label: 'Urea', unit: 'mmol/L', hint: '5'),
      CalcField(key: 'rr', label: 'Respiratory rate', unit: '/min', isInt: true, hint: '18'),
      CalcField(key: 'sbp', label: 'Systolic BP', unit: 'mmHg', isInt: true, hint: '120'),
      CalcField(key: 'dbp', label: 'Diastolic BP', unit: 'mmHg', isInt: true, hint: '80'),
      CalcField(key: 'age', label: 'Age', unit: 'years', isInt: true, hint: '40'),
    ],
    compute: (v) {
      final s = calculateCurb65(
        confused: v['conf'] as bool,
        ureaMmolL: double.parse(v['urea']),
        respRate: int.parse(v['rr']),
        sbpMmHg: int.parse(v['sbp']),
        dbpMmHg: int.parse(v['dbp']),
        age: int.parse(v['age']),
      );
      return '$s / 5';
    },
  ),
  CalculatorDef(
    name: 'Wells Score (PE)',
    description: 'Sum of weighted PE risk criteria (>4 = PE likely).',
    fields: [
      CalcField(key: 'prev', label: 'Previous DVT/PE?', isBool: true),
      CalcField(key: 'hr', label: 'Heart rate >100?', isBool: true),
      CalcField(key: 'immob', label: 'Recent surgery/immobilization?', isBool: true),
      CalcField(key: 'dvt', label: 'Clinical DVT signs?', isBool: true),
      CalcField(key: 'alt', label: 'Alternative dx less likely?', isBool: true),
      CalcField(key: 'hemo', label: 'Hemoptysis?', isBool: true),
      CalcField(key: 'ca', label: 'Active cancer?', isBool: true),
    ],
    compute: (v) {
      final s = calculateWellsPe(
        previousDvtOrPe: v['prev'] as bool,
        heartRateOver100: v['hr'] as bool,
        recentSurgeryOrImmobilization: v['immob'] as bool,
        clinicalDvtSigns: v['dvt'] as bool,
        alternativeDiagnosisLessLikely: v['alt'] as bool,
        hemoptysis: v['hemo'] as bool,
        cancer: v['ca'] as bool,
      );
      return '${s.toStringAsFixed(1)} (${s > 4 ? "PE likely" : "PE unlikely"})';
    },
  ),
  CalculatorDef(
    name: 'Wells Score (DVT)',
    description: 'Sum of weighted DVT risk criteria (≥2 = DVT likely).',
    fields: [
      CalcField(key: 'ca', label: 'Active cancer?', isBool: true),
      CalcField(key: 'paral', label: 'Paralysis/immobilization?', isBool: true),
      CalcField(key: 'bed', label: 'Recently bedridden/surgery?', isBool: true),
      CalcField(key: 'tend', label: 'Localized tenderness?', isBool: true),
      CalcField(key: 'swl', label: 'Entire leg swollen?', isBool: true),
      CalcField(key: 'calf', label: 'Calf swelling >3 cm?', isBool: true),
      CalcField(key: 'edem', label: 'Pitting edema?', isBool: true),
      CalcField(key: 'coll', label: 'Collateral superficial veins?', isBool: true),
      CalcField(key: 'alt', label: 'Alternative diagnosis likely?', isBool: true),
    ],
    compute: (v) {
      final s = calculateWellsDvt(
        activeCancer: v['ca'] as bool,
        paralysisOrImmobilization: v['paral'] as bool,
        recentlyBedriddenOrSurgery: v['bed'] as bool,
        localizedTenderness: v['tend'] as bool,
        entireLegSwollen: v['swl'] as bool,
        calfSwellingGreaterBy3cm: v['calf'] as bool,
        pittingEdema: v['edem'] as bool,
        collateralSuperficialVeins: v['coll'] as bool,
        alternativeDiagnosis: v['alt'] as bool,
      );
      return '${s.toStringAsFixed(1)} (${s >= 2 ? "DVT likely" : "DVT unlikely"})';
    },
  ),
];

CalculatorDef? findCalculatorDef(String name) {
  for (final def in calculatorDefs) {
    if (def.name == name) return def;
  }
  return null;
}
