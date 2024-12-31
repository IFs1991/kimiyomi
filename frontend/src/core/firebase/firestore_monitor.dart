import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';

class FirestoreMonitor {
  static final FirebasePerformance _performance = FirebasePerformance.instance;
  static final Map<String, Trace> _activeTraces = {};
  static final Map<String, int> _queryStats = {};
  static final Map<String, List<int>> _queryTimes = {};

  // クエリパフォーマンスの追跡開始
  static void startQueryTrace(String queryName) {
    if (kDebugMode) return;

    final trace = _performance.newTrace('firestore_query_$queryName');
    trace.start();
    _activeTraces[queryName] = trace;

    // クエリ統計の初期化
    _queryStats[queryName] = (_queryStats[queryName] ?? 0) + 1;
    _queryTimes[queryName] = _queryTimes[queryName] ?? [];
  }

  // クエリパフォーマンスの追跡終了
  static Future<void> stopQueryTrace(String queryName, {
    bool success = true,
    int? documentCount,
    String? errorMessage,
  }) async {
    if (kDebugMode) return;

    final trace = _activeTraces[queryName];
    if (trace == null) return;

    // 実行時間の記録
    final executionTime = trace.getAttribute('execution_time');
    if (executionTime != null) {
      _queryTimes[queryName]?.add(int.parse(executionTime));
    }

    // 基本メトリクスの記録
    trace.putAttribute('success', success.toString());
    if (documentCount != null) {
      trace.putMetric('document_count', documentCount);
    }
    if (errorMessage != null) {
      trace.putAttribute('error_message', errorMessage);
    }

    // 統計情報の記録
    final stats = _calculateQueryStats(queryName);
    trace.setMetric('avg_execution_time', stats['avgExecutionTime']?.toInt() ?? 0);
    trace.setMetric('total_executions', stats['totalExecutions']?.toInt() ?? 0);
    trace.setMetric('error_rate', stats['errorRate']?.toInt() ?? 0);

    await trace.stop();
    _activeTraces.remove(queryName);
  }

  // クエリ統計の計算
  static Map<String, double> _calculateQueryStats(String queryName) {
    final times = _queryTimes[queryName] ?? [];
    if (times.isEmpty) return {};

    final avgExecutionTime = times.reduce((a, b) => a + b) / times.length;
    final totalExecutions = _queryStats[queryName] ?? 0;
    final errorRate = _calculateErrorRate(queryName);

    return {
      'avgExecutionTime': avgExecutionTime,
      'totalExecutions': totalExecutions.toDouble(),
      'errorRate': errorRate,
    };
  }

  // エラー率の計算
  static double _calculateErrorRate(String queryName) {
    final total = _queryStats[queryName] ?? 0;
    if (total == 0) return 0.0;

    final errors = _activeTraces[queryName]
        ?.getAttribute('error_count')
        ?.toString() ?? '0';
    return int.parse(errors) / total * 100;
  }

  // バッチ処理のパフォーマンス追跡
  static void trackBatchOperation(String operationType, int documentCount) {
    if (kDebugMode) return;

    final metric = _performance.newTrace('firestore_batch_$operationType');
    metric.setMetric('document_count', documentCount);
    metric.setMetric('batch_size', documentCount);
    metric.putAttribute('operation_type', operationType);
    metric.start();
  }

  // キャッシュヒット率の追跡
  static void trackCacheHit(bool isHit) {
    if (kDebugMode) return;

    final metric = _performance.newTrace('firestore_cache_hit');
    metric.putAttribute('cache_hit', isHit.toString());
    _updateCacheHitRate(isHit);
    metric.start();
  }

  // キャッシュヒット率の更新
  static void _updateCacheHitRate(bool isHit) {
    final trace = _performance.newTrace('firestore_cache_stats');
    final totalRequests = int.parse(
      trace.getAttribute('total_requests') ?? '0'
    ) + 1;
    final cacheHits = int.parse(
      trace.getAttribute('cache_hits') ?? '0'
    ) + (isHit ? 1 : 0);

    trace.putAttribute('total_requests', totalRequests.toString());
    trace.putAttribute('cache_hits', cacheHits.toString());
    trace.setMetric('cache_hit_rate', ((cacheHits / totalRequests) * 100).toInt());
  }

  // ネットワーク使用量の追跡
  static void trackNetworkUsage(int bytesSent, int bytesReceived) {
    if (kDebugMode) return;

    final metric = _performance.newTrace('firestore_network_usage');
    metric.setMetric('bytes_sent', bytesSent);
    metric.setMetric('bytes_received', bytesReceived);
    metric.setMetric('total_bytes', bytesSent + bytesReceived);
    metric.start();
  }

  // オフライン操作の追跡
  static void trackOfflineOperation(String operationType) {
    if (kDebugMode) return;

    final metric = _performance.newTrace('firestore_offline_operation');
    metric.putAttribute('operation_type', operationType);
    metric.putAttribute('timestamp', DateTime.now().toIso8601String());
    metric.start();

    _updateOfflineStats(operationType);
  }

  // オフライン統計の更新
  static void _updateOfflineStats(String operationType) {
    final trace = _performance.newTrace('firestore_offline_stats');
    final count = int.parse(
      trace.getAttribute('${operationType}_count') ?? '0'
    ) + 1;
    trace.putAttribute('${operationType}_count', count.toString());
  }

  // エラー追跡
  static void trackError(String errorType, String errorMessage) {
    if (kDebugMode) return;

    final metric = _performance.newTrace('firestore_error');
    metric.putAttribute('error_type', errorType);
    metric.putAttribute('error_message', errorMessage);
    metric.putAttribute('timestamp', DateTime.now().toIso8601String());
    metric.start();

    _updateErrorStats(errorType);
  }

  // エラー統計の更新
  static void _updateErrorStats(String errorType) {
    final trace = _performance.newTrace('firestore_error_stats');
    final count = int.parse(
      trace.getAttribute('${errorType}_count') ?? '0'
    ) + 1;
    trace.putAttribute('${errorType}_count', count.toString());
  }

  // インデックス使用状況の追跡
  static void trackIndexUsage(String queryPath, bool usedIndex) {
    if (kDebugMode) return;

    final metric = _performance.newTrace('firestore_index_usage');
    metric.putAttribute('query_path', queryPath);
    metric.putAttribute('used_index', usedIndex.toString());
    metric.putAttribute('timestamp', DateTime.now().toIso8601String());
    metric.start();

    _updateIndexStats(queryPath, usedIndex);
  }

  // インデックス統計の更新
  static void _updateIndexStats(String queryPath, bool usedIndex) {
    final trace = _performance.newTrace('firestore_index_stats');
    final totalQueries = int.parse(
      trace.getAttribute('${queryPath}_total') ?? '0'
    ) + 1;
    final indexedQueries = int.parse(
      trace.getAttribute('${queryPath}_indexed') ?? '0'
    ) + (usedIndex ? 1 : 0);

    trace.putAttribute('${queryPath}_total', totalQueries.toString());
    trace.putAttribute('${queryPath}_indexed', indexedQueries.toString());
    trace.setMetric(
      '${queryPath}_index_usage_rate',
      ((indexedQueries / totalQueries) * 100).toInt()
    );
  }

  // クエリ実行時間の追跡
  static Stopwatch trackQueryExecutionTime() {
    return Stopwatch()..start();
  }

  // メモリ使用量の追跡
  static void trackMemoryUsage() {
    if (kDebugMode) return;

    final metric = _performance.newTrace('firestore_memory_usage');
    metric.putAttribute('timestamp', DateTime.now().toIso8601String());
    metric.start();
  }

  // パフォーマンスレポートの生成
  static Map<String, dynamic> generatePerformanceReport() {
    return {
      'queries': _generateQueryReport(),
      'cache': _generateCacheReport(),
      'network': _generateNetworkReport(),
      'errors': _generateErrorReport(),
      'indexes': _generateIndexReport(),
    };
  }

  // クエリレポートの生成
  static Map<String, dynamic> _generateQueryReport() {
    final report = <String, dynamic>{};
    _queryStats.forEach((queryName, count) {
      final stats = _calculateQueryStats(queryName);
      report[queryName] = {
        'totalExecutions': count,
        'averageExecutionTime': stats['avgExecutionTime'],
        'errorRate': stats['errorRate'],
      };
    });
    return report;
  }

  // キャッシュレポートの生成
  static Map<String, dynamic> _generateCacheReport() {
    final trace = _performance.newTrace('firestore_cache_stats');
    final totalRequests = int.parse(trace.getAttribute('total_requests') ?? '0');
    final cacheHits = int.parse(trace.getAttribute('cache_hits') ?? '0');

    return {
      'totalRequests': totalRequests,
      'cacheHits': cacheHits,
      'hitRate': totalRequests > 0 ? (cacheHits / totalRequests) * 100 : 0,
    };
  }

  // ネットワークレポートの生成
  static Map<String, dynamic> _generateNetworkReport() {
    final trace = _performance.newTrace('firestore_network_usage');
    return {
      'totalBytesSent': trace.getMetric('bytes_sent') ?? 0,
      'totalBytesReceived': trace.getMetric('bytes_received') ?? 0,
    };
  }

  // エラーレポートの生成
  static Map<String, dynamic> _generateErrorReport() {
    final trace = _performance.newTrace('firestore_error_stats');
    final report = <String, dynamic>{};
    trace.getAttributes().forEach((key, value) {
      if (key.endsWith('_count')) {
        final errorType = key.replaceAll('_count', '');
        report[errorType] = int.parse(value);
      }
    });
    return report;
  }

  // インデックスレポートの生成
  static Map<String, dynamic> _generateIndexReport() {
    final trace = _performance.newTrace('firestore_index_stats');
    final report = <String, dynamic>{};
    trace.getAttributes().forEach((key, value) {
      if (key.endsWith('_total')) {
        final queryPath = key.replaceAll('_total', '');
        final total = int.parse(value);
        final indexed = int.parse(
          trace.getAttribute('${queryPath}_indexed') ?? '0'
        );
        report[queryPath] = {
          'totalQueries': total,
          'indexedQueries': indexed,
          'indexUsageRate': total > 0 ? (indexed / total) * 100 : 0,
        };
      }
    });
    return report;
  }
}