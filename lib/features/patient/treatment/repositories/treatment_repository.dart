import '../models/adherence_record.dart';
import '../models/medication_reminder.dart';

/// Abstract repository interface for treatment data.
/// All UI communicates through this contract — never directly to mock or Supabase.
abstract class TreatmentRepository {
  /// Returns today's scheduled medication reminders, ordered by time.
  Future<List<MedicationReminder>> getTodaysReminders();

  /// Marks a reminder as confirmed. Returns the updated reminder.
  Future<MedicationReminder> confirmReminder(String reminderId);

  /// Returns adherence records for the past [days] days (default 7).
  Future<List<AdherenceRecord>> getWeeklyAdherence({int days = 7});

  /// Returns historical reminders in reverse-chronological order.
  Future<List<MedicationReminder>> getHistory({int limit = 30});
}
