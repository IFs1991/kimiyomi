import 'user.dart';
import 'diagnosis_result.dart';

class CompatibilityResult {
  final String id;
  final User user1;
  final User user2;
  final DiagnosisResult diagnosis1;
  final DiagnosisResult diagnosis2;
  final int compatibilityScore;
  final String compatibilityLevel;
  final String analysis;
  final List<String> commonTraits;
  final List<String> differences;
  final String advice;
  final bool isShared;
  final String? shareUrl;
  final DateTime createdAt;

  const CompatibilityResult({
    required this.id,
    required this.user1,
    required this.user2,
    required this.diagnosis1,
    required this.diagnosis2,
    required this.compatibilityScore,
    required this.compatibilityLevel,
    required this.analysis,
    required this.commonTraits,
    required this.differences,
    required this.advice,
    required this.isShared,
    this.shareUrl,
    required this.createdAt,
  });
}