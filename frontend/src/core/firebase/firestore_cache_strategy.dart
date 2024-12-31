import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_monitor.dart';

class FirestoreCacheStrategy {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // キャッシュ設定の初期化
  static Future<void> initialize() async {
    await _firestore.settings.persistenceEnabled;
    await _firestore.enableNetwork();

    // オフラインパーシステンスの有効化と最適化
    await _firestore.enablePersistence(
      const PersistenceSettings(synchronizeTabs: true),
    );

    // キャッシュサイズの設定
    _firestore.settings = const Settings(
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      persistenceEnabled: true,
      sslEnabled: true,
    );
  }

  // キャッシュ優先度の設定
  static Source getCacheStrategy(String collectionPath) {
    // 高頻度アクセスコレクション（キャッシュ優先）
    final highPriorityCollections = [
      'users',
      'contents',
      'messages',
      'system_settings',
    ];

    // 中頻度アクセスコレクション（キャッシュ＆サーバー）
    final mediumPriorityCollections = [
      'diagnosis_results',
      'compatibility_results',
      'notifications',
    ];

    // 低頻度アクセスコレクション（サーバー優先）
    final lowPriorityCollections = [
      'analytics',
      'logs',
      'temp_data',
    ];

    if (highPriorityCollections.contains(collectionPath)) {
      FirestoreMonitor.trackCacheHit(true);
      return Source.cache;
    } else if (mediumPriorityCollections.contains(collectionPath)) {
      FirestoreMonitor.trackCacheHit(true);
      return Source.serverAndCache;
    } else if (lowPriorityCollections.contains(collectionPath)) {
      FirestoreMonitor.trackCacheHit(false);
      return Source.server;
    } else {
      FirestoreMonitor.trackCacheHit(false);
      return Source.serverAndCache;
    }
  }

  // スマートプリフェッチ戦略
  static Future<void> prefetchData(String userId) async {
    await Future.wait([
      _prefetchUserData(userId),
      _prefetchContentData(),
      _prefetchSystemSettings(),
      _prefetchRecentMessages(userId),
    ]);
  }

  // ユーザーデータのスマートプリフェッチ
  static Future<void> _prefetchUserData(String userId) async {
    FirestoreMonitor.startQueryTrace('prefetch_user_data');

    try {
      // ユーザー本人のデータ
      await _firestore.collection('users').doc(userId).get(
        const GetOptions(source: Source.server)
      );

      // フォロー中のユーザーデータ
      await _firestore.collection('users')
          .where('followers', arrayContains: userId)
          .limit(20)
          .get(const GetOptions(source: Source.server));

      FirestoreMonitor.stopQueryTrace('prefetch_user_data',
        success: true,
        documentCount: 21
      );
    } catch (e) {
      FirestoreMonitor.stopQueryTrace('prefetch_user_data',
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  // コンテンツデータのスマートプリフェッチ
  static Future<void> _prefetchContentData() async {
    FirestoreMonitor.startQueryTrace('prefetch_content_data');

    try {
      // 最新のコンテンツ
      await _firestore.collection('contents')
          .where('status', isEqualTo: 'published')
          .orderBy('publishedAt', descending: true)
          .limit(10)
          .get(const GetOptions(source: Source.server));

      // 人気のコンテンツ
      await _firestore.collection('contents')
          .where('status', isEqualTo: 'published')
          .orderBy('viewCount', descending: true)
          .limit(10)
          .get(const GetOptions(source: Source.server));

      FirestoreMonitor.stopQueryTrace('prefetch_content_data',
        success: true,
        documentCount: 20
      );
    } catch (e) {
      FirestoreMonitor.stopQueryTrace('prefetch_content_data',
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  // システム設定のスマートプリフェッチ
  static Future<void> _prefetchSystemSettings() async {
    FirestoreMonitor.startQueryTrace('prefetch_system_settings');

    try {
      await _firestore.collection('system_settings')
          .where('status', isEqualTo: 'active')
          .get(const GetOptions(source: Source.server));

      FirestoreMonitor.stopQueryTrace('prefetch_system_settings', success: true);
    } catch (e) {
      FirestoreMonitor.stopQueryTrace('prefetch_system_settings',
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  // 最近のメッセージのプリフェッチ
  static Future<void> _prefetchRecentMessages(String userId) async {
    FirestoreMonitor.startQueryTrace('prefetch_recent_messages');

    try {
      await _firestore.collection('messages')
          .where('participants', arrayContains: userId)
          .orderBy('timestamp', descending: true)
          .limit(20)
          .get(const GetOptions(source: Source.server));

      FirestoreMonitor.stopQueryTrace('prefetch_recent_messages', success: true);
    } catch (e) {
      FirestoreMonitor.stopQueryTrace('prefetch_recent_messages',
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  // インテリジェントキャッシュクリア
  static Future<void> clearCache({
    bool clearAll = false,
    List<String>? collections,
    Duration? olderThan,
  }) async {
    if (clearAll) {
      await _firestore.clearPersistence();
      return;
    }

    if (collections != null) {
      for (final collection in collections) {
        final query = _firestore.collection(collection);

        if (olderThan != null) {
          final threshold = DateTime.now().subtract(olderThan);
          await query
              .where('updatedAt', isLessThan: threshold)
              .get()
              .then((snapshot) {
            for (final doc in snapshot.docs) {
              _firestore.doc(doc.reference.path).delete();
            }
          });
        } else {
          await query.get().then((snapshot) {
            for (final doc in snapshot.docs) {
              _firestore.doc(doc.reference.path).delete();
            }
          });
        }
      }
    }
  }

  // スマートオフライン操作の管理
  static Future<void> handleOfflineOperation({
    required String operation,
    required String collectionPath,
    required Map<String, dynamic> data,
    Map<String, dynamic>? metadata,
  }) async {
    FirestoreMonitor.trackOfflineOperation(operation);

    final timestamp = FieldValue.serverTimestamp();
    final metadataWithDefaults = {
      'deviceId': 'device_id',
      'networkType': 'offline',
      'appVersion': '1.0.0',
      ...?metadata,
    };

    switch (operation) {
      case 'create':
        await _firestore.collection(collectionPath).add({
          ...data,
          'createdAt': timestamp,
          'updatedAt': timestamp,
          'syncStatus': 'pending',
          'metadata': metadataWithDefaults,
        });
        break;
      case 'update':
        await _firestore.doc(collectionPath).update({
          ...data,
          'updatedAt': timestamp,
          'syncStatus': 'pending',
          'metadata': metadataWithDefaults,
        });
        break;
      case 'delete':
        await _firestore.doc(collectionPath).update({
          'deletedAt': timestamp,
          'syncStatus': 'pending_deletion',
          'metadata': metadataWithDefaults,
        });
        break;
    }
  }
}