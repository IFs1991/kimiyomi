import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/diagnosis_result.dart';
import '../../services/diagnosis_service.dart';

final diagnosisHistoryProvider = StateNotifierProvider<DiagnosisHistoryNotifier, DiagnosisHistoryState>((ref) {
  final diagnosisService = ref.watch(diagnosisServiceProvider);
  return DiagnosisHistoryNotifier(diagnosisService);
});

class DiagnosisHistoryState {
  final List<DiagnosisResult> results;
  final bool isLoading;
  final String? error;

  const DiagnosisHistoryState({
    this.results = const [],
    this.isLoading = false,
    this.error,
  });

  DiagnosisHistoryState copyWith({
    List<DiagnosisResult>? results,
    bool? isLoading,
    String? error,
  }) {
    return DiagnosisHistoryState(
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class DiagnosisHistoryNotifier extends StateNotifier<DiagnosisHistoryState> {
  final DiagnosisService _diagnosisService;

  DiagnosisHistoryNotifier(this._diagnosisService) : super(const DiagnosisHistoryState());

  Future<void> loadHistory() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final results = await _diagnosisService.getDiagnosisHistory();
      state = state.copyWith(results: results, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> shareResult(String resultId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _diagnosisService.shareDiagnosisResult(resultId);
      await loadHistory(); // 共有状態を更新するために履歴を再読み込み
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> deleteResult(String resultId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _diagnosisService.deleteDiagnosisResult(resultId);
      state = state.copyWith(
        results: state.results.where((r) => r.id != resultId).toList(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}