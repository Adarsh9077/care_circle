14:03 | Pivot home screen from detail-first to reassurance-first;
        hide event/vitals list behind an expandable "See today" section
      | CEO (via recruiter): app must not read as a clinical dashboard;
        residents have complained about feeling over-monitored
      | Rejected: always-visible timeline/vitals grid on home screen;
        auto-refresh/polling (removed in favor of manual pull-to-refresh only)



14:24 | Source "See today" from listRawTimeline (validated) instead of
        listCareEvents, and fall back unrecognized status/null timestamp
        to friendly labels
      | Required capability #4 ("behaves sensibly when data is malformed")
        wasn't actually exercised by the UI before this
      | Rejected: silently dropping the malformed record entirely —
        chose to show it degraded rather than hide it, since staff still
        recorded something happened



# Decision Log

| Time | Decision | Why | What I rejected or deferred |
|---|---|---|---|
| 11:05 AM | Port to Flutter/Riverpod instead of using the Expo/RN starter directly | Existing Flutter fluency; brief explicitly allows another framework if Android-reproducible | Sticking with Expo/RN, which would've cost setup time in an unfamiliar stack |
| 11:22 AM | Reproduce the mock service as a self-contained Dart class (`CareCircleMockService`) rather than a real backend call | Starter repo has no real API yet; brief says "assume APIs will eventually be available" | A thin HTTP layer against a stub server — unnecessary complexity for a 6-hour demo |
| 11:41 AM | Scope the home screen to: reassurance status, one collapsible detail section, one check-in action | "Smallest coherent product" instruction; only 5 outcome constraints are required, not a full feature list | Vitals screen, staff-update feed, photos, messaging, appointments — all deferred, none required by the brief |
| 12:03 PM | Home screen leads with a single reassurance card (status + one-line headline), not a data table | Client brief's core tension is reassurance vs. surveillance | A dense info-dense dashboard laying out every event/vital at once |
| 12:19 PM | No auto-refresh or polling anywhere; data loads on screen open and manual pull-to-refresh only | Reduces incentive to compulsively re-open/re-check the app | A live-updating feed or periodic background refresh |
| 12:48 PM | Pivot: after CEO clarification (via recruiter) that the app must not read as a clinical dashboard, and that residents have complained about feeling over-monitored, moved event/vitals detail behind a collapsed "See today" section instead of showing it by default | Direct client feedback mid-build; addresses both the family's need and the resident's complaint | Kept the always-visible event list I'd started with — replaced it with the collapsed version instead of layering a toggle on top |
| 1:12 PM | Source the "See today" list from the raw/unvalidated timeline endpoint (`listRawTimeline`) instead of the pre-cleaned `listCareEvents` | Required capability #4 ("behaves sensibly when data is malformed") wasn't actually being exercised by the UI otherwise | Sourcing from the clean endpoint only — would have made the malformed-record handling untested in the actual app |
| 1:34 PM | Enforce privacy at two levels: per-event `visibility` (never show `resident_only`) AND the resident's category-level `sharingPreferences` (medication/meal/activity) | docs/API.md: "Both levels matter" — filtering on visibility alone isn't sufficient | Filtering on `visibility` only, which would have exposed medication/meal/activity events even when the resident opted out of that category |
| 2:05 PM | Left vitals entirely out of scope; incident-mode toggle (`setVitalsIncident`) exists in the mock service but has no UI hookup | No official bulletin activated the incident during this build; vitals weren't part of the chosen scope | Building a vitals screen "just in case" — would have spent time on a feature not required and not exercised |
| 2:32 PM | Malformed/unrecognized event status and missing timestamps degrade to a generic friendly label ("recorded" / "time not recorded") rather than showing raw values | Brief: don't expose raw/unvalidated data; also avoids implying certainty the data doesn't support | Dropping the malformed record from the list entirely — chose to show it degraded since staff did record that something happened |