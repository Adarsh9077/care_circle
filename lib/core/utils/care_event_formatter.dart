import 'package:care_circle/core/models/care_circle_models.dart';

class CareEventFormatter {
  CareEventFormatter._();

  static const Map<EventCategory, Set<String>> _knownStatuses = {
    EventCategory.medication: {'taken', 'missed', 'delayed', 'unknown'},
    EventCategory.meal: {'completed', 'partial', 'skipped', 'unknown'},
    EventCategory.activity: {'completed', 'cancelled', 'unknown'},
  };

  static String label(CareEvent e) =>
      '${_name(e)} — ${status(e)} · ${time(e.recordedAt)}';

  static String _name(CareEvent e) => switch (e.category) {
    EventCategory.medication => e.medicationLabel ?? 'Medication',
    EventCategory.meal => e.mealType ?? 'Meal',
    EventCategory.activity => e.activityType ?? 'Activity',
    EventCategory.unknown => 'Update',
  };

  static String status(CareEvent e) {
    final allowed = _knownStatuses[e.category] ?? const <String>{};
    if (!allowed.contains(e.status))
      return 'recorded'; // unrecognized/malformed → degrade, don't leak raw value
    return e.status.replaceAll('_', ' ');
  }

  static String time(DateTime? recordedAt) {
    if (recordedAt == null) return 'time not recorded';
    final local = recordedAt.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  /// Local calendar-day key, ignoring time-of-day — used for day/week grouping.
  static DateTime dayKey(DateTime dt) {
    final local = dt.toLocal();
    return DateTime(local.year, local.month, local.day);
  }
}
