import 'package:care_circle/core/models/care_circle_models.dart';
import 'package:care_circle/core/providers/care_circle_service_provider.dart';
import 'package:care_circle/core/utils/care_event_formatter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final residentsProvider = FutureProvider<List<Resident>>((ref) async {
  final envelope = await ref.watch(careCircleServiceProvider).listResidents();
  return envelope.data;
});

final residentByIdProvider = Provider.family<Resident?, String>((
  ref,
  residentId,
) {
  final residents = ref.watch(residentsProvider).asData?.value ?? const [];
  return residents.where((r) => r.id == residentId).firstOrNull;
});

final dailySummaryProvider = FutureProvider.family<DailySummary?, String>((
  ref,
  residentId,
) async {
  final envelope = await ref
      .watch(careCircleServiceProvider)
      .getDailySummary(residentId);
  return envelope.data;
});

final careEventsProvider = FutureProvider.family<List<CareEvent>, String>((
  ref,
  residentId,
) async {
  final envelope = await ref
      .watch(careCircleServiceProvider)
      .listRawTimeline(residentId);
  return envelope.data
      .map(CareEvent.tryFromJson)
      .whereType<CareEvent>()
      .toList();
});

/// Enforces BOTH levels of privacy the docs call out: per-event `visibility`
/// AND the resident's category-level sharingPreferences. Raw mock data alone
/// does not filter this — the client must.
final familyVisibleCareEventsProvider =
    Provider.family<List<CareEvent>, String>((ref, residentId) {
      final events =
          ref.watch(careEventsProvider(residentId)).asData?.value ?? const [];
      final resident = ref.watch(residentByIdProvider(residentId));
      if (resident == null) return const [];
      final prefs = resident.sharingPreferences;

      return events.where((e) {
        if (e.visibility == Visibility.residentOnly) return false;
        return switch (e.category) {
          EventCategory.medication => prefs.shareMedicationStatus,
          EventCategory.meal => prefs.shareMealStatus,
          EventCategory.activity => prefs.shareActivityDetails,
          EventCategory.unknown => false,
        };
      }).toList();
    });

/// Groups family-visible events by calendar day. Days with no data simply
/// have no key — nothing is fabricated to fill gaps.
final careEventsByDayProvider =
    Provider.family<Map<DateTime, List<CareEvent>>, String>((ref, residentId) {
      final events = ref.watch(familyVisibleCareEventsProvider(residentId));
      final grouped = <DateTime, List<CareEvent>>{};
      for (final e in events) {
        if (e.recordedAt == null) {
          continue; // handled separately below, not silently dropped
        }
        grouped
            .putIfAbsent(CareEventFormatter.dayKey(e.recordedAt!), () => [])
            .add(e);
      }
      return grouped;
    });

/// Events with no usable timestamp — can't be placed on a day/week view,
/// so surfaced explicitly instead of disappearing.
final undatedCareEventsProvider = Provider.family<List<CareEvent>, String>((
  ref,
  residentId,
) {
  return ref
      .watch(familyVisibleCareEventsProvider(residentId))
      .where((e) => e.recordedAt == null)
      .toList();
});
