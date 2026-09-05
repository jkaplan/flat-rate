/// The two numbers a flat-rate technician is never handed.
///
/// Both are undefined rather than zero when their denominator is zero: a
/// technician who was not scheduled has no efficiency, and reporting 0% would
/// read as a bad week rather than as no week.
library;

double? efficiency({required double flagged, required double available}) => _ratio(
      flagged: flagged,
      denominator: available,
      denominatorName: 'available',
    );

double? proficiency({required double flagged, required double clocked}) => _ratio(
      flagged: flagged,
      denominator: clocked,
      denominatorName: 'clocked',
    );

double? _ratio({
  required double flagged,
  required double denominator,
  required String denominatorName,
}) {
  _guard(flagged, 'flagged');
  _guard(denominator, denominatorName);

  if (denominator == 0) return null;
  return flagged / denominator;
}

void _guard(double hours, String name) {
  if (hours.isNaN || hours.isInfinite) {
    throw ArgumentError.value(hours, name, 'must be a real number of hours');
  }
  if (hours < 0) {
    throw ArgumentError.value(hours, name, 'hours cannot be negative');
  }
}
