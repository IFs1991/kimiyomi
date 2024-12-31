import '../entities/diagnosis_result.dart';

abstract class DiagnosisRepository {
  Future<DiagnosisResult> getDiagnosisResult(String userId);
  Future<DiagnosisResult> createDiagnosis(String userId, Map<String, dynamic> answers);
  Future<List<DiagnosisResult>> getUserDiagnosisHistory(String userId);
  Future<void> deleteDiagnosisResult(String diagnosisId);
  Future<DiagnosisResult> updateDiagnosisResult(String diagnosisId, Map<String, dynamic> updates);
}