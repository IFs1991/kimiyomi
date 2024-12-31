import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../firebase/firestore_service.dart';

// FirestoreServiceのプロバイダー
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

// ユーザーデータのキャッシュプロバイダー
final userCacheProvider = StateProvider<Map<String, dynamic>>((ref) {
  return {};
});

// コンテンツデータのキャッシュプロバイダー
final contentCacheProvider = StateProvider<Map<String, dynamic>>((ref) {
  return {};
});

// 診断結果のキャッシュプロバイダー
final diagnosisResultCacheProvider = StateProvider<Map<String, dynamic>>((ref) {
  return {};
});

// 相性診断結果のキャッシュプロバイダー
final compatibilityResultCacheProvider = StateProvider<Map<String, dynamic>>((ref) {
  return {};
});

// オフラインデータ同期状態のプロバイダー
final offlineSyncStateProvider = StateProvider<bool>((ref) {
  return false;
});

// データ更新キューのプロバイダー
final updateQueueProvider = StateProvider<List<Map<String, dynamic>>>((ref) {
  return [];
});

// バッチ処理状態のプロバイダー
final batchProcessingProvider = StateProvider<bool>((ref) {
  return false;
});

// キャッシュ制御プロバイダー
final cacheControlProvider = Provider((ref) {
  return CacheController(ref);
});

class CacheController {
  final Ref _ref;

  CacheController(this._ref);

  // キャッシュの更新
  void updateCache(String type, String id, Map<String, dynamic> data) {
    switch (type) {
      case 'user':
        final cache = _ref.read(userCacheProvider);
        cache[id] = data;
        _ref.read(userCacheProvider.notifier).state = Map.from(cache);
        break;
      case 'content':
        final cache = _ref.read(contentCacheProvider);
        cache[id] = data;
        _ref.read(contentCacheProvider.notifier).state = Map.from(cache);
        break;
      case 'diagnosis':
        final cache = _ref.read(diagnosisResultCacheProvider);
        cache[id] = data;
        _ref.read(diagnosisResultCacheProvider.notifier).state = Map.from(cache);
        break;
      case 'compatibility':
        final cache = _ref.read(compatibilityResultCacheProvider);
        cache[id] = data;
        _ref.read(compatibilityResultCacheProvider.notifier).state = Map.from(cache);
        break;
    }
  }

  // キャッシュのクリア
  void clearCache(String type) {
    switch (type) {
      case 'user':
        _ref.read(userCacheProvider.notifier).state = {};
        break;
      case 'content':
        _ref.read(contentCacheProvider.notifier).state = {};
        break;
      case 'diagnosis':
        _ref.read(diagnosisResultCacheProvider.notifier).state = {};
        break;
      case 'compatibility':
        _ref.read(compatibilityResultCacheProvider.notifier).state = {};
        break;
      case 'all':
        _ref.read(userCacheProvider.notifier).state = {};
        _ref.read(contentCacheProvider.notifier).state = {};
        _ref.read(diagnosisResultCacheProvider.notifier).state = {};
        _ref.read(compatibilityResultCacheProvider.notifier).state = {};
        break;
    }
  }

  // 更新キューの管理
  void addToUpdateQueue(Map<String, dynamic> update) {
    final queue = _ref.read(updateQueueProvider);
    queue.add(update);
    _ref.read(updateQueueProvider.notifier).state = List.from(queue);
  }

  // バッチ処理の実行
  Future<void> processBatchUpdates() async {
    if (_ref.read(batchProcessingProvider)) return;

    _ref.read(batchProcessingProvider.notifier).state = true;
    try {
      final queue = _ref.read(updateQueueProvider);
      if (queue.isEmpty) return;

      final firestoreService = _ref.read(firestoreServiceProvider);
      await firestoreService.optimizedBatchWrite(
        documents: queue,
        collectionPath: queue.first['collection'] as String,
      );

      _ref.read(updateQueueProvider.notifier).state = [];
    } finally {
      _ref.read(batchProcessingProvider.notifier).state = false;
    }
  }
}