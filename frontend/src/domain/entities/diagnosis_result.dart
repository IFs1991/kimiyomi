import 'user.dart';
import 'diagnosis.dart';

class DiagnosisResult {
  final String id;
  final User user;
  final Diagnosis diagnosis;
  final Map<String, int> answers;
  final int totalScore;
  final String result;
  final String advice;
  final bool isShared;
  final String? shareUrl;
  final DateTime createdAt;

  const DiagnosisResult({
    required this.id,
    required this.user,
    required this.diagnosis,
    required this.answers,
    required this.totalScore,
    required this.result,
    required this.advice,
    required this.isShared,
    this.shareUrl,
    required this.createdAt,
  });
}