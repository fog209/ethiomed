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
    return Article(
      id: (json['id'] as String?) ?? '',
      title: (json['title'] as String?) ?? 'Untitled Article',
      category: json['category'],
      content: json['content'] is Map ? json['content'] : null,
      imageUrl: json['image_url'],
      videoUrl: json['video_url'],
      isHighYield: (json['is_high_yield'] as bool?) ?? false,
    );
  }
}
