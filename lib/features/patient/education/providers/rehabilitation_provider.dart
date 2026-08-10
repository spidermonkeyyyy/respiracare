import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/exercise.dart';
import '../models/exercise_session.dart';
import '../models/rehabilitation_program.dart';
import '../repositories/education_repository.dart';
import '../repositories/mock_education_repository.dart';

/// State for rehabilitation feature
class RehabilitationState {
  final bool isLoading;
  final String? errorMessage;
  final RehabilitationProgram? program;
  final Exercise? todaysExercise;
  final List<ExerciseSession> recentSessions;
  final int weeklySessionsCompleted;
  final int weeklyTargetSessions;

  const RehabilitationState({
    this.isLoading = true,
    this.errorMessage,
    this.program,
    this.todaysExercise,
    this.recentSessions = const [],
    this.weeklySessionsCompleted = 0,
    this.weeklyTargetSessions = 5,
  });

  RehabilitationState copyWith({
    bool? isLoading,
    String? errorMessage,
    RehabilitationProgram? program,
    Exercise? todaysExercise,
    List<ExerciseSession>? recentSessions,
    int? weeklySessionsCompleted,
    int? weeklyTargetSessions,
  }) {
    return RehabilitationState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      program: program ?? this.program,
      todaysExercise: todaysExercise ?? this.todaysExercise,
      recentSessions: recentSessions ?? this.recentSessions,
      weeklySessionsCompleted:
          weeklySessionsCompleted ?? this.weeklySessionsCompleted,
      weeklyTargetSessions: weeklyTargetSessions ?? this.weeklyTargetSessions,
    );
  }

  double get weeklyProgress => weeklyTargetSessions > 0
      ? weeklySessionsCompleted / weeklyTargetSessions
      : 0.0;
}

/// Provider for the education repository
final educationRepositoryProvider = Provider<EducationRepository>((ref) {
  return MockEducationRepository();
});

/// Rehabilitation provider using StateNotifier
final rehabilitationProvider =
    StateNotifierProvider<RehabilitationNotifier, RehabilitationState>((ref) {
  final repository = ref.watch(educationRepositoryProvider);
  return RehabilitationNotifier(repository);
});

class RehabilitationNotifier extends StateNotifier<RehabilitationState> {
  final EducationRepository _repository;

  RehabilitationNotifier(this._repository)
      : super(const RehabilitationState()) {
    loadProgram();
  }

  Future<void> loadProgram() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final program = await _repository.getRehabilitationProgram();
      final sessions = await _repository.getExerciseSessions(limit: 10);

      // Calculate weekly sessions (last 7 days)
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));
      final weeklySessions =
          sessions.where((s) => s.completedAt.isAfter(weekAgo)).length;

      Exercise? todaysExercise;
      if (program != null) {
        todaysExercise = program.getTodaysExercise();
      }

      state = state.copyWith(
        isLoading: false,
        program: program,
        todaysExercise: todaysExercise,
        recentSessions: sessions,
        weeklySessionsCompleted: weeklySessions,
        weeklyTargetSessions: program?.targetWeeklySessions ?? 5,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Impossible de charger votre programme de rééducation.',
      );
    }
  }

  Future<void> completeExerciseSession(ExerciseSession session) async {
    try {
      final recordedSession = await _repository.recordExerciseSession(session);

      final updatedSessions = [recordedSession, ...state.recentSessions];

      // Recalculate weekly count
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));
      final weeklySessions =
          updatedSessions.where((s) => s.completedAt.isAfter(weekAgo)).length;

      state = state.copyWith(
        recentSessions: updatedSessions,
        weeklySessionsCompleted: weeklySessions,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Impossible d\'enregistrer votre séance.',
      );
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
