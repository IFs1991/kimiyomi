import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/diagnosis.dart';
import '../../services/diagnosis_service.dart';

final diagnosisListProvider = StateNotifierProvider<DiagnosisListNotifier, DiagnosisListState>((ref) {
  final diagnosisService = ref.watch(diagnosisServiceProvider);
  return DiagnosisListNotifier(diagnosisService);
});

final selectedDiagnosisProvider = StateNotifierProvider<SelectedDiagnosisNotifier, SelectedDiagnosisState>((ref) {
  final diagnosisService = ref.watch(diagnosisServiceProvider);
  return SelectedDiagnosisNotifier(diagnosisService);
});

class DiagnosisListState {
  final List<Diagnosis> diagnoses;
  final bool isLoading;
  final String? error;

  const DiagnosisListState({
    this.diagnoses = const [],
    this.isLoading = false,
    this.error,
  });

  DiagnosisListState copyWith({
    List<Diagnosis>? diagnoses,
    bool? isLoading,
    String? error,
  }) {
    return DiagnosisListState(
      diagnoses: diagnoses ?? this.diagnoses,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class DiagnosisListNotifier extends StateNotifier<DiagnosisListState> {
  final DiagnosisService _diagnosisService;

  DiagnosisListNotifier(this._diagnosisService) : super(const DiagnosisListState());

  Future<void> loadDiagnoses() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final diagnoses = await _diagnosisService.getDiagnoses();
      state = state.copyWith(diagnoses: diagnoses, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> createDiagnosis(Diagnosis diagnosis) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final createdDiagnosis = await _diagnosisService.createDiagnosis(diagnosis);
      state = state.copyWith(
        diagnoses: [...state.diagnoses, createdDiagnosis],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> deleteDiagnosis(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _diagnosisService.deleteDiagnosis(id);
      state = state.copyWith(
        diagnoses: state.diagnoses.where((d) => d.id != id).toList(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

class SelectedDiagnosisState {
  final Diagnosis? diagnosis;
  final bool isLoading;
  final String? error;

  const SelectedDiagnosisState({
    this.diagnosis,
    this.isLoading = false,
    this.error,
  });

  SelectedDiagnosisState copyWith({
    Diagnosis? diagnosis,
    bool? isLoading,
    String? error,
  }) {
    return SelectedDiagnosisState(
      diagnosis: diagnosis ?? this.diagnosis,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class SelectedDiagnosisNotifier extends StateNotifier<SelectedDiagnosisState> {
  final DiagnosisService _diagnosisService;

  SelectedDiagnosisNotifier(this._diagnosisService) : super(const SelectedDiagnosisState());

  Future<void> loadDiagnosis(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final diagnosis = await _diagnosisService.getDiagnosis(id);
      state = state.copyWith(diagnosis: diagnosis, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> updateDiagnosis(String id, Diagnosis diagnosis) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updatedDiagnosis = await _diagnosisService.updateDiagnosis(id, diagnosis);
      state = state.copyWith(diagnosis: updatedDiagnosis, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> publishDiagnosis(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _diagnosisService.publishDiagnosis(id);
      if (state.diagnosis != null) {
        state = state.copyWith(
          diagnosis: Diagnosis(
            id: state.diagnosis!.id,
            title: state.diagnosis!.title,
            description: state.diagnosis!.description,
            questions: state.diagnosis!.questions,
            isPublished: true,
            creator: state.diagnosis!.creator,
            createdAt: state.diagnosis!.createdAt,
            updatedAt: DateTime.now(),
          ),
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> unpublishDiagnosis(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _diagnosisService.unpublishDiagnosis(id);
      if (state.diagnosis != null) {
        state = state.copyWith(
          diagnosis: Diagnosis(
            id: state.diagnosis!.id,
            title: state.diagnosis!.title,
            description: state.diagnosis!.description,
            questions: state.diagnosis!.questions,
            isPublished: false,
            creator: state.diagnosis!.creator,
            createdAt: state.diagnosis!.createdAt,
            updatedAt: DateTime.now(),
          ),
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}