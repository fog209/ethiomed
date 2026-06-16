class ArticleContent {
  const ArticleContent({
    this.redFlags,
    this.approach,
    this.contraindications,
    this.clinicalPearls,
    this.ethiopianContext,
    this.mnemonics,
  });

  final String? redFlags;
  final String? approach;
  final String? contraindications;
  final String? clinicalPearls;
  final String? ethiopianContext;
  final String? mnemonics;

  factory ArticleContent.fromJson(Map<String, dynamic> json) {
    return ArticleContent(
      redFlags: json['redFlags'] as String?,
      approach: json['approach'] as String?,
      contraindications: json['contraindications'] as String?,
      clinicalPearls: json['clinicalPearls'] as String?,
      ethiopianContext: json['ethiopianContext'] as String?,
      mnemonics: json['mnemonics'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'redFlags': redFlags,
      'approach': approach,
      'contraindications': contraindications,
      'clinicalPearls': clinicalPearls,
      'ethiopianContext': ethiopianContext,
      'mnemonics': mnemonics,
    };
  }
}
