import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:respiracare/features/nurse/dashboard/models/monitoring_rule.dart';
import 'package:respiracare/features/nurse/dashboard/providers/nurse_assignments_provider.dart';
import 'package:respiracare/features/nurse/patients/models/nurse_patient.dart';
import 'package:respiracare/features/nurse/patients/repositories/mock_nurse_patient_repository.dart';

void main() {
  NursePatient patient(String id, String fullName) => NursePatient(
        id: id,
        fullName: fullName,
        condition: 'BPCO',
        classification: 'GOLD III',
        priority: PriorityLevel.high,
        hasNewSubmission: true,
      );

  group('nurseAssignedPatientSearchProvider', () {
    Future<ProviderContainer> build(List<NursePatient> patients) async {
      final container = ProviderContainer(
        overrides: [
          nurseAssignmentsProvider.overrideWith(
            (ref) => _FakeAssignmentsNotifier(patients),
          ),
        ],
      );
      addTearDown(container.dispose);
      // Start the (lazy) assignment notifier, then let its async load complete
      // before asserting on the derived search result.
      container.read(nurseAssignmentsProvider);
      await Future<void>.delayed(const Duration(milliseconds: 5));
      return container;
    }

    test('returns the full authorized roster when the query is empty',
        () async {
      final container = await build([
        patient('p1', 'Ahmed Bensalem'),
        patient('p2', 'Nsiri Karim'),
      ]);

      final result = container.read(nurseAssignedPatientSearchProvider(''));
      expect(result.map((p) => p.id), ['p1', 'p2']);
    });

    test('matches case-insensitively on the display name', () async {
      final container = await build([
        patient('p1', 'Ahmed Bensalem'),
        patient('p2', 'Nsiri Karim'),
      ]);

      expect(
        container.read(nurseAssignedPatientSearchProvider('AHMED')),
        hasLength(1),
      );
      expect(
        container.read(nurseAssignedPatientSearchProvider('ahmed')).single.id,
        'p1',
      );
      expect(
        container
            .read(nurseAssignedPatientSearchProvider('bensalem'))
            .single
            .id,
        'p1',
      );
    });

    test('returns no matches when nothing matches the query', () async {
      final container = await build([
        patient('p1', 'Ahmed Bensalem'),
      ]);

      expect(
        container.read(nurseAssignedPatientSearchProvider('zorg')),
        isEmpty,
      );
    });
  });
}

class _FakeAssignmentsNotifier extends NurseAssignmentsNotifier {
  _FakeAssignmentsNotifier(List<NursePatient> patients)
      : super(_SearchRepo(patients), 'n1', 'Asma');
}

class _SearchRepo extends MockNursePatientRepository {
  _SearchRepo(this.patients);
  final List<NursePatient> patients;

  @override
  Future<List<NursePatient>> getAssignedPatients(String nurseId) async =>
      patients;
}
