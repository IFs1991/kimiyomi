class ApiResponse<T> {
  final T? data;
  final String? message;
  final bool isSuccess;

  const ApiResponse({
    this.data,
    this.message,
    required this.isSuccess,
  });

  factory ApiResponse.success(T data, [String? message]) {
    return ApiResponse(
      data: data,
      message: message,
      isSuccess: true,
    );
  }

  factory ApiResponse.error(String message) {
    return ApiResponse(
      message: message,
      isSuccess: false,
    );
  }

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (json['error'] != null) {
      return ApiResponse.error(
        json['message'] ?? '不明なエラーが発生しました',
      );
    }

    return ApiResponse.success(
      fromJson(json['data'] as Map<String, dynamic>),
      json['message'] as String?,
    );
  }
}