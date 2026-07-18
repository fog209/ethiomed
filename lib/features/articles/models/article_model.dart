class ArticleSection {
  final String key;
  final String body;

  const ArticleSection({required this.key, required this.body});

  factory ArticleSection.fromJson(Map<String, dynamic> json) {
    return ArticleSection(
      key: (json['key'] as String?) ?? '',
      body: (json['body'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'key': key, 'body': body};
}

class ArticleContent {
  final int schemaVersion;
  final List<ArticleSection> sections;

  const ArticleContent({this.schemaVersion = 2, this.sections = const []});

  factory ArticleContent.empty() => const ArticleContent();

  /// Fixed-field keys, in canonical display order. Used to convert the legacy
  /// fixed-shape content (no `schemaVersion`) into the new `sections` array.
  static const List<String> _legacyFieldOrder = [
    'definition',
    'epidemiology',
    'etiology',
    'pathophysiology',
    'clinicalFeatures',
    'redFlags',
    'approach',
    'diagnosis',
    'treatment',
    'contraindications',
    'dontMiss',
    'complications',
    'clinicalPearls',
    'ethiopianContext',
    'mnemonics',
    'examTraps',
  ];

  factory ArticleContent.fromJson(Map<String, dynamic> json) {
    // New shape: {schemaVersion: 2, sections: [{key, body}]}
    if (json['schemaVersion'] != null) {
      final rawSections = json['sections'];
      final List<ArticleSection> sections = [];
      if (rawSections is List) {
        for (final item in rawSections) {
          if (item is Map<String, dynamic>) {
            final section = ArticleSection.fromJson(item);
            if (section.key.isNotEmpty && section.body.trim().isNotEmpty) {
              sections.add(section);
            }
          }
        }
      }
      return ArticleContent(
        schemaVersion: json['schemaVersion'] is int ? json['schemaVersion'] : 2,
        sections: sections,
      );
    }

    // Legacy shape: fixed named fields. Convert each non-empty field into a
    // {key, body} section in the canonical order so old content renders
    // identically with no immediate data migration.
    final sections = <ArticleSection>[];
    for (final key in _legacyFieldOrder) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) {
        sections.add(ArticleSection(key: key, body: value));
      }
    }
    return ArticleContent(sections: sections);
  }

  Map<String, dynamic> toJson() => {
        'schemaVersion': schemaVersion,
        'sections': [for (final section in sections) section.toJson()],
      };

  /// Returns the body for [key], or null if no section uses that key.
  String? bodyFor(String key) =>
      sections.where((s) => s.key == key).firstOrNull?.body;
}
