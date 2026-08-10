import 'package:respiracare/features/patient/education/models/educational_content.dart';
import 'package:respiracare/features/patient/education/models/exercise_session.dart';
import 'package:respiracare/features/patient/education/models/rehabilitation_program.dart';
import 'package:respiracare/features/patient/education/models/smoking_entry.dart';

/// Abstract repository interface for education-related data
/// This allows swapping between mock and real implementations
abstract class EducationRepository {
  // Rehabilitation
  Future<RehabilitationProgram?> getRehabilitationProgram();
  Future<List<ExerciseSession>> getExerciseSessions({int? limit});
  Future<ExerciseSession> recordExerciseSession(ExerciseSession session);

  // Smoking Cessation
  Future<List<SmokingEntry>> getSmokingEntries({int? limit});
  Future<SmokingEntry> addSmokingEntry(SmokingEntry entry);
  Future<void> deleteSmokingEntry(String entryId);
  Future<int> getTrackedDaysCount();
  Future<String> getCurrentGoal();

  // Educational Content
  Future<List<EducationalContent>> getEducationalContent({
    String? category,
  });
  Future<EducationalContent?> getEducationalContentById(String id);
}
