# CareCircle — Family Reassurance App (Flutter port)

## What this is
A reassurance-first mobile app for CareCircle families. A family member opens
the app and immediately sees whether their parent is okay today — not a
clinical dashboard of raw data. Details are available on request, never
forced on screen.

This is a Flutter/Riverpod port of the official Expo/React Native/TypeScript
starter. The port targets Android and reproduces the supplied mock service's
data shapes, delays, and error behavior in Dart rather than depending on the
Node/Expo runtime.

## Tested platform
- Android (emulator + physical device)
- Flutter 3.x / Dart 3.x, Riverpod 2.x, go_router

## Run steps
```bash
flutter pub get
flutter run
```
No environment variables, credentials, or backend are required — the mock
service (`CareCircleMockService`) is self-contained and ships with the same
fixture data as the original TypeScript fixtures (two residents, one stale
summary, one malformed timeline record, vitals incident toggle defaulted off).

To build a release APK:
```bash
flutter build apk --release
```

## Architecture / data flow
```
UI (views/widgets)
  ↑ watch
Riverpod providers (feature/home/providers, notifiers)
  ↑ call
CareCircleMockService (core/services)  — mirrors careCircleApi.ts:
  delay → ApiEnvelope{data, generatedAt} → throws MockApiException on error
  ↑ backed by
Fixture data (in-memory, mirrors fixtures.ts)
```
- Navigation: `go_router`, driven by a `RouterRefreshNotifier` that listens
  to `residentsProvider` (no auth in this app — family is assumed already
  signed in at the account level; not modeled here).
- State: `FutureProvider`/`FutureProvider.family` for reads,
  `AsyncNotifier.family` for the one write path (check-in requests).
- Models are null-safe by construction — `CareEvent.tryFromJson` returns
  `null` on unparseable records instead of throwing, and the UI degrades
  unrecognized status/missing timestamps to a friendly label rather than
  showing raw values or crashing.

## Screens (intentionally narrow scope)
1. **Splash** — loads residents; routes to resident home directly if there's
   only one, otherwise to a resident picker.
2. **Resident list** — only shown when there's more than one resident.
3. **Resident home** — the whole product:
   - Reassurance card (status word + one-line headline + freshness label)
   - Collapsible "See today" (recent medication/meal/activity events)
   - Privacy badge acknowledging the resident's sharing preferences
   - "Request a check-in" bottom sheet (create action)

## What's complete
- Full read path: residents, daily summary, care events (sourced from the
  raw/unvalidated timeline endpoint, not the pre-cleaned one, so malformed
  records are actually exercised)
- Create path: check-in request, including the 422-on-blank-reason case
- Two-level privacy enforcement: per-event `visibility` AND the resident's
  category-level `sharingPreferences` (medication/meal/activity)
- Loading, error, and empty states on every screen; pull-to-refresh instead
  of any polling/auto-refresh (deliberate — see DECISIONS.md)

## What's mocked / intentionally omitted
- Vitals, staff-update feed, photos, messaging, appointments, facility
  notices, multi-resident dashboards — all out of scope for this first
  version (see DECISIONS.md for why)
- No push notifications; check-in acknowledgement is a local, in-session
  confirmation only
- Vitals-503 incident handling exists in the mock service
  (`setVitalsIncident`) but has no UI hookup, since no official bulletin
  activated it and vitals aren't part of this scope
- No persisted local cache — a cold relaunch re-fetches from the mock
  service (acceptable since the mock service has no real network cost)

## Known limitations
- `residentByIdProvider` depends on `residentsProvider` already having
  resolved; if it's read before that, it returns `null` and the relevant
  screens show their "resident unknown" fallback rather than crashing —
  but this hasn't been stress-tested against real async race conditions.
- No accessibility audit beyond the design-token level (touch targets,
  contrast, no color-only status meaning) — not verified with a screen
  reader.
- The malformed-timeline handling covers the one fixture case the mock
  service ships; it hasn't been fuzzed against arbitrary garbage input.

## Freeze / submission commits
- Freeze commit: update readme file
- Final submission commit: update readme file