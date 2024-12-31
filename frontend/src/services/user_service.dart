import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_client.dart';
import '../domain/entities/user.dart' as entities;
import '../domain/entities/profile.dart' as entities;
import '../data/models/user.dart' as models;
import '../data/models/profile.dart' as models;
import '../core/models/api_response.dart';

final userServiceProvider = Provider((ref) => UserService(ApiClient()));

class UserService {
  final ApiClient _apiClient;

  UserService(this._apiClient);

  Future<entities.User?> login(String email, String password) async {
    try {
      final response = await _apiClient.post<models.User>(
        ApiClient.loginEndpoint,
        data: {
          'email': email,
          'password': password,
        },
        fromJson: (json) => models.User.fromJson(json),
      );

      if (response.isSuccess && response.data != null) {
        return response.data.toEntity();
      }
      throw Exception(response.error ?? '認証に失敗しました');
    } catch (e) {
      throw Exception('ログイン中にエラーが発生しました: $e');
    }
  }

  Future<void> logout() async {
    try {
      final response = await _apiClient.post<void>(
        ApiClient.logoutEndpoint,
        fromJson: (_) => null,
      );

      if (!response.isSuccess) {
        throw Exception(response.error ?? 'ログアウトに失敗しました');
      }
    } catch (e) {
      throw Exception('ログアウト中にエラーが発生しました: $e');
    }
  }

  Future<entities.Profile?> getProfile() async {
    try {
      final response = await _apiClient.get<models.Profile>(
        ApiClient.profileEndpoint,
        fromJson: (json) => models.Profile.fromJson(json),
      );

      if (response.isSuccess && response.data != null) {
        return response.data.toEntity();
      }
      throw Exception(response.error ?? 'プロフィールの取得に失敗しました');
    } catch (e) {
      throw Exception('プロフィール取得中にエラーが発生しました: $e');
    }
  }

  Future<entities.Profile?> updateProfile(entities.Profile profile) async {
    try {
      final modelProfile = models.Profile.fromEntity(profile);
      final response = await _apiClient.put<models.Profile>(
        ApiClient.profileEndpoint,
        data: modelProfile.toJson(),
        fromJson: (json) => models.Profile.fromJson(json),
      );

      if (response.isSuccess && response.data != null) {
        return response.data.toEntity();
      }
      throw Exception(response.error ?? 'プロフィールの更新に失敗しました');
    } catch (e) {
      throw Exception('プロフィール更新中にエラーが発生しました: $e');
    }
  }
}