import 'package:flutter_test/flutter_test.dart';
import 'package:respiracare/features/nurse/dashboard/repositories/mock_nurse_dashboard_repository.dart';

/// Determinism guard for the deterministic-mock rule (Step 12.7 §31/§37).
///
/// Mock data must be stable: repeated calls must return the same items with
/// the same fixed timestamps. It must not generate random/`DateTime.now()`-
/// based values on each load, otherwise the derived worklist ordering and tests
/// would be unstable.
void main() {
  group('MockNurseDashboardRepository determinism', () {
    test('getRecentSubmissions returns identical items across calls', () async {
      final repo = MockNurseDashboardRepository();
      final first = await repo.getRecentSubmissions();
      final second = await repo.getRecentSubmissions();

      expect(first, hasLength(second.length));
      for (var i = 0; i < first.length; i++) {
        expect(first[i].id, second[i].id);
        expect(first[i].submittedAt, second[i].submittedAt);
        expect(first[i].spo2, second[i].spo2);
      }
      // The two mock submissions have a fixed, stable ordering (newer first).
      expect(
        first[0].submittedAt.isAfter(first[1].submittedAt) ||
            first[0].submittedAt.isAtSameMomentAs(first[1].submittedAt),
        isTrue,
      );
    });

    test('submission timestamps are exact fixed constants, not Date.now()-derived',
        () async {
      final repo = MockNurseDashboardRepository();
      final submissions = await repo.getRecentSubmissions();

      // The two mock submissions derive from the deterministic anchor constant,
      // so their timestamps are fixed and clock-independent.
      expect(
        submissions[0].submittedAt,
        kMockDashboardSubmissionsAnchor.subtract(const Duration(minutes: 12)),
      );
      expect(
        submissions[1].submittedAt,
        kMockDashboardSubmissionsAnchor.subtract(const Duration(hours: 2)),
      );
    });
  });
}