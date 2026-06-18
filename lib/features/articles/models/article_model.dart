class ArticleContent {
  const ArticleContent({
    this.redFlags,
    this.approach,
    this.contraindications,
    this.dontMiss,
    this.clinicalPearls,
    this.ethiopianContext,
    this.mnemonics,
    this.examTraps,
  });

  final String? redFlags;
  final String? approach;
  final String? contraindications;
  final String? dontMiss;
  final String? clinicalPearls;
  final String? ethiopianContext;
  final String? mnemonics;
  final String? examTraps;

  factory ArticleContent.fromJson(Map<String, dynamic> json) {
    return ArticleContent(
      redFlags: json['redFlags'] as String?,
      approach: json['approach'] as String?,
      contraindications: json['contraindications'] as String?,
      dontMiss: json['dontMiss'] as String?,
      clinicalPearls: json['clinicalPearls'] as String?,
      ethiopianContext: json['ethiopianContext'] as String?,
      mnemonics: json['mnemonics'] as String?,
      examTraps: json['examTraps'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'redFlags': redFlags,
      'approach': approach,
      'contraindications': contraindications,
      'dontMiss': dontMiss,
      'clinicalPearls': clinicalPearls,
      'ethiopianContext': ethiopianContext,
      'mnemonics': mnemonics,
      'examTraps': examTraps,
    };
  }
}
