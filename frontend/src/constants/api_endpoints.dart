class ApiEndpoints {
  static const String baseUrl = 'https://api.kimiyomi.com/v1';

  // Authentication
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String logout = '$baseUrl/auth/logout';
  static const String refreshToken = '$baseUrl/auth/refresh';

  // User Profile
  static const String profile = '$baseUrl/profile';
  static const String updateProfile = '$baseUrl/profile/update';
  static const String uploadAvatar = '$baseUrl/profile/avatar';

  // Personality Diagnosis
  static const String startDiagnosis = '$baseUrl/diagnosis/start';
  static const String submitAnswers = '$baseUrl/diagnosis/submit';
  static const String getDiagnosisResult = '$baseUrl/diagnosis/result';
  static const String getDiagnosisHistory = '$baseUrl/diagnosis/history';

  // Content
  static const String getRecommendedContent = '$baseUrl/content/recommended';
  static const String getContentDetails = '$baseUrl/content/details';
  static const String likeContent = '$baseUrl/content/like';
  static const String saveContent = '$baseUrl/content/save';

  // Matching
  static const String getMatches = '$baseUrl/matching/list';
  static const String getMatchDetails = '$baseUrl/matching/details';
  static const String sendMatchRequest = '$baseUrl/matching/request';
  static const String respondToMatch = '$baseUrl/matching/respond';

  // Chat
  static const String getChatRooms = '$baseUrl/chat/rooms';
  static const String getChatMessages = '$baseUrl/chat/messages';
  static const String sendMessage = '$baseUrl/chat/send';
  static const String markAsRead = '$baseUrl/chat/read';
}