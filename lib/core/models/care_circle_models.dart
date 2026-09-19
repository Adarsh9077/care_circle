enum Visibility { family, limited, residentOnly }

Visibility visibilityFromJson(String v) => switch (v) {
  'family' => Visibility.family,
  'limited' => Visibility.limited,
  _ => Visibility.residentOnly,
};

class SharingPreferences {
  final bool shareMedicationStatus;
  final bool shareMealStatus;
  final bool shareActivityDetails;
  final bool shareVitalDetails;
  final String shareStaffNotes; // 'all' | 'limited' | 'none'
  final bool sharePhotos;

  const SharingPreferences({
    required this.shareMedicationStatus,
    required this.shareMealStatus,
    required this.shareActivityDetails,
    required this.shareVitalDetails,
    required this.shareStaffNotes,
    required this.sharePhotos,
  });

  factory SharingPreferences.fromJson(Map<String, dynamic> j) =>
      SharingPreferences(
        shareMedicationStatus: j['shareMedicationStatus'] as bool,
        shareMealStatus: j['shareMealStatus'] as bool,
        shareActivityDetails: j['shareActivityDetails'] as bool,
        shareVitalDetails: j['shareVitalDetails'] as bool,
        shareStaffNotes: j['shareStaffNotes'] as String,
        sharePhotos: j['sharePhotos'] as bool,
      );
}

class Facility {
  final String id;
  final String name;
  final String city;
  const Facility({required this.id, required this.name, required this.city});
  factory Facility.fromJson(Map<String, dynamic> j) =>
      Facility(id: j['id'], name: j['name'], city: j['city']);
}

class Resident {
  final String id;
  final String name;
  final String avatarInitials;
  final String relationship;
  final Facility facility;
  final String timezone;
  final SharingPreferences sharingPreferences;

  const Resident({
    required this.id,
    required this.name,
    required this.avatarInitials,
    required this.relationship,
    required this.facility,
    required this.timezone,
    required this.sharingPreferences,
  });

  factory Resident.fromJson(Map<String, dynamic> j) => Resident(
    id: j['id'],
    name: j['name'],
    avatarInitials: j['avatarInitials'],
    relationship: j['relationship'],
    facility: Facility.fromJson(j['facility']),
    timezone: j['timezone'],
    sharingPreferences: SharingPreferences.fromJson(j['sharingPreferences']),
  );
}

enum ReassuranceState { reassuring, needsAttention, notEnoughInformation }

ReassuranceState reassuranceFromJson(String v) => switch (v) {
  'reassuring' => ReassuranceState.reassuring,
  'needs_attention' => ReassuranceState.needsAttention,
  _ => ReassuranceState.notEnoughInformation,
};

class DailySummary {
  final String residentId;
  final String localDate;
  final ReassuranceState reassuranceState;
  final DateTime generatedAt;
  final String headline;
  final List<String> highlights;

  const DailySummary({
    required this.residentId,
    required this.localDate,
    required this.reassuranceState,
    required this.generatedAt,
    required this.headline,
    required this.highlights,
  });

  factory DailySummary.fromJson(Map<String, dynamic> j) => DailySummary(
    residentId: j['residentId'],
    localDate: j['localDate'],
    reassuranceState: reassuranceFromJson(j['reassuranceState']),
    generatedAt: DateTime.parse(j['generatedAt']),
    headline: j['headline'],
    highlights: List<String>.from(j['highlights'] ?? []),
  );
}

enum EventCategory { medication, meal, activity, unknown }

/// One class covers all three RN event types; unused fields stay null.
class CareEvent {
  final String id;
  final String residentId;
  final EventCategory category;
  final String
  status; // kept as raw string — validated per-category by the UI/notifier
  final DateTime? scheduledAt;
  final DateTime? recordedAt;
  final Visibility visibility;
  final String? note;

  // category-specific
  final String? medicationLabel;
  final String? mealType;
  final String? activityType;
  final int? durationMinutes;

  const CareEvent({
    required this.id,
    required this.residentId,
    required this.category,
    required this.status,
    required this.scheduledAt,
    required this.recordedAt,
    required this.visibility,
    this.note,
    this.medicationLabel,
    this.mealType,
    this.activityType,
    this.durationMinutes,
  });

  /// Returns null (rather than throwing) on malformed input — caller decides
  /// how to surface "couldn't read this record" per the brief's edge cases.
  static CareEvent? tryFromJson(Map<String, dynamic> j) {
    try {
      final categoryStr = j['category'] as String?;
      final category = switch (categoryStr) {
        'medication' => EventCategory.medication,
        'meal' => EventCategory.meal,
        'activity' => EventCategory.activity,
        _ => EventCategory.unknown,
      };
      final recordedAtRaw = j['recordedAt'];
      return CareEvent(
        id: j['id'] as String,
        residentId: j['residentId'] as String,
        category: category,
        status: (j['status'] as String?) ?? 'unknown',
        scheduledAt: j['scheduledAt'] != null
            ? DateTime.tryParse(j['scheduledAt'])
            : null,
        recordedAt: recordedAtRaw != null
            ? DateTime.tryParse(recordedAtRaw)
            : null,
        visibility: visibilityFromJson(
          (j['visibility'] as String?) ?? 'resident_only',
        ),
        note: j['note'] as String?,
        medicationLabel: j['medicationLabel'] as String?,
        mealType: j['mealType'] as String?,
        activityType: j['activityType'] as String?,
        durationMinutes: j['durationMinutes'] as int?,
      );
    } catch (_) {
      return null;
    }
  }
}

class VitalReading {
  final String id;
  final String residentId;
  final String type;
  final dynamic value; // String or num in source data
  final String unit;
  final DateTime measuredAt;
  final String? referenceLabel;
  final Visibility visibility;

  const VitalReading({
    required this.id,
    required this.residentId,
    required this.type,
    required this.value,
    required this.unit,
    required this.measuredAt,
    this.referenceLabel,
    required this.visibility,
  });

  factory VitalReading.fromJson(Map<String, dynamic> j) => VitalReading(
    id: j['id'],
    residentId: j['residentId'],
    type: j['type'],
    value: j['value'],
    unit: j['unit'],
    measuredAt: DateTime.parse(j['measuredAt']),
    referenceLabel: j['referenceLabel'],
    visibility: visibilityFromJson(j['visibility']),
  );
}

class StaffUpdate {
  final String id;
  final String residentId;
  final DateTime createdAt;
  final String authorRole;
  final String? text;
  final String? mediaUrl;
  final Visibility visibility;

  const StaffUpdate({
    required this.id,
    required this.residentId,
    required this.createdAt,
    required this.authorRole,
    this.text,
    this.mediaUrl,
    required this.visibility,
  });

  factory StaffUpdate.fromJson(Map<String, dynamic> j) => StaffUpdate(
    id: j['id'],
    residentId: j['residentId'],
    createdAt: DateTime.parse(j['createdAt']),
    authorRole: j['authorRole'],
    text: j['text'],
    mediaUrl: j['mediaUrl'],
    visibility: visibilityFromJson(j['visibility']),
  );
}

class CheckInRequestInput {
  final String residentId;
  final String reason;
  final String urgency; // 'routine' | 'soon'
  const CheckInRequestInput({
    required this.residentId,
    required this.reason,
    required this.urgency,
  });
}

class CheckInRequest extends CheckInRequestInput {
  final String id;
  final DateTime createdAt;
  final String status;
  const CheckInRequest({
    required super.residentId,
    required super.reason,
    required super.urgency,
    required this.id,
    required this.createdAt,
    required this.status,
  });
}

class ApiEnvelope<T> {
  final T data;
  final DateTime generatedAt;
  const ApiEnvelope({required this.data, required this.generatedAt});
}

class MockApiException implements Exception {
  final String message;
  final int status;
  final String code;
  MockApiException(this.message, this.status, this.code);
  @override
  String toString() => 'MockApiException($status $code): $message';
}
