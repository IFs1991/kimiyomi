import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_client.dart';
import '../domain/entities/compatibility_result.dart' as entities;
import '../data/models/compatibility_result.dart' as models;

final compatibilityServiceProvider = Provider((ref) => CompatibilityService(ApiClient()));

class CompatibilityService {
  final ApiClient _apiClient;

  CompatibilityService(this._apiClient);

  Future<entities.CompatibilityResult> checkCompatibility(String userId) async {
    try {
      final response = await _apiClient.post<models.CompatibilityResult>(
        '${ApiClient.compatibilityEndpoint}/$userId',
        fromJson: (json) => models.CompatibilityResult.fromJson(json),
      );

      if (!response.isSuccess || response.data == null) {
        throw Exception(response.error ?? '相性診断に失敗しました');
      }

      final data = response.data;
      if (data == null) {
        throw Exception('相性診断結果が見つかりませんでした');
      }

      return data.toEntity();
    } catch (e) {
      throw Exception('相性診断中にエラーが発生しました: $e');
    }
  }

  Future<List<entities.CompatibilityResult>> getCompatibilityHistory() async {
    try {
      final response = await _apiClient.get<List<models.CompatibilityResult>>(
        '${ApiClient.compatibilityEndpoint}/history',
        fromJson: (json) => (json['items'] as List<dynamic>)
            .map((item) => models.CompatibilityResult.fromJson(item as Map<String, dynamic>))
            .toList(),
      );

      if (!response.isSuccess || response.data == null) {
        throw Exception(response.error ?? '相性診断履歴の取得に失敗しました');
      }

      final data = response.data;
      if (data == null) {
        throw Exception('相性診断履歴が見つかりませんでした');
      }

      return data.map((d) => d.toEntity()).toList();
    } catch (e) {
      throw Exception('相性診断履歴の取得中にエラーが発生しました: $e');
    }
  }

  Future<void> shareCompatibilityResult(String resultId) async {
    try {
      final response = await _apiClient.post<void>(
        '${ApiClient.compatibilityEndpoint}/results/$resultId/share',
        fromJson: (_) => null,
      );

      if (!response.isSuccess) {
        throw Exception(response.error ?? '相性診断結果の共有に失敗しました');
      }
    } catch (e) {
      throw Exception('相性診断結果の共有中にエラーが発生しました: $e');
    }
  }

  Future<void> deleteCompatibilityResult(String resultId) async {
    try {
      final response = await _apiClient.delete<void>(
        '${ApiClient.compatibilityEndpoint}/results/$resultId',
        fromJson: (_) => null,
      );

      if (!response.isSuccess) {
        throw Exception(response.error ?? '相性診断結果の削除に失敗しました');
      }
    } catch (e) {
      throw Exception('相性診断結果の削除中にエラーが発生しました: $e');
    }
  }
}