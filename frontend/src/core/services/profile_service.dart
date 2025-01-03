import 'package:flutter/foundation.dart';

import '../api/api_client.dart';
import '../models/api_response.dart';
import '../../data/models/profile.dart';

class ProfileService {
  final ApiClient _apiClient;

  ProfileService(this._apiClient);

  Future<Profile> fetchProfile(String userId) async {
    try {
      final response = await _apiClient.get<Profile>(
        '/profiles/$userId',
        fromJson: Profile.fromJson,
      );
      if (!response.isSuccess || response.data == null) {
        throw Exception(response.message ?? 'プロフィールの取得に失敗しました');
      }
      return response.data!;
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
      if (!response.isSuccess || response.data == null) {
        throw Exception(response.message ?? 'プロフィールの更新に失敗しました');
      }
      return response.data!;
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
        throw Exception(response.message ?? 'プロフィールの削除に失敗しました');
      }
    } catch (e) {
      debugPrint('プロフィール削除エラー: $e');
      rethrow;
    }
  }
}