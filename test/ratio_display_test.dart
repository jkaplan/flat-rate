import 'package:test/test.dart';
import 'package:flat_rate/logic/ratio_display.dart';

void main() {
  group('a ratio that exists renders as a percentage', () {
    test('to one decimal place', () {
      expect(1.125.asPercent, equals('112.5%'));
      expect(0.8756.asPercent, equals('87.6%'));
    });

    test('zero renders as zero per cent, because it happened', () {
      expect(0.0.asPercent, equals('0.0%'));
    });

    test('a good week is not flattened to a hundred', () {
      expect(1.5.asPercent, equals('150.0%'));
    });
  });

  group('a ratio that does not exist renders as the absence mark', () {
    test('null is a dash', () {
      const double? undefined = null;
      expect(undefined.asPercent, equals(absenceMark));
    });

    test('the mark is defined once, and it is an em dash', () {
      expect(absenceMark, equals('—'));
    });
  });

  group('the two cases must not be confusable', () {
    // Nothing rests on this beyond the fact that a dead week and a week that
    // never happened mean opposite things to a technician's paycheck.
    test('zero and undefined never render the same', () {
      const double? undefined = null;
      expect(0.0.asPercent, isNot(equals(undefined.asPercent)));
    });
  });
}
