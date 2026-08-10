import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/adherence_record.dart';
import '../models/medication_reminder.dart';
import '../repositories/mock_treatment_repository.dart';
import '../repositories/treatment_repository.dart';

// ─── Repository Provider ────────────────────────────────────────────────────

final treatmentRepositoryProvider = Provider<TreatmentRepository>((ref) {
  return MockTreatmentRepository();
});

// ─── State ──────────────────────────────────────────────────────────────────

class TreatmentState {
  final bool isLoadingReminders;
  final bool isLoadingHistory;
  final bool isLoadingAdherence;
  final List<MedicationReminder> todayReminders;
  final List<MedicationReminder> history;
  final List<AdherenceRecord> adherenceRecords;
  final String? confirmingId; // ID of the reminder currently being confirmed
  final String? errorMessage;

  const TreatmentState({
    this.isLoadingReminders = true,
    this.isLoadingHistory = true,
    this.isLoadingAdherence = true,
    this.todayReminders = const [],
    this.history = const [],
    this.adherenceRecords = const [],
    this.confirmingId,
    this.errorMessage,
  });

  bool get isAnyLoading =>
      isLoadingReminders || isLoadingHistory || isLoadingAdherence;

  int get pendingReminderCount => todayReminders
      .where((r) => r.status == MedicationStatus.pending || r.status == MedicationStatus.notConfirmed)
      .length;

  int get confirmedTodayCount =>
      todayReminders.where((r) => r.isConfirmed).length;

  /// Weekly adherence rate (0–1), averaged across all records.
  double get weeklyAdherenceRate {
    if (adherenceRecords.isEmpty) return 0.0;
    final total = adherenceRecords.fold<int>(
        0, (sum, r) => sum + r.scheduledCount);
    final confirmed = adherenceRecords.fold<int>(
        0, (sum, r) => sum + r.confirmedCount);
    return total == 0 ? 1.0 : confirmed / total;
  }

  TreatmentState copyWith({
    bool? isLoadingReminders,
    bool? isLoadingHistory,
    bool? isLoadingAdherence,
    List<MedicationReminder>? todayReminders,
    List<MedicationReminder>? history,
    List<AdherenceRecord>? adherenceRecords,
    String? confirmingId,
    String? errorMessage,
    bool clearConfirmingId = false,
    bool clearError = false,
  }) {
    return TreatmentState(
      isLoadingReminders: isLoadingReminders ?? this.isLoadingReminders,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      isLoadingAdherence: isLoadingAdherence ?? this.isLoadingAdherence,
      todayReminders: todayReminders ?? this.todayReminders,
      history: history ?? this.history,
      adherenceRecords: adherenceRecords ?? this.adherenceRecords,
      confirmingId: clearConfirmingId ? null : (confirmingId ?? this.confirmingId),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

// ─── Notifier ───────────────────────────────────────────────────────────────

class TreatmentNotifier extends StateNotifier<TreatmentState> {
  final TreatmentRepository _repository;

  TreatmentNotifier(this._repository) : super(const TreatmentState()) {
    loadAll();
  }

  Future<void> loadAll() async {
    await Future.wait([
      loadTodayReminders(),
      loadAdherence(),
      loadHistory(),
    ]);
  }

  Future<void> loadTodayReminders() async {
    state = state.copyWith(isLoadingReminders: true, clearError: true);
    try {
      final reminders = await _repository.getTodaysReminders();
      state = state.copyWith(isLoadingReminders: false, todayReminders: reminders);
    } catch (e) {
      state = state.copyWith(
        isLoadingReminders: false,
        errorMessage: 'Impossible de charger le planning de traitement.',
      );
    }
  }

  Future<void> loadAdherence() async {
    state = state.copyWith(isLoadingAdherence: true);
    try {
      final records = await _repository.getWeeklyAdherence();
      state = state.copyWith(isLoadingAdherence: false, adherenceRecords: records);
    } catch (e) {
      state = state.copyWith(isLoadingAdherence: false);
    }
  }

  Future<void> loadHistory() async {
    state = state.copyWith(isLoadingHistory: true);
    try {
      final history = await _repository.getHistory();
      state = state.copyWith(isLoadingHistory: false, history: history);
    } catch (e) {
      state = state.copyWith(isLoadingHistory: false);
    }
  }

  Future<void> confirmReminder(String reminderId) async {
    state = state.copyWith(confirmingId: reminderId);
    try {
      final updated = await _repository.confirmReminder(reminderId);
      final newReminders = state.todayReminders.map((r) {
        return r.id == reminderId ? updated : r;
      }).toList();
      state = state.copyWith(
        todayReminders: newReminders,
        clearConfirmingId: true,
      );
    } catch (e) {
      state = state.copyWith(
        clearConfirmingId: true,
        errorMessage: 'La confirmation a échoué. Veuillez réessayer.',
      );
    }
  }
}

// ─── Provider ───────────────────────────────────────────────────────────────

final treatmentProvider =
    StateNotifierProvider<TreatmentNotifier, TreatmentState>((ref) {
  final repository = ref.watch(treatmentRepositoryProvider);
  return TreatmentNotifier(repository);
});
