import '../entities/content_item.dart';

abstract class ContentRepository {
  Future<List<ContentItem>> getContentItems({
    String? type,
    List<String>? tags,
    bool? isPremium,
    int? limit,
    int? offset,
  });
  Future<ContentItem> getContentItem(String contentId);
  Future<List<ContentItem>> searchContent(String query);
  Future<void> createContentItem(ContentItem item);
  Future<void> updateContentItem(String contentId, ContentItem item);
  Future<void> deleteContentItem(String contentId);
  Future<List<ContentItem>> getRecommendedContent(String userId);
}