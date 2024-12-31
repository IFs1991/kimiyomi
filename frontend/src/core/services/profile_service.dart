import 'package:flutter/foundation.dart';

import '../api/api_client.dart';
import '../../data/models/profile.dart';

class ApiResponse<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  ApiResponse({
    this.data,
    this.error,
    required this.isSuccess,
  });
}

class ProfileService {
  final ApiClient _apiClient;

  ProfileService(this._apiClient);

  Future<Profile> fetchProfile(String userId) async {
    try {
      final response = await _apiClient.get<Profile>(
        '/profiles/$userId',
        fromJson: Profile.fromJson,
      );
      if (response.isSuccess && response.data != null) {
        return response.data!;
      }
      throw Exception(response.error ?? 'プロフィールの取得に失敗しました');
    } catch (e) {
      debugPrint('プロフィール取得エラー: $e');
      rethrow;
    }
  }

  Future<Profile> updateProfile(Profile profile) async {
    try {
      final response = await _apiClient.put<Profile>(
        '/profiles/${profile.userId}',
        data: profile.toJson(),
        fromJson: Profile.fromJson,
      );
      if (response.isSuccess && response.data != null) {
        return response.data!;
      }
      throw Exception(response.error ?? 'プロフィールの更新に失敗しました');
    } catch (e) {
      debugPrint('プロフィール更新エラー: $e');
      rethrow;
    }
  }

  Future<void> deleteProfile(String userId) async {
    try {
      final response = await _apiClient.delete<void>(
        '/profiles/$userId',
        fromJson: (_) => null,
      );
      if (!response.isSuccess) {
        throw Exception(response.error ?? 'プロフィールの削除に失敗しました');
      }
    } catch (e) {
      debugPrint('プロフィール削除エラー: $e');
      rethrow;
    }
  }
}