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

  const ContentItem({
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
}