class ArticleContent {
  final String? definition;
  final String? epidemiology;
  final String? etiology;
  final String? pathophysiology;
  final String? clinicalFeatures;
  final String? diagnosis;
  final String? treatment;
  final String? complications;
  final String? ethiopianContext;
  final String? mnemonics;
  final String? redFlags;
  final String? approach;
  final String? contraindications;
  final String? dontMiss;
  final String? clinicalPearls;
  final String? examTraps;

  ArticleContent({
    this.definition,
    this.epidemiology,
    this.etiology,
    this.pathophysiology,
    this.clinicalFeatures,
    this.diagnosis,
    this.treatment,
    this.complications,
    this.ethiopianContext,
    this.mnemonics,
    this.redFlags,
    this.approach,
    this.contraindications,
    this.dontMiss,
    this.clinicalPearls,
    this.examTraps,
  });

  factory ArticleContent.fromJson(Map<String, dynamic> json) {
    return ArticleContent(
      definition: json['definition'] as String? ?? '',
      epidemiology: json['epidemiology'] as String? ?? '',
      etiology: json['etiology'] as String? ?? '',
      pathophysiology: json['pathophysiology'] as String? ?? '',
      clinicalFeatures: json['clinicalFeatures'] as String? ?? '',
      diagnosis: json['diagnosis'] as String? ?? '',
      treatment: json['treatment'] as String? ?? '',
      complications: json['complications'] as String? ?? '',
      ethiopianContext: json['ethiopianContext'] as String? ?? '',
      mnemonics: json['mnemonics'] as String? ?? '',
      redFlags: json['redFlags'] as String? ?? '',
      approach: json['approach'] as String? ?? '',
      contraindications: json['contraindications'] as String? ?? '',
      dontMiss: json['dontMiss'] as String? ?? '',
      clinicalPearls: json['clinicalPearls'] as String? ?? '',
      examTraps: json['examTraps'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'definition': definition,
        'epidemiology': epidemiology,
        'etiology': etiology,
        'pathophysiology': pathophysiology,
        'clinicalFeatures': clinicalFeatures,
        'diagnosis': diagnosis,
        'treatment': treatment,
        'complications': complications,
        'ethiopianContext': ethiopianContext,
        'mnemonics': mnemonics,
        'redFlags': redFlags,
        'approach': approach,
        'contraindications': contraindications,
        'dontMiss': dontMiss,
        'clinicalPearls': clinicalPearls,
        'examTraps': examTraps,
      };
}