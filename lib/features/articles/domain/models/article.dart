import 'package:flutter/foundation.dart';

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
    final rawCategory = json['category'] as String?;
    if (rawCategory == null || rawCategory.trim().isEmpty) {
      debugPrint('Article ${json['id']} has no category — assigned to General');
    }
    final category = rawCategory == null || rawCategory.trim().isEmpty
        ? 'General'
        : rawCategory;
    Map<String, dynamic>? content;
    final rawContent = json['content'];
    try {
      if (rawContent is Map<String, dynamic>) {
        content = rawContent;
      } else if (rawContent is Map) {
        content = rawContent.cast<String, dynamic>();
      } else {
        debugPrint(
          'Article ${json['id']}: content wrong type ${rawContent.runtimeType}',
        );
        content = const <String, dynamic>{};
      }
    } catch (e) {
      debugPrint('Article content parse failed: $e');
      content = const <String, dynamic>{};
    }
    final imageUrl = json['image_url'] as String?;
    final videoUrl = json['video_url'] as String?;

    return Article(
      id: (json['id'] as String?) ?? '',
      title: title,
      category: category,
      content: content,
      imageUrl: imageUrl,
      videoUrl: videoUrl,
      isHighYield: (json['is_high_yield'] as bool?) ?? false,
    );
  }
}
