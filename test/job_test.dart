import 'package:test/test.dart';
import 'package:flat_rate/model/job.dart';

void main() {
  group('a job records both hour figures', () {
    test('flagged and actual are kept apart, and both are decimals', () {
      final job = Job(
        repairOrder: '184922',
        date: DateTime(2026, 9, 3),
        payType: PayType.customer,
        writerId: 1,
        flaggedHours: 1.7,
        actualHours: 2.4,
      );
      expect(job.flaggedHours, equals(1.7));
      expect(job.actualHours, equals(2.4));
    });

    test('actual hours may be missing, because that is the thing techs skip', () {
      // The assumption this whole build is skipping. The model must be able to
      // represent its failure, or the app cannot report it.
      final job = Job(
        repairOrder: '184922',
        date: DateTime(2026, 9, 3),
        payType: PayType.customer,
        writerId: 1,
        flaggedHours: 1.7,
        actualHours: null,
      );
      expect(job.actualHours, isNull);
      expect(job.isComplete, isFalse);
    });

    test('a job with both figures is complete', () {
      final job = Job(
        repairOrder: '1',
        date: DateTime(2026, 9, 3),
        payType: PayType.customer,
        writerId: 1,
        flaggedHours: 1.0,
        actualHours: 1.0,
      );
      expect(job.isComplete, isTrue);
    });
  });

  group('pay type carries four values, not two', () {
    test('warranty, internal and recall are all cut, and all distinct', () {
      // Folding these into customer pay flatters both ratios.
      expect(PayType.values, hasLength(4));
      expect(PayType.values, contains(PayType.customer));
      expect(PayType.values, contains(PayType.warranty));
      expect(PayType.values, contains(PayType.internal));
      expect(PayType.values, contains(PayType.recall));
    });
  });

  group('a job refuses to exist in a state that would mislead', () {
    test('an empty repair order number', () {
      expect(
        () => Job(
          repairOrder: '   ',
          date: DateTime(2026, 9, 3),
          payType: PayType.customer,
          writerId: 1,
          flaggedHours: 1.0,
          actualHours: 1.0,
        ),
        throwsArgumentError,
      );
    });

    test('negative flagged hours', () {
      expect(
        () => Job(
          repairOrder: '1',
          date: DateTime(2026, 9, 3),
          payType: PayType.customer,
          writerId: 1,
          flaggedHours: -1.0,
          actualHours: 1.0,
        ),
        throwsArgumentError,
      );
    });

    test('a repair order number keeps its leading zeros', () {
      // RO numbers are identifiers, not quantities. 00412 is not 412.
      final job = Job(
        repairOrder: '00412',
        date: DateTime(2026, 9, 3),
        payType: PayType.warranty,
        writerId: 2,
        flaggedHours: 0.3,
        actualHours: 0.5,
      );
      expect(job.repairOrder, equals('00412'));
    });
  });
}
