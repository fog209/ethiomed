class Flowchart {
  const Flowchart({
    required this.id,
    required this.title,
    this.specialty,
    required this.imageUrl,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String? specialty;
  final String imageUrl;
  final DateTime createdAt;

  factory Flowchart.fromJson(Map<String, dynamic> json) {
    return Flowchart(
      id: json['id'] as String,
      title: json['title'] as String,
      specialty: json['specialty'] as String?,
      imageUrl: json['image_url'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class LocalGuideline {
  const LocalGuideline({
    required this.id,
    required this.title,
    this.description,
    required this.fileUrl,
    this.fileType,
    this.specialty,
    required this.uploadedAt,
  });

  final String id;
  final String title;
  final String? description;
  final String fileUrl;
  final String? fileType;
  final String? specialty;
  final DateTime uploadedAt;

  factory LocalGuideline.fromJson(Map<String, dynamic> json) {
    return LocalGuideline(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      fileUrl: json['file_url'] as String,
      fileType: json['file_type'] as String?,
      specialty: json['specialty'] as String?,
      uploadedAt: DateTime.parse(json['uploaded_at'] as String),
    );
  }
}
