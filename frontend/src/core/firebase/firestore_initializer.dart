import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

class FirestoreInitializer {
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Firestoreの設定
    FirebaseFirestore.instance.settings = Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      sslEnabled: true,
    );

    // インデックスの最適化
    await _configureIndexes();

    // オフラインサポートの有効化
    await _enableOfflineSupport();
  }

  static Future<void> _configureIndexes() async {
    // 頻繁に使用されるクエリのインデックス設定
    final db = FirebaseFirestore.instance;

    // ユーザーコレクションのインデックス
    await db.collection('users')
        .orderBy('lastActive', descending: true)
        .limit(1)
        .get();

    // コンテンツコレクションのインデックス
    await db.collection('contents')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    // 診断結果コレクションのインデックス
    await db.collection('diagnosis_results')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();
  }

  static Future<void> _enableOfflineSupport() async {
    await FirebaseFirestore.instance.enablePersistence(
      const PersistenceSettings(
        synchronizeTabs: true,
      ),
    );

    // 重要なコレクションのオフラインキャッシュを設定
    final collections = [
      'users',
      'contents',
      'diagnosis_results',
      'compatibility_results',
    ];

    for (final collection in collections) {
      await FirebaseFirestore.instance
          .collection(collection)
          .limit(100)
          .get(const GetOptions(source: Source.server));
    }
  }
}