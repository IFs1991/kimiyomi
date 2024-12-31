import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_response.freezed.dart';
part 'api_response.g.dart';

@freezed
class ApiResponse<T> with _$ApiResponse<T> {
  const factory ApiResponse.success({
    required T data,
    String? message,
  }) = _Success<T>;

  const factory ApiResponse.error({
    required String message,
    @Default(null) dynamic error,
  }) = _Error<T>;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (json['error'] != null) {
      return ApiResponse.error(
        message: json['message'] ?? '不明なエラーが発生しました',
        error: json['error'],
      );
    }

    return ApiResponse.success(
      data: fromJson(json['data'] as Map<String, dynamic>),
      message: json['message'] as String?,
    );
  }
}