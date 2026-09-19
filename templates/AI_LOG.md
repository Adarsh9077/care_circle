# AI Working Log

## Tools used
- Claude (chat) for architecture planning, porting the RN/TypeScript starter
  to Dart/Riverpod, and drafting screens, providers, and this documentation.

## Tasks delegated
- Translating TypeScript domain types (`careCircle.ts`) into null-safe Dart
  model classes, including a lenient `CareEvent.tryFromJson` for the
  malformed-record case.
- Porting `careCircleApi.ts`'s functions, delay behavior, envelope shape,
  and error codes into an equivalent Dart mock service.
- Scaffolding the design system (`AppColors`, `AppSizes`, `AppTextStyles`,
  `AppTheme`) and a reusable `AppScaffold` (SafeArea + RefreshIndicator)
  used on every screen instead of duplicating boilerplate.
- Drafting the Riverpod provider/notifier layer and the three screens
  (splash, resident list, resident home) plus the check-in bottom sheet.
- Drafting this README/DECISIONS/AI_LOG scaffolding itself.

## Notable AI errors / things caught and fixed
- An early version of the "See today" section read from `listCareEvents`
  (the pre-cleaned endpoint). That technically worked but meant the
  malformed-record handling built into the models was never actually
  exercised by the running app — a real gap against required capability
  #4. Caught by checking the built UI against the brief's five outcome
  constraints one by one, not by the AI flagging it unprompted.
- Privacy filtering initially only checked each event's `visibility` field.
  `docs/API.md` states both `visibility` and the resident's category-level
  `sharingPreferences` matter — the first pass would have shown, e.g., meal
  events to a family member even when the resident had turned off meal
  sharing. Fixed by adding a second filtering provider.

## Outputs rejected or materially changed (3+)
1. **Rejected:** an always-visible, data-forward home screen (status +
   events + vitals shown together on load). Replaced after the CEO
   clarification with a reassurance-card-first layout and a collapsed
   detail section, because the original direction read too much like a
   dashboard.
2. **Rejected:** auto-refresh / polling for "live" status updates. Decided
   against it deliberately — it would have encouraged exactly the
   compulsive-checking behavior residents complained about. Manual
   pull-to-refresh only.
3. **Changed:** the "See today" event list was rewritten to source from
   the raw/unvalidated timeline endpoint instead of the cleaned one (see
   AI errors above), and its status/timestamp rendering was rewritten to
   degrade gracefully instead of surfacing raw malformed values.
4. **Changed:** privacy filtering was extended from a single `visibility`
   check to a combined `visibility` + per-category `sharingPreferences`
   check after re-reading the API docs' "both levels matter" note.

## What I'd delegate differently next time
- Ask the AI to check generated UI against each of the brief's outcome
  constraints explicitly (as a checklist) at the point features are built,
  rather than after the fact — the malformed-data gap above would have
  been caught earlier that way.
- Have the AI draft the privacy-filtering logic directly from the docs'
  fixture-example table up front, instead of building a simpler
  single-field filter first and correcting it later.
