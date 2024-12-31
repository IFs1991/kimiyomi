import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/compatibility_result.dart';
import '../../services/compatibility_service.dart';

class CompatibilityState {
  final bool isLoading;
  final String? error;
  final List<CompatibilityResult> results;
  final CompatibilityResult? selectedResult;

  CompatibilityState({
    this.isLoading = false,
    this.error,
    this.results = const [],
    this.selectedResult,
  });

  CompatibilityState copyWith({
    bool? isLoading,
    String? error,
    List<CompatibilityResult>? results,
    CompatibilityResult? selectedResult,
  }) {
    return CompatibilityState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      results: results ?? this.results,
      selectedResult: selectedResult ?? this.selectedResult,
    );
  }
}

class CompatibilityNotifier extends StateNotifier<CompatibilityState> {
  final CompatibilityService _compatibilityService;

  CompatibilityNotifier(this._compatibilityService) : super(CompatibilityState());

  Future<void> checkCompatibility(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _compatibilityService.checkCompatibility(userId);
      state = state.copyWith(
        isLoading: false,
        selectedResult: result,
        results: [result, ...state.results],
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadCompatibilityHistory() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final results = await _compatibilityService.getCompatibilityHistory();
      state = state.copyWith(isLoading: false, results: results);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> shareResult(String resultId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _compatibilityService.shareCompatibilityResult(resultId);
      await loadCompatibilityHistory(); // 履歴を再読み込み
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteResult(String resultId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _compatibilityService.deleteCompatibilityResult(resultId);
      final updatedResults = state.results.where((r) => r.id != resultId).toList();
      state = state.copyWith(
        isLoading: false,
        results: updatedResults,
        selectedResult: state.selectedResult?.id == resultId ? null : state.selectedResult,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void selectResult(CompatibilityResult result) {
    state = state.copyWith(selectedResult: result);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final compatibilityProvider = StateNotifierProvider<CompatibilityNotifier, CompatibilityState>((ref) {
  final compatibilityService = ref.watch(compatibilityServiceProvider);
  return CompatibilityNotifier(compatibilityService);
});