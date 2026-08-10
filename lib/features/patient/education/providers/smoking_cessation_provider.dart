import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/educational_content.dart';
import '../models/smoking_entry.dart';
import '../repositories/education_repository.dart';
import 'rehabilitation_provider.dart';

/// State for smoking cessation feature
class SmokingCessationState {
  final bool isLoading;
  final String? errorMessage;
  final List<SmokingEntry> entries;
  final int trackedDays;
  final String currentGoal;
  final List<EducationalContent> educationalContent;

  const SmokingCessationState({
    this.isLoading = true,
    this.errorMessage,
    this.entries = const [],
    this.trackedDays = 0,
    this.currentGoal = 'Arrêt progressif',
    this.educationalContent = const [],
  });

  SmokingCessationState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<SmokingEntry>? entries,
    int? trackedDays,
    String? currentGoal,
    List<EducationalContent>? educationalContent,
  }) {
    return SmokingCessationState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      entries: entries ?? this.entries,
      trackedDays: trackedDays ?? this.trackedDays,
      currentGoal: currentGoal ?? this.currentGoal,
      educationalContent: educationalContent ?? this.educationalContent,
    );
  }

  /// Today's entry if exists
  SmokingEntry? get todaysEntry {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    try {
      return entries.firstWhere((e) {
        final entryDate = DateTime(e.date.year, e.date.month, e.date.day);
        return entryDate == todayDate;
      });
    } catch (_) {
      return null;
    }
  }

  /// Total cigarettes this week
  int get weeklyCigarettes {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return entries
        .where((e) => e.date.isAfter(weekAgo))
        .fold(0, (sum, e) => sum + e.cigarettesConsumed);
  }

  /// Average cigarettes per day (last 7 days with entries)
  double get averageDailyCigarettes {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final recentEntries = entries.where((e) => e.date.isAfter(weekAgo)).toList();
    if (recentEntries.isEmpty) return 0.0;
    final total = recentEntries.fold(0, (sum, e) => sum + e.cigarettesConsumed);
    return total / recentEntries.length;
  }

  /// Tracking completion rate (days with entry / tracked days)
  double get trackingCompletionRate {
    if (trackedDays == 0) return 0.0;
    final uniqueEntryDates = entries
        .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
        .toSet();
    return uniqueEntryDates.length / trackedDays;
  }
}

/// Smoking cessation provider using StateNotifier
final smokingCessationProvider =
    StateNotifierProvider<SmokingCessationNotifier, SmokingCessationState>((ref) {
  final repository = ref.watch(educationRepositoryProvider);
  return SmokingCessationNotifier(repository);
});

class SmokingCessationNotifier extends StateNotifier<SmokingCessationState> {
  final EducationRepository _repository;

  SmokingCessationNotifier(this._repository) : super(const SmokingCessationState()) {
    loadData();
  }

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final entries = await _repository.getSmokingEntries();
      final trackedDays = await _repository.getTrackedDaysCount();
      final goal = await _repository.getCurrentGoal();
      final content = await _repository.getEducationalContent(
        category: 'sevrage',
      );

      state = state.copyWith(
        isLoading: false,
        entries: entries,
        trackedDays: trackedDays,
        currentGoal: goal,
        educationalContent: content,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Impossible de charger vos données de sevrage.',
      );
    }
  }

  Future<void> addEntry(SmokingEntry entry) async {
    try {
      final savedEntry = await _repository.addSmokingEntry(entry);

      final updatedEntries = [savedEntry, ...state.entries];
      final trackedDays = await _repository.getTrackedDaysCount();

      state = state.copyWith(
        entries: updatedEntries,
        trackedDays: trackedDays,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Impossible d\'enregistrer votre entrée.',
      );
    }
  }

  Future<void> deleteEntry(String entryId) async {
    try {
      await _repository.deleteSmokingEntry(entryId);

      final updatedEntries = state.entries.where((e) => e.id != entryId).toList();
      final trackedDays = await _repository.getTrackedDaysCount();

      state = state.copyWith(
        entries: updatedEntries,
        trackedDays: trackedDays,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Impossible de supprimer cette entrée.',
      );
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}