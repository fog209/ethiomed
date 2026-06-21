class Article {
  final String id;
  final String title;
  final String? category;
  final Map<String, dynamic>? content;
  final String? imageUrl;
  final String? videoUrl;
  final bool isHighYield;

  Article({
    required this.id,
    required this.title,
    this.category,
    this.content,
    this.imageUrl,
    this.videoUrl,
    this.isHighYield = false,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    final title = json['title'] as String? ?? '';
    final category = json['category'] as String? ?? 'General';
    final content = json['content'] is Map ? json['content'] : null;
    final imageUrl = json['image_url'] as String?;
    final videoUrl = json['video_url'] as String?;

    return Article(
      id: (json['id'] as String?) ?? '',
      title: title,
      category: category,
      content: content is Map<String, dynamic> ? content : null,
      imageUrl: imageUrl,
      videoUrl: videoUrl,
      isHighYield: (json['is_high_yield'] as bool?) ?? false,
    );
  }
}
