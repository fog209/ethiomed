class Article {
  final String id;
  final String title;
  final String? category;
  final Map<String, dynamic>? content;
  final String? imageUrl;
  final String? videoUrl;

  Article({
    required this.id,
    required this.title,
    this.category,
    this.content,
    this.imageUrl,
    this.videoUrl,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: (json['id'] as String?) ?? '',
      title: (json['title'] as String?) ?? 'Untitled Article',
      category: json['category'],
      content: json['content'] is Map ? json['content'] : null,
      imageUrl: json['image_url'],
      videoUrl: json['video_url'],
    );
  }
}
