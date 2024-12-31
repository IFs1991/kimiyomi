import '../../domain/entities/diagnosis_result.dart' as entities;
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

  DiagnosisResult({
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

  factory DiagnosisResult.fromJson(Map<String, dynamic> json) {
    return DiagnosisResult(
      id: json['id'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      diagnosis: Diagnosis.fromJson(json['diagnosis'] as Map<String, dynamic>),
      answers: Map<String, int>.from(json['answers'] as Map),
      totalScore: json['total_score'] as int,
      result: json['result'] as String,
      advice: json['advice'] as String,
      isShared: json['is_shared'] as bool,
      shareUrl: json['share_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'diagnosis': diagnosis.toJson(),
      'answers': answers,
      'total_score': totalScore,
      'result': result,
      'advice': advice,
      'is_shared': isShared,
      'share_url': shareUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  entities.DiagnosisResult toEntity() {
    return entities.DiagnosisResult(
      id: id,
      user: user.toEntity(),
      diagnosis: diagnosis.toEntity(),
      answers: answers,
      totalScore: totalScore,
      result: result,
      advice: advice,
      isShared: isShared,
      shareUrl: shareUrl,
      createdAt: createdAt,
    );
  }

  factory DiagnosisResult.fromEntity(entities.DiagnosisResult entity) {
    return DiagnosisResult(
      id: entity.id,
      user: User.fromEntity(entity.user),
      diagnosis: Diagnosis.fromEntity(entity.diagnosis),
      answers: entity.answers,
      totalScore: entity.totalScore,
      result: entity.result,
      advice: entity.advice,
      isShared: entity.isShared,
      shareUrl: entity.shareUrl,
      createdAt: entity.createdAt,
    );
  }
}