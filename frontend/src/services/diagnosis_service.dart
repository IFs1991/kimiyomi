import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_client.dart';
import '../domain/entities/diagnosis.dart' as entities;
import '../domain/entities/diagnosis_result.dart' as entities;
import '../data/models/diagnosis.dart' as models;
import '../data/models/diagnosis_result.dart' as models;

final diagnosisServiceProvider = Provider((ref) => DiagnosisService(ApiClient()));

class DiagnosisService {
  final ApiClient _apiClient;

  DiagnosisService(this._apiClient);

  Future<List<entities.Diagnosis>> getDiagnoses() async {
    try {
      final response = await _apiClient.get<List<models.Diagnosis>>(
        ApiClient.diagnosesEndpoint,
        fromJson: (json) => (json['items'] as List<dynamic>)
            .map((item) => models.Diagnosis.fromJson(item as Map<String, dynamic>))
            .toList(),
      );

      if (response.isSuccess && response.data != null) {
        return response.data.map((d) => d.toEntity()).toList();
      }
      throw Exception(response.error ?? '診断一覧の取得に失敗しました');
    } catch (e) {
      throw Exception('診断一覧の取得中にエラーが発生しました: $e');
    }
  }

  Future<entities.Diagnosis> getDiagnosis(String id) async {
    try {
      final response = await _apiClient.get<models.Diagnosis>(
        '${ApiClient.diagnosesEndpoint}/$id',
        fromJson: (json) => models.Diagnosis.fromJson(json),
      );

      if (response.isSuccess && response.data != null) {
        return response.data.toEntity();
      }
      throw Exception(response.error ?? '診断の取得に失敗しました');
    } catch (e) {
      throw Exception('診断の取得中にエラーが発生しました: $e');
    }
  }

  Future<entities.Diagnosis> createDiagnosis(entities.Diagnosis diagnosis) async {
    try {
      final modelDiagnosis = models.Diagnosis.fromEntity(diagnosis);
      final response = await _apiClient.post<models.Diagnosis>(
        ApiClient.diagnosesEndpoint,
        data: modelDiagnosis.toJson(),
        fromJson: (json) => models.Diagnosis.fromJson(json),
      );

      if (response.isSuccess && response.data != null) {
        return response.data.toEntity();
      }
      throw Exception(response.error ?? '診断の作成に失敗しました');
    } catch (e) {
      throw Exception('診断の作成中にエラーが発生しました: $e');
    }
  }

  Future<entities.Diagnosis> updateDiagnosis(String id, entities.Diagnosis diagnosis) async {
    try {
      final modelDiagnosis = models.Diagnosis.fromEntity(diagnosis);
      final response = await _apiClient.put<models.Diagnosis>(
        '${ApiClient.diagnosesEndpoint}/$id',
        data: modelDiagnosis.toJson(),
        fromJson: (json) => models.Diagnosis.fromJson(json),
      );

      if (response.isSuccess && response.data != null) {
        return response.data.toEntity();
      }
      throw Exception(response.error ?? '診断の更新に失敗しました');
    } catch (e) {
      throw Exception('診断の更新中にエラーが発生しました: $e');
    }
  }

  Future<void> deleteDiagnosis(String id) async {
    try {
      final response = await _apiClient.delete<void>(
        '${ApiClient.diagnosesEndpoint}/$id',
        fromJson: (_) => null,
      );

      if (!response.isSuccess) {
        throw Exception(response.error ?? '診断の削除に失敗しました');
      }
    } catch (e) {
      throw Exception('診断の削除中にエラーが発生しました: $e');
    }
  }

  Future<void> publishDiagnosis(String id) async {
    try {
      final response = await _apiClient.post<void>(
        '${ApiClient.diagnosesEndpoint}/$id/publish',
        fromJson: (_) => null,
      );

      if (!response.isSuccess) {
        throw Exception(response.error ?? '診断の公開に失敗しました');
      }
    } catch (e) {
      throw Exception('診断の公開中にエラーが発生しました: $e');
    }
  }

  Future<void> unpublishDiagnosis(String id) async {
    try {
      final response = await _apiClient.post<void>(
        '${ApiClient.diagnosesEndpoint}/$id/unpublish',
        fromJson: (_) => null,
      );

      if (!response.isSuccess) {
        throw Exception(response.error ?? '診断の非公開化に失敗しました');
      }
    } catch (e) {
      throw Exception('診断の非公開化中にエラーが発生しました: $e');
    }
  }

  Future<List<entities.DiagnosisResult>> getDiagnosisHistory() async {
    try {
      final response = await _apiClient.get<List<models.DiagnosisResult>>(
        '${ApiClient.diagnosesEndpoint}/history',
        fromJson: (json) => (json['items'] as List<dynamic>)
            .map((item) => models.DiagnosisResult.fromJson(item as Map<String, dynamic>))
            .toList(),
      );

      if (response.isSuccess && response.data != null) {
        return response.data.map((d) => d.toEntity()).toList();
      }
      throw Exception(response.error ?? '診断履歴の取得に失敗しました');
    } catch (e) {
      throw Exception('診断履歴の取得中にエラーが発生しました: $e');
    }
  }

  Future<void> shareDiagnosisResult(String resultId) async {
    try {
      final response = await _apiClient.post<void>(
        '${ApiClient.diagnosesEndpoint}/results/$resultId/share',
        fromJson: (_) => null,
      );

      if (!response.isSuccess) {
        throw Exception(response.error ?? '診断結果の共有に失敗しました');
      }
    } catch (e) {
      throw Exception('診断結果の共有中にエラーが発生しました: $e');
    }
  }

  Future<void> deleteDiagnosisResult(String resultId) async {
    try {
      final response = await _apiClient.delete<void>(
        '${ApiClient.diagnosesEndpoint}/results/$resultId',
        fromJson: (_) => null,
      );

      if (!response.isSuccess) {
        throw Exception(response.error ?? '診断結果の削除に失敗しました');
      }
    } catch (e) {
      throw Exception('診断結果の削除中にエラーが発生しました: $e');
    }
  }
}