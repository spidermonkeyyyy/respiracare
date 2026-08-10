import '../models/adherence_record.dart';
import '../models/medication_reminder.dart';
import 'treatment_repository.dart';

/// Mock implementation of [TreatmentRepository].
/// Provides realistic two-reminder-per-day data for development.
/// Replace with SupabaseTreatmentRepository at backend integration time.
class MockTreatmentRepository implements TreatmentRepository {
  // In-memory mutable state to simulate confirm actions during the session
  final List<MedicationReminder> _todayReminders;

  MockTreatmentRepository() : _todayReminders = _buildTodayReminders();

  static List<MedicationReminder> _buildTodayReminders() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return [
      MedicationReminder(
        id: 'reminder-morning',
        medicationId: 'med-001',
        medicationLabel: 'Traitement inhalé 1',
        scheduledAt: today.copyWith(hour: 8, minute: 0),
        status: MedicationStatus.confirmed,
        confirmedAt: today.copyWith(hour: 8, minute: 2),
      ),
      MedicationReminder(
        id: 'reminder-evening',
        medicationId: 'med-001',
        medicationLabel: 'Traitement inhalé 1',
        scheduledAt: today.copyWith(hour: 20, minute: 0),
        status: MedicationStatus.pending,
      ),
    ];
  }

  @override
  Future<List<MedicationReminder>> getTodaysReminders() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.unmodifiable(_todayReminders);
  }

  @override
  Future<MedicationReminder> confirmReminder(String reminderId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _todayReminders.indexWhere((r) => r.id == reminderId);
    if (index == -1) throw Exception('Reminder $reminderId not found');

    final updated = _todayReminders[index].copyWith(
      status: MedicationStatus.confirmed,
      confirmedAt: DateTime.now(),
    );
    _todayReminders[index] = updated;
    return updated;
  }

  @override
  Future<List<AdherenceRecord>> getWeeklyAdherence({int days = 7}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();
    return List.generate(days, (i) {
      final date = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: days - 1 - i));
      // Simulate one missed dose on day index 3 (Thursday equivalent)
      final confirmed = (i == 3) ? 1 : 2;
      return AdherenceRecord(
        date: date,
        scheduledCount: 2,
        confirmedCount: confirmed,
      );
    });
  }

  @override
  Future<List<MedicationReminder>> getHistory({int limit = 30}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final now = DateTime.now();
    final history = <MedicationReminder>[];

    for (int day = 1; day <= 7; day++) {
      final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: day));
      final missedEvening = (day == 4);

      // Morning dose — always confirmed in history
      history.add(MedicationReminder(
        id: 'hist-$day-morning',
        medicationId: 'med-001',
        medicationLabel: 'Traitement inhalé 1',
        scheduledAt: date.copyWith(hour: 8, minute: 0),
        status: MedicationStatus.confirmed,
        confirmedAt: date.copyWith(hour: 8, minute: 2),
      ));

      // Evening dose — missed on one prior day
      history.add(MedicationReminder(
        id: 'hist-$day-evening',
        medicationId: 'med-001',
        medicationLabel: 'Traitement inhalé 1',
        scheduledAt: date.copyWith(hour: 20, minute: 0),
        status: missedEvening ? MedicationStatus.notConfirmed : MedicationStatus.confirmed,
        confirmedAt: missedEvening ? null : date.copyWith(hour: 20, minute: 3),
      ));
    }

    // Sort descending (most recent first)
    history.sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
    return history.take(limit).toList();
  }
}

extension _DateTimeCopyWith on DateTime {
  DateTime copyWith({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
  }) {
    return DateTime(
      year ?? this.year,
      month ?? this.month,
      day ?? this.day,
      hour ?? this.hour,
      minute ?? this.minute,
      second ?? this.second,
    );
  }
}
