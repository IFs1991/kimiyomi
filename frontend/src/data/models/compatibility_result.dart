import '../../domain/entities/compatibility_result.dart' as entities;
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

  CompatibilityResult({
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

  factory CompatibilityResult.fromJson(Map<String, dynamic> json) {
    return CompatibilityResult(
      id: json['id'] as String,
      user1: User.fromJson(json['user1'] as Map<String, dynamic>),
      user2: User.fromJson(json['user2'] as Map<String, dynamic>),
      diagnosis1: DiagnosisResult.fromJson(json['diagnosis1'] as Map<String, dynamic>),
      diagnosis2: DiagnosisResult.fromJson(json['diagnosis2'] as Map<String, dynamic>),
      compatibilityScore: json['compatibility_score'] as int,
      compatibilityLevel: json['compatibility_level'] as String,
      analysis: json['analysis'] as String,
      commonTraits: (json['common_traits'] as List<dynamic>).map((e) => e as String).toList(),
      differences: (json['differences'] as List<dynamic>).map((e) => e as String).toList(),
      advice: json['advice'] as String,
      isShared: json['is_shared'] as bool,
      shareUrl: json['share_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user1': user1.toJson(),
      'user2': user2.toJson(),
      'diagnosis1': diagnosis1.toJson(),
      'diagnosis2': diagnosis2.toJson(),
      'compatibility_score': compatibilityScore,
      'compatibility_level': compatibilityLevel,
      'analysis': analysis,
      'common_traits': commonTraits,
      'differences': differences,
      'advice': advice,
      'is_shared': isShared,
      'share_url': shareUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  entities.CompatibilityResult toEntity() {
    return entities.CompatibilityResult(
      id: id,
      user1: user1.toEntity(),
      user2: user2.toEntity(),
      diagnosis1: diagnosis1.toEntity(),
      diagnosis2: diagnosis2.toEntity(),
      compatibilityScore: compatibilityScore,
      compatibilityLevel: compatibilityLevel,
      analysis: analysis,
      commonTraits: commonTraits,
      differences: differences,
      advice: advice,
      isShared: isShared,
      shareUrl: shareUrl,
      createdAt: createdAt,
    );
  }

  factory CompatibilityResult.fromEntity(entities.CompatibilityResult entity) {
    return CompatibilityResult(
      id: entity.id,
      user1: User.fromEntity(entity.user1),
      user2: User.fromEntity(entity.user2),
      diagnosis1: DiagnosisResult.fromEntity(entity.diagnosis1),
      diagnosis2: DiagnosisResult.fromEntity(entity.diagnosis2),
      compatibilityScore: entity.compatibilityScore,
      compatibilityLevel: entity.compatibilityLevel,
      analysis: entity.analysis,
      commonTraits: entity.commonTraits,
      differences: entity.differences,
      advice: entity.advice,
      isShared: entity.isShared,
      shareUrl: entity.shareUrl,
      createdAt: entity.createdAt,
    );
  }
}