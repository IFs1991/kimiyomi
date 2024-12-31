import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_monitor.dart';
import 'firestore_cache_strategy.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const int _maxBatchSize = 500;

  // スマートバッチ取得
  Future<List<T>> optimizedBatchGet<T>({
    required String collectionPath,
    int batchSize = 10,
    required T Function(Map<String, dynamic>) fromJson,
    Map<String, dynamic>? whereConditions,
    List<String>? orderBy,
    bool descending = false,
  }) async {
    try {
      FirestoreMonitor.startQueryTrace('batch_get_$collectionPath');

      Query<Map<String, dynamic>> query = _firestore.collection(collectionPath);

      // クエリ条件の適用
      if (whereConditions != null) {
        whereConditions.forEach((field, value) {
          query = query.where(field, isEqualTo: value);
        });
      }

      // ソート条件の適用
      if (orderBy != null) {
        for (final field in orderBy) {
          query = query.orderBy(field, descending: descending);
        }
      }

      // バッチサイズの適用
      query = query.limit(batchSize);

      // キャッシュ戦略の適用
      final source = FirestoreCacheStrategy.getCacheStrategy(collectionPath);
      final snapshot = await query.get(GetOptions(source: source));

      FirestoreMonitor.stopQueryTrace(
        'batch_get_$collectionPath',
        success: true,
        documentCount: snapshot.docs.length,
      );

      return snapshot.docs
          .map((doc) => fromJson(doc.data()))
          .toList();
    } catch (e) {
      FirestoreMonitor.stopQueryTrace(
        'batch_get_$collectionPath',
        success: false,
        errorMessage: e.toString(),
      );
      throw Exception('Firestoreからのデータ取得に失敗しました: $e');
    }
  }

  // スマートストリーム
  Stream<List<T>> optimizedStream<T>({
    required String collectionPath,
    required T Function(Map<String, dynamic>) fromJson,
    Map<String, dynamic>? whereConditions,
    List<String>? orderBy,
    bool descending = false,
    int? limit,
  }) {
    Query<Map<String, dynamic>> query = _firestore.collection(collectionPath);

    // クエリ条件の適用
    if (whereConditions != null) {
      whereConditions.forEach((field, value) {
        query = query.where(field, isEqualTo: value);
      });
    }

    // ソート条件の適用
    if (orderBy != null) {
      for (final field in orderBy) {
        query = query.orderBy(field, descending: descending);
      }
    }

    // 制限の適用
    if (limit != null) {
      query = query.limit(limit);
    }

    return query
        .snapshots()
        .map((snapshot) {
          FirestoreMonitor.trackCacheHit(snapshot.metadata.isFromCache);
          return snapshot.docs
              .map((doc) => fromJson(doc.data()))
              .toList();
        });
  }

  // スマートクエリ最適化
  Query<Map<String, dynamic>> optimizeQuery({
    required String collectionPath,
    List<String>? orderBy,
    List<Map<String, dynamic>>? whereConditions,
    int? limit,
    bool descending = false,
  }) {
    Query<Map<String, dynamic>> query = _firestore.collection(collectionPath);

    // WHERE条件の最適化（複合インデックスを考慮）
    if (whereConditions != null) {
      // 等価条件を先に適用
      final equalityConditions = whereConditions
          .where((condition) => condition['operator'] == '==');
      for (final condition in equalityConditions) {
        query = query.where(
          condition['field'] as String,
          isEqualTo: condition['value'],
        );
      }

      // 範囲条件を後に適用
      final rangeConditions = whereConditions
          .where((condition) => condition['operator'] != '==');
      for (final condition in rangeConditions) {
        final operator = condition['operator'] as String;
        final field = condition['field'] as String;
        final value = condition['value'];

        switch (operator) {
          case '>':
            query = query.where(field, isGreaterThan: value);
            break;
          case '>=':
            query = query.where(field, isGreaterThanOrEqualTo: value);
            break;
          case '<':
            query = query.where(field, isLessThan: value);
            break;
          case '<=':
            query = query.where(field, isLessThanOrEqualTo: value);
            break;
          case 'array-contains':
            query = query.where(field, arrayContains: value);
            break;
          case 'in':
            query = query.where(field, whereIn: value as List);
            break;
        }
      }
    }

    // ソート順の最適化
    if (orderBy != null) {
      for (final field in orderBy) {
        query = query.orderBy(field, descending: descending);
      }
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    return query;
  }

  // スマートバッチ書き込み
  Future<void> optimizedBatchWrite({
    required List<Map<String, dynamic>> documents,
    required String collectionPath,
    bool merge = false,
  }) async {
    try {
      FirestoreMonitor.startQueryTrace('batch_write_$collectionPath');
      final timestamp = FieldValue.serverTimestamp();

      for (var i = 0; i < documents.length; i += _maxBatchSize) {
        final batch = _firestore.batch();
        final end = (i + _maxBatchSize < documents.length)
            ? i + _maxBatchSize
            : documents.length;

        for (var j = i; j < end; j++) {
          final doc = {
            ...documents[j],
            'updatedAt': timestamp,
          };
          final ref = _firestore.collection(collectionPath).doc();

          if (merge) {
            batch.set(ref, doc, SetOptions(merge: true));
          } else {
            batch.set(ref, doc);
          }
        }

        await batch.commit();
      }

      FirestoreMonitor.stopQueryTrace(
        'batch_write_$collectionPath',
        success: true,
        documentCount: documents.length,
      );
    } catch (e) {
      FirestoreMonitor.stopQueryTrace(
        'batch_write_$collectionPath',
        success: false,
        errorMessage: e.toString(),
      );
      throw Exception('バッチ書き込みに失敗しました: $e');
    }
  }

  // トランザクション最適化
  Future<T> optimizedTransaction<T>({
    required Future<T> Function(Transaction) transactionHandler,
    int maxAttempts = 5,
  }) async {
    int attempts = 0;
    while (true) {
      try {
        attempts++;
        return await _firestore.runTransaction(transactionHandler);
      } catch (e) {
        if (attempts >= maxAttempts) {
          throw Exception('トランザクションが失敗しました: $e');
        }
        // 指数バックオフ
        await Future.delayed(Duration(milliseconds: (1 << attempts) * 100));
      }
    }
  }

  // ページネーション最適化
  Future<QuerySnapshot<Map<String, dynamic>>> optimizedPagination({
    required String collectionPath,
    required int pageSize,
    DocumentSnapshot? lastDocument,
    Map<String, dynamic>? whereConditions,
    List<String>? orderBy,
    bool descending = false,
  }) async {
    try {
      Query<Map<String, dynamic>> query = optimizeQuery(
        collectionPath: collectionPath,
        whereConditions: whereConditions != null ? [whereConditions] : null,
        orderBy: orderBy,
        limit: pageSize,
        descending: descending,
      );

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      return await query.get();
    } catch (e) {
      throw Exception('ページネーションの取得に失敗しました: $e');
    }
  }
}