import 'package:test/test.dart';
import 'package:flat_rate/logic/ratios.dart';

void main() {
  group('proficiency — flagged divided by clocked', () {
    test('beating book time reads above one', () {
      expect(proficiency(flagged: 45.0, clocked: 40.0), closeTo(1.125, 1e-9));
    });

    test('losing against book time reads below one', () {
      expect(proficiency(flagged: 30.0, clocked: 40.0), closeTo(0.75, 1e-9));
    });

    test('carries the decimals a flag time is actually written in', () {
      expect(proficiency(flagged: 0.3, clocked: 1.7), closeTo(0.17647058, 1e-8));
    });
  });

  group('efficiency — flagged divided by scheduled', () {
    test('a full schedule fully flagged reads as one', () {
      expect(efficiency(flagged: 40.0, available: 40.0), closeTo(1.0, 1e-9));
    });

    test('the same technician can be efficient and unproficient at once', () {
      // Stayed late: scheduled 40, was there 50, flagged 45.
      // The shop kept them busy; the work still took longer than it books at.
      expect(efficiency(flagged: 45.0, available: 40.0), greaterThan(1.0));
      expect(proficiency(flagged: 45.0, clocked: 50.0), lessThan(1.0));
    });
  });

  group('undefined is a real answer, not zero', () {
    test('no scheduled hours means no efficiency', () {
      expect(efficiency(flagged: 0.0, available: 0.0), isNull);
    });

    test('no clocked hours means no proficiency', () {
      expect(proficiency(flagged: 0.0, clocked: 0.0), isNull);
    });

    test('flagged hours with no clocked hours is still undefined, not infinite', () {
      // Warranty paperwork flagged on a day off. Real, and not a division.
      expect(proficiency(flagged: 2.5, clocked: 0.0), isNull);
    });
  });

  group('zero flagged is a bad week, not a missing one', () {
    test('a dead week reads as zero rather than undefined', () {
      expect(efficiency(flagged: 0.0, available: 40.0), equals(0.0));
      expect(proficiency(flagged: 0.0, clocked: 40.0), equals(0.0));
    });
  });

  group('the ratios do not clamp', () {
    test('a very good week is reported as it is', () {
      expect(proficiency(flagged: 60.0, clocked: 40.0), closeTo(1.5, 1e-9));
    });
  });

  group('bad input throws rather than returning a plausible number', () {
    test('negative flagged hours', () {
      expect(() => proficiency(flagged: -1.0, clocked: 40.0), throwsArgumentError);
    });

    test('negative denominator', () {
      expect(() => efficiency(flagged: 10.0, available: -40.0), throwsArgumentError);
    });

    test('a denominator that is not a number', () {
      expect(() => proficiency(flagged: 10.0, clocked: double.nan), throwsArgumentError);
    });

    test('an infinite numerator', () {
      expect(() => efficiency(flagged: double.infinity, available: 40.0), throwsArgumentError);
    });
  });
}
