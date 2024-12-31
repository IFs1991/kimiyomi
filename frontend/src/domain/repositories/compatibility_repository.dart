import '../entities/compatibility_result.dart';

abstract class CompatibilityRepository {
  Future<CompatibilityResult> getCompatibilityResult(String user1Id, String user2Id);
  Future<CompatibilityResult> analyzeCompatibility(String user1Id, String user2Id);
  Future<List<CompatibilityResult>> getUserCompatibilityHistory(String userId);
  Future<void> deleteCompatibilityResult(String compatibilityId);
  Future<CompatibilityResult> updateCompatibilityResult(String compatibilityId, Map<String, dynamic> updates);
}