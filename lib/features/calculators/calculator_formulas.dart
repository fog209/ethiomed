/// Pure, testable clinical calculator formulas for WardReady.
///
/// Every function is a side-effect-free Dart function so it can be unit
/// tested against published reference values. Units are stated per parameter.
/// References:
///  - BMI: Quetelet (1832); clinical cutoff WHO.
///  - Cockcroft–Gault: Cockcroft & Gault, Nephron 1976.
///  - Corrected Calcium: standard albumin-correction (per 1 g/dL albumin
///    deficit of 0.02 mmol/L) — see e.g. Lancet 1983;21:574.
///  - GCS: Teasdale & Jennett, Lancet 1974.
///  - qSOFA: Sepsis-3, JAMA 2016.
///  - CURB-65: Lim et al., Thorax 2003.
///  - Wells PE / DVT: Wells et al., Thromb Haemost 2000 / 2003.

library;

/// Body Mass Index (kg/m²). [heightCm] is height in centimetres.
double calculateBmi({required double weightKg, required double heightCm}) {
  if (weightKg <= 0 || heightCm <= 0) {
    throw ArgumentError('Weight and height must be positive.');
  }
  final heightM = heightCm / 100;
  return weightKg / (heightM * heightM);
}

/// Cockcroft–Gault creatinine clearance (mL/min).
/// [sex] 'male' or 'female' (female multiplies by 0.85).
/// [serumCreatinineMgDl] in mg/dL.
double calculateCockcroftGault({
  required int age,
  required double weightKg,
  required String sex,
  required double serumCreatinineMgDl,
}) {
  if (age <= 0 || weightKg <= 0 || serumCreatinineMgDl <= 0) {
    throw ArgumentError('Inputs must be positive.');
  }
  final sexFactor = sex.toLowerCase() == 'female' ? 0.85 : 1.0;
  return ((140 - age) * weightKg * sexFactor) / serumCreatinineMgDl;
}

/// Albumin-corrected total calcium (mmol/L).
/// [measuredCalciumMmolL] total calcium, [albuminGdl] albumin in g/dL.
/// Corrected = measured + 0.02 * (40 - albumin).
double calculateCorrectedCalcium({
  required double measuredCalciumMmolL,
  required double albuminGdl,
}) {
  return measuredCalciumMmolL + 0.02 * (40 - albuminGdl);
}

/// Glasgow Coma Scale (3–15). Sums eye/verbal/motor component scores.
int calculateGcs({
  required int eye,
  required int verbal,
  required int motor,
}) {
  if (eye < 1 || eye > 4 || verbal < 1 || verbal > 5 || motor < 1 || motor > 6) {
    throw ArgumentError('GCS components out of range.');
  }
  return eye + verbal + motor;
}

/// qSOFA score (0–3) for sepsis risk.
/// [respRate] breaths/min, [sbpMmHg] systolic BP, [gcs] Glasgow score.
int calculateqSOFA({
  required int respRate,
  required int sbpMmHg,
  required int gcs,
}) {
  var score = 0;
  if (respRate >= 22) score++;
  if (gcs < 15) score++;
  if (sbpMmHg <= 100) score++;
  return score;
}

/// CURB-65 severity score (0–5). [ureaMmolL] serum urea (mmol/L).
int calculateCurb65({
  required bool confused,
  required double ureaMmolL,
  required int respRate,
  required int sbpMmHg,
  required int dbpMmHg,
  required int age,
}) {
  var score = 0;
  if (confused) score++;
  if (ureaMmolL > 7) score++;
  if (respRate >= 30) score++;
  if (sbpMmHg < 90 || dbpMmHg <= 60) score++;
  if (age >= 65) score++;
  return score;
}

/// Wells score for pulmonary embolism (PE).
/// Returns the summed weighted points. A score > 4 is "PE likely".
double calculateWellsPe({
  required bool previousDvtOrPe,
  required bool heartRateOver100,
  required bool recentSurgeryOrImmobilization,
  required bool clinicalDvtSigns,
  required bool alternativeDiagnosisLessLikely,
  required bool hemoptysis,
  required bool cancer,
}) {
  var score = 0.0;
  if (clinicalDvtSigns) score += 3.0;
  if (alternativeDiagnosisLessLikely) score += 3.0;
  if (heartRateOver100) score += 1.5;
  if (previousDvtOrPe) score += 1.5;
  if (recentSurgeryOrImmobilization) score += 1.5;
  if (hemoptysis) score += 1.0;
  if (cancer) score += 1.0;
  return score;
}

/// Wells score for deep vein thrombosis (DVT).
/// Returns the summed weighted points. A score >= 2 is "DVT likely".
double calculateWellsDvt({
  required bool activeCancer,
  required bool paralysisOrImmobilization,
  required bool recentlyBedriddenOrSurgery,
  required bool localizedTenderness,
  required bool entireLegSwollen,
  required bool calfSwellingGreaterBy3cm,
  required bool pittingEdema,
  required bool collateralSuperficialVeins,
  required bool alternativeDiagnosis,
}) {
  var score = 0.0;
  if (alternativeDiagnosis) score -= 2.0;
  if (activeCancer) score += 1.0;
  if (paralysisOrImmobilization) score += 1.0;
  if (recentlyBedriddenOrSurgery) score += 1.0;
  if (localizedTenderness) score += 1.0;
  if (entireLegSwollen) score += 1.0;
  if (calfSwellingGreaterBy3cm) score += 1.0;
  if (pittingEdema) score += 1.0;
  if (collateralSuperficialVeins) score += 1.0;
  return score;
}
