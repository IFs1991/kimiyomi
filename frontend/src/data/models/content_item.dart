class ContentItem {
  final String id;
  final String title;
  final String description;
  final String type;
  final String content;
  final List<String> tags;
  final bool isPremium;
  final double price;
  final DateTime publishedAt;
  final DateTime? updatedAt;

  ContentItem({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.content,
    required this.tags,
    required this.isPremium,
    required this.price,
    required this.publishedAt,
    this.updatedAt,
  });

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    return ContentItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      content: json['content'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      isPremium: json['isPremium'] as bool,
      price: (json['price'] as num).toDouble(),
      publishedAt: DateTime.parse(json['publishedAt'] as String),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'content': content,
      'tags': tags,
      'isPremium': isPremium,
      'price': price,
      'publishedAt': publishedAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}