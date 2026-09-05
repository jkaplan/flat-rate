/// One job off a repair order: what it paid, and what it cost in time.
library;

enum PayType { customer, warranty, internal, recall }

class Job {
  Job({
    this.id,
    required this.repairOrder,
    required this.date,
    required this.payType,
    required this.writerId,
    required this.flaggedHours,
    required this.actualHours,
  }) {
    if (repairOrder.trim().isEmpty) {
      throw ArgumentError.value(
          repairOrder, 'repairOrder', 'a job needs a repair order number');
    }
    _guardHours(flaggedHours, 'flaggedHours');
    if (actualHours != null) _guardHours(actualHours!, 'actualHours');
  }

  final int? id;

  /// Text, not a number: 00412 is an identifier and is not 412.
  final String repairOrder;
  final DateTime date;
  final PayType payType;
  final int writerId;
  final double flaggedHours;

  /// Null until the technician records it, which is the habit this whole
  /// product is betting on. The model has to be able to say it is missing.
  final double? actualHours;

  bool get isComplete => actualHours != null;
}

void _guardHours(double hours, String name) {
  if (hours.isNaN || hours.isInfinite) {
    throw ArgumentError.value(hours, name, 'must be a real number of hours');
  }
  if (hours < 0) {
    throw ArgumentError.value(hours, name, 'hours cannot be negative');
  }
}
