class ArticleContent {
  const ArticleContent({this.ethiopianContext, this.mnemonics});

  final String? ethiopianContext;
  final String? mnemonics;

  factory ArticleContent.fromJson(Map<String, dynamic> json) {
    return ArticleContent(
      ethiopianContext: json['ethiopianContext'] as String?,
      mnemonics: json['mnemonics'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'ethiopianContext': ethiopianContext,
      'mnemonics': mnemonics,
    };
  }
}
