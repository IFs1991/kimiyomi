import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'diagnosis.g.dart';

@JsonSerializable()
class Diagnosis extends Equatable {
  final String id;
  final String userId;
  final DateTime createdAt;
  final DiagnosisType type;
  final Map<String, double> scores;
  final String primaryType;
  final List<String> compatibleTypes;
  final String summary;
  final Map<String, String> detailedResults;

  const Diagnosis({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.type,
    required this.scores,
    required this.primaryType,
    required this.compatibleTypes,
    required this.summary,
    required this.detailedResults,
  });

  factory Diagnosis.fromJson