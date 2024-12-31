import '../domain/entities/content_item.dart';
import '../domain/repositories/content_repository.dart';

class ContentService {
  final ContentRepository _contentRepository;

  ContentService(this._contentRepository);

  Future<List<ContentItem>> getContentItems({
    String? type,
    List<String>? tags,
    bool? isPremium,
    int? limit,
    int? offset,
  }) {
    return _contentRepository.getContentItems(
      type: type,
      tags: tags,
      isPremium: isPremium,
      limit: limit,
      offset: offset,
    );
  }

  Future<ContentItem> getContentItem(String contentId) {
    return _contentRepository.getContentItem(contentId);
  }

  Future<List<ContentItem>> searchContent(String query) {
    return _contentRepository.searchContent(query);
  }

  Future<void> createContentItem(ContentItem item) {
    return _contentRepository.createContentItem(item);
  }

  Future<void> updateContentItem(String contentId, ContentItem item) {
    return _contentRepository.updateContentItem(contentId, item);
  }

  Future<void> deleteContentItem(String contentId) {
    return _contentRepository.deleteContentItem(contentId);
  }

  Future<List<ContentItem>> getRecommendedContent(String userId) {
    return _contentRepository.getRecommendedContent(userId);
  }
}