/// How a ratio reads on screen. Defined apart from the arithmetic so that
/// [absenceMark] has exactly one definition and the maths never formats.
library;

/// Shown when a ratio is undefined. Changing this changes it everywhere.
const String absenceMark = '—';

extension RatioDisplay on double? {
  String get asPercent {
    final ratio = this;
    if (ratio == null) return absenceMark;
    return '${(ratio * 100).toStringAsFixed(1)}%';
  }
}
