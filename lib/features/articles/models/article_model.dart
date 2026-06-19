class Article {
  const Article({
    required this.id,
    required this.title,
    this.category,
    this.subcategory,
    this.slug,
    this.content,
    this.imageUrl,
    this.videoUrl,
  });

  final String id;
  final String title;
  final String? category;
  final String? subcategory;
  final String? slug;
  final ArticleContent? content;
  final String? imageUrl;
  final String? videoUrl;

  factory Article.fromJson(Map<String, dynamic> json) {
    final content = json['content'];
    final contentMap = content is Map<String, dynamic> ? content : null;

    return Article(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      category: json['category'] as String?,
      subcategory: json['subcategory'] as String?,
      slug: json['slug'] as String?,
      content: contentMap == null ? null : ArticleContent.fromJson(contentMap),
      imageUrl: json['image_url'] as String?,
      videoUrl: json['video_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'category': category,
      'subcategory': subcategory,
      'slug': slug,
      'content': content?.toJson(),
      'image_url': imageUrl,
      'video_url': videoUrl,
    };
  }
}

class ArticleContent {
  const ArticleContent({
    this.subcategory,
    this.slug,
    this.redFlags,
    this.approach,
    this.contraindications,
    this.dontMiss,
    this.clinicalPearls,
    this.ethiopianContext,
    this.mnemonics,
    this.examTraps,
  });

  final String? subcategory;
  final String? slug;
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
      subcategory: json['subcategory'] as String?,
      slug: json['slug'] as String?,
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
      'subcategory': subcategory,
      'slug': slug,
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
