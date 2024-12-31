import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_monitor.dart';

class FirestoreIndexes {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // コレクション毎のインデックス設定
  static Future<void> configureIndexes() async {
    await Future.wait([
      _configureUserIndexes(),
      _configureContentIndexes(),
      _configureDiagnosisIndexes(),
      _configureCompatibilityIndexes(),
      _configureMessageIndexes(),
    ]);
  }

  // ユーザーコレクションのインデックス
  static Future<void> _configureUserIndexes() async {
    FirestoreMonitor.trackIndexUsage('users', true);

    // アクティブユーザー検索用インデックス
    await _firestore.collection('users')
        .where('status', isEqualTo: 'active')
        .orderBy('lastActive', descending: true)
        .limit(1)
        .get();

    // マッチング用インデックス（複合）
    await _firestore.collection('users')
        .where('interests', arrayContains: 'any')
        .where('status', isEqualTo: 'active')
        .orderBy('matchScore', descending: true)
        .limit(1)
        .get();

    // フォロワー検索用インデックス
    await _firestore.collection('users')
        .where('followers', arrayContains: 'any')
        .orderBy('lastActive', descending: true)
        .limit(1)
        .get();
  }

  // コンテンツコレクションのインデックス
  static Future<void> _configureContentIndexes() async {
    FirestoreMonitor.trackIndexUsage('contents', true);

    // 最新コンテンツ検索用インデックス
    await _firestore.collection('contents')
        .where('status', isEqualTo: 'published')
        .orderBy('publishedAt', descending: true)
        .limit(1)
        .get();

    // 人気コンテンツ検索用インデックス
    await _firestore.collection('contents')
        .where('status', isEqualTo: 'published')
        .orderBy('viewCount', descending: true)
        .limit(1)
        .get();

    // カテゴリ別人気コンテンツ用インデックス
    await _firestore.collection('contents')
        .where('category', isEqualTo: 'any')
        .where('status', isEqualTo: 'published')
        .orderBy('rating', descending: true)
        .limit(1)
        .get();
  }

  // 診断結果コレクションのインデックス
  static Future<void> _configureDiagnosisIndexes() async {
    FirestoreMonitor.trackIndexUsage('diagnosis_results', true);

    // ユーザー別診断履歴用インデックス
    await _firestore.collection('diagnosis_results')
        .where('userId', isEqualTo: 'any')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    // 診断タイプ別ランキング用インデックス
    await _firestore.collection('diagnosis_results')
        .where('type', isEqualTo: 'any')
        .where('status', isEqualTo: 'published')
        .orderBy('score', descending: true)
        .limit(1)
        .get();

    // 期間別診断統計用インデックス
    await _firestore.collection('diagnosis_results')
        .where('createdAt', isGreaterThanOrEqualTo: DateTime.now())
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();
  }

  // 相性診断コレクションのインデックス
  static Future<void> _configureCompatibilityIndexes() async {
    FirestoreMonitor.trackIndexUsage('compatibility_results', true);

    // ユーザー別相性診断履歴用インデックス
    await _firestore.collection('compatibility_results')
        .where('userId', isEqualTo: 'any')
        .orderBy('matchScore', descending: true)
        .limit(1)
        .get();

    // 高相性ユーザー検索用インデックス
    await _firestore.collection('compatibility_results')
        .where('matchScore', isGreaterThanOrEqualTo: 80)
        .orderBy('matchScore', descending: true)
        .limit(1)
        .get();
  }

  // メッセージコレクションのインデックス
  static Future<void> _configureMessageIndexes() async {
    FirestoreMonitor.trackIndexUsage('messages', true);

    // メャット履歴検索用インデックス
    await _firestore.collection('messages')
        .where('chatId', isEqualTo: 'any')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    // 未読メッセージ検索用インデックス
    await _firestore.collection('messages')
        .where('receiverId', isEqualTo: 'any')
        .where('status', isEqualTo: 'unread')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    // グループメッセージ検索用インデックス
    await _firestore.collection('messages')
        .where('type', isEqualTo: 'group')
        .where('participants', arrayContains: 'any')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();
  }

  // インデックス使用状況の分析
  static Future<void> analyzeIndexUsage() async {
    final collections = [
      'users',
      'contents',
      'diagnosis_results',
      'compatibility_results',
      'messages',
    ];

    for (final collection in collections) {
      final snapshot = await _firestore.collection(collection)
          .limit(1)
          .get();

      FirestoreMonitor.trackIndexUsage(
        collection,
        snapshot.metadata.isFromCache == false,
      );
    }
  }
}