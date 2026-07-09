import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../../../../core/config/app_config.dart';

class Article {
  final String id;
  final String title;
  final List<String> category;
  final Map<String, dynamic>? content;
  final String? imageUrl;
  final String? videoUrl;
  final bool isHighYield;

  Article({
    required this.id,
    required this.title,
    required this.category,
    this.content,
    this.imageUrl,
    this.videoUrl,
    this.isHighYield = false,
  });

  String get parentCategory => category.isNotEmpty ? category.first : 'General';
  String get subcategory => category.length > 1 ? category[1] : '';

  String get categoryName => category.length > 1 ? category[1] : parentCategory;

  int get estimatedReadMinutes {
    final content = this.content;
    if (content == null) return 1;
    int totalWords = 0;
    for (final value in content.values) {
      if (value is String) {
        totalWords += value.split(RegExp(r'\s+')).length;
      }
    }
    return (totalWords / 200).round().clamp(1, 999);
  }

  factory Article.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] as String?) ?? '';
    
    Map<String, dynamic>? content;
    final rawContent = json['content'];
    try {
      if (rawContent is Map<String, dynamic>) {
        content = rawContent;
      } else if (rawContent is Map) {
        content = rawContent.cast<String, dynamic>();
      } else if (rawContent is String) {
        content = jsonDecode(rawContent) as Map<String, dynamic>;
      } else {
        content = const <String, dynamic>{};
      }
    } catch (e) {
      debugPrint('Article content parse failed: $e');
      content = const <String, dynamic>{};
    }

    final title = (json['title'] as String?) ?? (content['title'] as String?) ?? '';

    final rawCategory = json['category'] ?? content['category'];
    List<String> categoryPath = [];
    if (rawCategory is List) {
      categoryPath = rawCategory.map((e) => e.toString()).toList();
    } else if (rawCategory is String && rawCategory.trim().isNotEmpty) {
      final sub = json['subcategory'] as String? ?? content['subcategory'] as String?;
      categoryPath = _mapOldCategory(rawCategory.trim(), sub);
    } else {
      categoryPath = const ['General'];
    }

    final imageUrl = (json['image_url'] as String?) ?? (json['imageUrl'] as String?) ?? (content['image_url'] as String?);
    final videoUrl = (json['video_url'] as String?) ?? (json['videoUrl'] as String?) ?? (content['video_url'] as String?);
    final isHighYield = (json['is_high_yield'] as bool?) ?? (json['isHighYield'] as bool?) ?? (content['is_high_yield'] as bool?) ?? false;

    return Article(
      id: id,
      title: title,
      category: categoryPath,
      content: content,
      imageUrl: imageUrl,
      videoUrl: videoUrl,
      isHighYield: isHighYield,
    );
  }

  /// Serializes back to the canonical nested shape.
  ///
  /// `category` is always emitted as a JSON array (the path), which is exactly
  /// the array form `fromJson` accepts. The denormalized `subcategory` is
  /// included for backward-compat with older consumers that read a flat
  /// `subcategory` field. Round-trips with [fromJson] for 1-, 2-, and 3+-level
  /// paths as well as legacy string rows.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'content': content ?? const <String, dynamic>{},
      'image_url': imageUrl,
      'video_url': videoUrl,
      'is_high_yield': isHighYield,
      'subcategory': subcategory,
    };
  }

  static List<String> _mapOldCategory(String cat, String? sub) {
    if (sub != null && sub.isNotEmpty) {
      return [cat, sub];
    }
    final parent = AppConfig.categoryToParent[cat];
    if (parent != null) {
      return [parent, cat];
    }
    return [cat];
  }
}
