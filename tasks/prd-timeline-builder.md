# PRD: Wedding-Day Timeline Builder

## Introduction

The Timeline Builder is a new in-app, Pro-gated feature for Daily I Do. A couple
answers a plain-language questionnaire (up to 41 questions, only 6 required), and
a deterministic engine generates their full wedding-day timeline — getting ready,
ceremony, cocktail hour, reception, after-party — plus the surrounding weekend
events. Most timeline lines are not asked directly; they are **derived** as
chained offsets from a handful of **anchors**, so answering just the 6 required
questions already produces a complete, sensible timeline, and every additional
answer refines it.

The generated timeline is hand-editable (adjust any time, reorder sequenced
moments), shows conflict warnings, and can display the "first look" and "no first
look" versions side by side for undecided couples. The feature is reached from a
new **Tools** hub that replaces the center tab button's old destination
(Settings), and also houses a link to the existing web Budget Tracker.

The timing logic is derived from the planners' first-look / no-first-look sheets
and six real 2026 weddings (Caroline & Chris, Claire & Justin, Laura & Jonathan,
Mallory & Morgan, Megan & Jeff, Scott & Courtney), which serve as the engine's
validation fixtures.

## Goals

- Let a couple generate a complete, professional wedding-day timeline from as few
  as 6 answers, with sensible defaults filling everything else.
- Produce a **deterministic, testable** timing engine that reproduces the six
  real 2026 timelines.
- Support the two decisions that reshape the whole day: **first look (yes/no)**
  and **ceremony/reception at the same venue (yes/no)**.
- Support **per-partner getting-ready tracks** (two full tracks when needed, e.g.
  two brides each with their own hair/makeup team and photographer).
- Let couples **edit** derived times and **reorder** sequenced moments without
  losing those edits when they later change an answer.
- Surface **conflict warnings** (e.g. hair & makeup before 7 AM, first look after
  sunset, coverage ending before the cake cutting).
- Compute **sunset / golden hour** from the wedding date and venue location.
- Offer a **"show me both"** comparison of the first-look and no-first-look days.
- Gate the feature on the existing **"Pro"** entitlement and persist everything to
  Supabase using the app's anon-key pattern.
- Introduce a **Tools** hub in the navigation and relocate **Settings** to the
  To-Do page.

## User Stories

Stories are grouped into epics in build order. Each is scoped to a focused
session. Because this is a SwiftUI iOS app, UI stories are verified in the **iOS
Simulator** (the run/simulator tooling), not a browser.

---

### Epic A — Navigation & Tools hub

#### US-A1: Add Settings gear to the To-Do page
**Description:** As a user, I want to reach Settings from the To-Do page so it is
still accessible after the center button changes.

**Acceptance Criteria:**
- [ ] Add a `navigationBarTrailing` toolbar button (gear icon,
      `gearshape`) to `ChecklistView` that sets `showSettings = true`.
- [ ] The existing `.sheet(isPresented: $showSettings)` presents `SettingsView`
      and dismisses correctly (plumbing already exists at
      `ChecklistView.swift:85`).
- [ ] Thread `onRestartTutorial` into the To-Do Settings sheet so "Restart
      Tutorial" still works (today the sheet passes only `onDone`).
- [ ] Opening Settings from the gear logs `logSettingsOpened()`.
- [ ] After Settings closes, the couple photo used by the center button refreshes
      (move the refresh trigger from tab-change to the sheet's `onDone`).
- [ ] Typecheck/build passes.
- [ ] Verify in iOS Simulator.

#### US-A2: Create the Tools hub screen
**Description:** As a user, I want a Tools screen with the couple's photo and a
list of tools so I have one place for extras.

**Acceptance Criteria:**
- [ ] New `ToolsHubView` shows couple photo + names at the top (reuse the photo
      loaded by `OnboardingViewModel.loadCouplePhoto()`).
- [ ] Shows two cards: **Timeline Builder** and **Budget Tracker**.
- [ ] Each card shows a Pro indicator when the user is not subscribed.
- [ ] Typecheck/build passes.
- [ ] Verify in iOS Simulator.

#### US-A3: Point the center tab button at the Tools hub
**Description:** As a user, I want the center button to open Tools instead of
Settings.

**Acceptance Criteria:**
- [ ] `MainTabView` tab 2 renders `ToolsHubView` instead of `SettingsView`
      (`DailyIDoApp.swift:101`).
- [ ] The center button in `CustomTabBar` still shows the couple photo and the
      selected-state ring (`DailyIDoApp.swift:442`).
- [ ] Tab-2 open logs `logTabOpened("tools")` instead of `logSettingsOpened()`
      (`DailyIDoApp.swift:131`).
- [ ] Settings is no longer reachable from the center button (only from the To-Do
      gear).
- [ ] Typecheck/build passes.
- [ ] Verify in iOS Simulator.

#### US-A4: Link the Budget Tracker
**Description:** As a user, I want to open the Budget Tracker from Tools.

**Acceptance Criteria:**
- [ ] Tapping the Budget Tracker card (when Pro) opens
      `https://www.thedailyido.com/budgettracker` in `SafariView` (reuse the
      existing component used by Book-a-Call).
- [ ] Tapping while not Pro shows the paywall (`showProBadgePaywall` pattern).
- [ ] Opening logs an analytics event (e.g. `tool_opened` = `budget_tracker`).
- [ ] Typecheck/build passes.
- [ ] Verify in iOS Simulator.

---

### Epic B — Timing engine (pure, no UI)

#### US-B1: Define the engine data model
**Description:** As a developer, I need typed models for answers, nodes, rules,
overrides, and warnings so the engine is well-structured and Codable for storage.

**Acceptance Criteria:**
- [ ] `TimelineQuestionnaire` (Codable) holds all answers (see Appendix B),
      including `partners: [PartnerInfo]` and per-partner getting-ready sections.
- [ ] `FirstLookChoice` enum: `.yes | .no | .both`.
- [ ] `TimelineNode`: stable `id: String`, `label`, `track`, `rule`,
      `durationMin`, `phase`, `isEditable`, `isSequenced`.
- [ ] `NodeTrack` enum: `.shared`, `.partner(PartnerID)`, `.vendor(VendorType)`.
- [ ] `NodeRule` enum: `.anchor(TimeOfDay)`, `.offset(from: String, minutes: Int)`,
      `.sequenced(order: Int, durationMin: Int)`, `.lookup(.sunset, offsetMin: Int)`.
- [ ] `TimelineOverride`: `nodeId`, `timeOverride: TimeOfDay?`,
      `orderOverride: Int?`, `isSkipped: Bool?`.
- [ ] `TimelineWarning`: `id`, `severity`, `message`, `relatedNodeIds`.
- [ ] `TimeOfDay` value type (minutes from midnight on the wedding date) with
      arithmetic helpers.
- [ ] Typecheck/build passes.

#### US-B2: Resolve nodes in dependency order
**Description:** As a developer, I need the engine to compute every node's time by
resolving anchors first, then offsets/sequences in dependency order.

**Acceptance Criteria:**
- [ ] `TimelineEngine.generate(_ answers:, sunset: TimeOfDay?) -> TimelineResult`
      is a pure function (no network, no disk).
- [ ] Anchors resolve from answers; offset/sequenced nodes resolve via topological
      order over their dependencies.
- [ ] Cyclic or missing dependencies are reported as a structured error, not a
      crash.
- [ ] Unit tests cover a minimal graph (anchor → offset → sequenced).

#### US-B3: Implement getting-ready + ceremony rules (both branches)
**Description:** As a developer, I need the pre-ceremony chain for first-look and
no-first-look, including per-partner tracks and the HMU formula.

**Acceptance Criteria:**
- [ ] Hair & makeup start formula implemented (Appendix C): uses the stylist's
      given time if provided, else `End − (rounds × 45) − 45 − 30`, where rounds =
      ceil of the larger of (hair people ÷ hair artists) and (makeup people ÷
      makeup artists).
- [ ] First-look chain implemented per Appendix C ("Before the ceremony: first
      look").
- [ ] No-first-look chain implemented per Appendix C, counting back from each
      partner's **own departure** (arrival − that partner's drive).
- [ ] Ceremony length derived from ceremony type (civil 30 / religious 45 / full
      service 60), plus tradition/extra minutes.
- [ ] Per-partner tracks produced independently (two tracks when two partners both
      get ready).

#### US-B4: Implement cocktail-hour + reception rules
**Description:** As a developer, I need the reception chain and the cocktail-hour
timing for both branches.

**Acceptance Criteria:**
- [ ] Cocktail-hour start = ceremony end (+ travel if reception is elsewhere);
      length default 60 min (first look) / 90 min (no first look).
- [ ] Reception chain implemented per Appendix C ("Reception"), from introductions
      through reception end anchor.
- [ ] Vendor-driven lines (photo/video depart = arrival + hours booked; band/DJ
      setup; ceremony musicians) implemented.

#### US-B5: Implement skip / move / reorder logic
**Description:** As a developer, I need skipped and reordered items to re-chain
correctly.

**Acceptance Criteria:**
- [ ] Skipping an item pulls the next item into its slot and shifts the rest
      earlier (Appendix C "When items are skipped or moved").
- [ ] No grand entrance → couple seated at R + 20 min; chain continues.
- [ ] Toasts during dinner → peer toasts at salad + 15 min (5 min each); dinner
      stays at salad + 30 min.
- [ ] First dance after dinner → placed right before parent dance 1.
- [ ] Sunset photos that land on a must-attend moment move to the nearest open gap.

#### US-B6: Validate against the six real 2026 weddings
**Description:** As a developer, I need the engine proven against ground truth.

**Acceptance Criteria:**
- [ ] Each of the six weddings is encoded as a `TimelineQuestionnaire` fixture with
      its known expected key times.
- [ ] A test asserts the engine reproduces each wedding's anchor and derived times
      within tolerance (exact for anchors; documented tolerance for derived).
- [ ] At least one fixture exercises two full getting-ready tracks (Mallory &
      Morgan) and one exercises an off-site ceremony with a travel gap (Caroline &
      Chris).
- [ ] All engine tests pass.

---

### Epic C — Questionnaire (data, UI, persistence)

#### US-C1: Supabase schema for timelines
**Description:** As a developer, I need a table to persist answers and overrides.

**Acceptance Criteria:**
- [ ] Migration adds `wedding_timelines` (Appendix D): `user_id`, `questionnaire`
      jsonb, `overrides` jsonb, `first_look_choice` text, `updated_at`.
- [ ] RLS policy matches the app's existing anon-key pattern.
- [ ] One row per user (upsert on `user_id`).
- [ ] Migration SQL saved to the repo and runnable.

#### US-C2: Questionnaire persistence service
**Description:** As a developer, I need load/save of the questionnaire + overrides.

**Acceptance Criteria:**
- [ ] `SupabaseService` methods: fetch, upsert questionnaire, upsert overrides.
- [ ] Saves debounce/batch so typing doesn't thrash the network.
- [ ] Works offline then syncs (local cache is source of truth for the session).
- [ ] Typecheck/build passes.

#### US-C3: Questionnaire flow UI
**Description:** As a user, I want to answer the questions in short, plain-language
sections with save-and-resume.

**Acceptance Criteria:**
- [ ] Nine sections (Appendix B), each a short screen; reuse existing onboarding
      form patterns.
- [ ] The 6 required questions (★) gate completion; all others offer "Not sure"
      which applies the documented default.
- [ ] Progress indicator; the couple can leave and resume where they left off.
- [ ] Section 3 (Getting ready) is answered **per partner**, producing one track
      each.
- [ ] Venue-fact questions are framed "check with your venue" with a default when
      skipped.
- [ ] Typecheck/build passes.
- [ ] Verify in iOS Simulator.

---

### Epic D — Timeline view (read-only)

#### US-D1: Render the generated timeline
**Description:** As a user, I want to see my full day as a clear vertical timeline.

**Acceptance Criteria:**
- [ ] Vertical, time-ordered timeline grouped by phase (Getting ready → Ceremony →
      Cocktail hour → Reception → After).
- [ ] Each line shows time, label, and its track (Partner 1 / Partner 2 / shared /
      vendor) when relevant.
- [ ] Per-partner getting-ready shown as distinct tracks/labels.
- [ ] Weekend events (rehearsal, rehearsal dinner, brunch, etc.) shown in their own
      section.
- [ ] Typecheck/build passes.
- [ ] Verify in iOS Simulator.

---

### Epic E — Editing & overrides

#### US-E1: Edit a line's time
**Description:** As a user, I want to adjust any suggested time.

**Acceptance Criteria:**
- [ ] Tapping a line lets the user set a new time; stored as a `TimelineOverride`
      keyed by node id.
- [ ] Rendered timeline applies overrides over the engine baseline.
- [ ] A "reset to suggested" action clears the override for that line.
- [ ] Typecheck/build passes.
- [ ] Verify in iOS Simulator.

#### US-E2: Reorder sequenced moments
**Description:** As a user, I want to reorder moments like toasts and dances.

**Acceptance Criteria:**
- [ ] Sequenced items (toasts, first dance, parent dances, cake cutting, bouquet
      toss, 2nd look) are drag-reorderable.
- [ ] Reordering stores an `orderOverride` and the chain re-spaces using default
      durations.
- [ ] Typecheck/build passes.
- [ ] Verify in iOS Simulator.

#### US-E3: Edits survive answer changes
**Description:** As a user, I want my manual edits kept when I change an answer.

**Acceptance Criteria:**
- [ ] Changing a questionnaire answer recomputes the baseline but preserves
      overrides by node id.
- [ ] If an overridden node no longer exists after a change, its override is
      dropped silently.
- [ ] Typecheck/build passes.
- [ ] Verify in iOS Simulator.

---

### Epic F — Conflict warnings

#### US-F1: Compute and show warnings
**Description:** As a user, I want to be warned about timing problems.

**Acceptance Criteria:**
- [ ] Warnings implemented (Appendix C "Warnings"): HMU before 7 AM; no first look
      with 60-min cocktail hour; no first look with 20+ family photo groupings;
      photographer coverage ends before cake cutting or parent dances; sunset
      before ceremony end (sunset photos impossible).
- [ ] Warnings render as banners on the timeline, linked to the relevant lines.
- [ ] Warnings recompute after edits and answer changes.
- [ ] Typecheck/build passes.
- [ ] Verify in iOS Simulator.

---

### Epic G — Sunset / golden hour

#### US-G1: Sunset service
**Description:** As a developer, I need sunset time from date + venue.

**Acceptance Criteria:**
- [ ] `SunsetService` geocodes the ceremony venue (city/ZIP) via `CLGeocoder` to
      coordinates.
- [ ] Computes sunset for the wedding date with a standard solar algorithm
      (offline once coordinates are known).
- [ ] Returns `nil` gracefully when the venue can't be geocoded (no network, bad
      input); the engine then omits golden-hour and sunset-dependent warnings.
- [ ] The resolved sunset `TimeOfDay` is passed into `TimelineEngine.generate` (the
      engine stays pure).
- [ ] Unit tests for the solar calc at known lat/long/date values.

#### US-G2: Golden-hour line
**Description:** As a user, I want sunset photos placed in my timeline.

**Acceptance Criteria:**
- [ ] When the couple wants sunset photos and sunset is known, a golden-hour line
      appears at `sunset − 30 min` on a separate couple track.
- [ ] If it collides with a must-attend moment, it moves to the nearest open gap
      (ties into US-B5).
- [ ] Typecheck/build passes.
- [ ] Verify in iOS Simulator.

---

### Epic H — Show me both

#### US-H1: Compare first-look vs no-first-look
**Description:** As an undecided couple, I want to see both versions side by side.

**Acceptance Criteria:**
- [ ] When first-look answer is "Show me both," the engine generates both versions.
- [ ] The timeline view offers First look / No first look / Compare; Compare shows
      the two side by side.
- [ ] Choosing one persists it as the couple's `first_look_choice`.
- [ ] Typecheck/build passes.
- [ ] Verify in iOS Simulator.

---

### Epic I — Gating, analytics, polish

#### US-I1: Pro gating
**Description:** As the business, I want the Timeline Builder behind Pro.

**Acceptance Criteria:**
- [ ] Opening the Timeline Builder while not subscribed shows the paywall (same
      `isSubscribed` / "Pro" entitlement check the checklist uses).
- [ ] Subscribed users reach the questionnaire/timeline directly.
- [ ] Book-a-Call upsell shown at the end of the timeline ("want a planner to
      review this?") linking to the existing Book-a-Call flow.
- [ ] Typecheck/build passes.
- [ ] Verify in iOS Simulator.

#### US-I2: Analytics
**Description:** As the team, I want to measure usage.

**Acceptance Criteria:**
- [ ] Events: tool opened, questionnaire started, questionnaire completed, timeline
      generated, timeline edited, first-look choice made, warning shown.
- [ ] Events logged through `AnalyticsService` to Supabase analytics.
- [ ] Typecheck/build passes.

## Functional Requirements

- FR-1: The center tab button (tab 2) must open a new `ToolsHubView` instead of
  `SettingsView`.
- FR-2: Settings must be reachable from the To-Do page via a toolbar gear button.
- FR-3: The Tools hub must list Timeline Builder (native) and Budget Tracker
  (opens `https://www.thedailyido.com/budgettracker` in `SafariView`).
- FR-4: Both Tools must be gated on the "Pro" entitlement; non-subscribers see the
  paywall.
- FR-5: The questionnaire must present 41 questions across 9 sections; only the 6
  starred questions are required; every other question must offer "Not sure" with
  the documented default.
- FR-6: The system must persist the questionnaire and overrides to a
  `wedding_timelines` Supabase row, one per user.
- FR-7: `TimelineEngine.generate` must be a pure function of (answers, sunset) and
  must not perform I/O.
- FR-8: The engine must resolve anchors, then offsets and sequenced items in
  dependency order, producing a complete timeline from the 6 required answers
  alone.
- FR-9: The engine must support first-look and no-first-look branches, same-venue
  vs. different-venue travel, and per-partner getting-ready tracks.
- FR-10: The engine must apply the skip/move/reorder rules in Appendix C.
- FR-11: The engine must reproduce the six 2026 reference timelines in tests.
- FR-12: The timeline view must render phases in order with per-track labels and a
  weekend-events section.
- FR-13: Users must be able to edit any line's time (stored as an override by node
  id) and reset to suggested.
- FR-14: Users must be able to reorder sequenced moments.
- FR-15: Manual overrides must survive questionnaire answer changes; orphaned
  overrides are dropped.
- FR-16: The system must compute and display the warnings in Appendix C.
- FR-17: `SunsetService` must compute sunset from date + geocoded venue, degrade
  gracefully to `nil`, and feed the engine; golden-hour line placed at
  `sunset − 30 min`.
- FR-18: When first-look = "Show me both," the system must generate both versions
  and offer a compare view; selecting one persists the choice.
- FR-19: The system must log the analytics events in US-I2.

## Non-Goals (Out of Scope for v1)

- **Native** budget tracker (v1 links to the existing web tool).
- Vendor-facing filtered timelines (each vendor seeing only their lines).
- Dedicated planner/coordinator arrival/departure lines keyed off question 1.6.
- A traditions library of pre-built add-on blocks (ketubah, hora, tea ceremony)
  with their own durations/placement — v1 only adds flat extra minutes/slots.
- PDF export / printable timeline.
- Multiple weddings/timelines per user (one per account).
- Venue-specific rules or a venue database (everything is "check with your venue"
  with defaults).
- A web version of the Timeline Builder (app-only for now; engine may be ported
  later).
- Push notifications or reminders based on the timeline.

## Design Considerations

- **Navigation.** 3-slot custom tab bar stays: Calendar (0) · center photo → Tools
  (2) · To-Do (1). The center button keeps the couple photo as its icon. Tools hub
  opens to couple photo + names, then tool cards.
- **Settings relocation.** Gear in the To-Do (`ChecklistView`) navigation bar;
  the Settings sheet plumbing already exists and only needs a trigger +
  `onRestartTutorial` threaded through.
- **Reuse.** `SafariView` (Book-a-Call), onboarding multi-step form components,
  existing paywall trigger, `OnboardingViewModel.loadCouplePhoto()`, app color
  constants, `HapticManager`.
- **Labels.** Use Partner 1 / Partner 2 (with a per-person Bride/Groom/Partner
  label), never bride/groom globally.
- **Timeline UI.** Vertical, phase-grouped, per-track labels; tappable lines for
  editing; drag handles on sequenced items; warning banners; a compare mode for
  show-both.

## Technical Considerations

- **Engine purity.** `TimelineEngine` takes answers + an optional pre-resolved
  sunset time and returns nodes + warnings. All I/O (geocoding, Supabase) lives
  outside it. This keeps it unit-testable against the six fixtures.
- **Dependency resolution.** Model the timeline as nodes with dependencies;
  topologically sort; anchors are roots. Skip/reorder then fall out of
  re-resolution rather than special cases.
- **Overrides model.** Baseline (engine) + overrides (per node id) applied at
  render. "Reset to suggested" clears an override. Answer change → recompute
  baseline, keep overrides by id, drop orphans.
- **Time model.** Day-of items use `TimeOfDay` (minutes from midnight on the
  wedding date). Weekend events carry their own dates.
- **Sunset.** `CLGeocoder` (built-in, free) for city/ZIP → coordinates; standard
  solar algorithm for sunset; offline after geocode. Requires network + a
  parseable venue string; degrade to `nil`.
- **Persistence.** `wedding_timelines` jsonb columns (Appendix D), anon-key RLS
  pattern, upsert by `user_id`, debounced saves, offline-first with sync.
- **Gating.** Reuse the single "Pro" entitlement check (`isSubscribed`).
- **Integration points.** `DailyIDoApp.swift` (MainTabView tab 2, CustomTabBar
  center button, analytics), `ChecklistView.swift` (Settings gear + sheet),
  `SupabaseService`, `AnalyticsService`, `SafariView`, paywall trigger.

## Success Metrics

- Engine reproduces all six 2026 reference timelines in tests (hard gate).
- A couple can generate a usable timeline from only the 6 required answers.
- Measurable funnel: Tools opened → questionnaire started → completed → timeline
  generated.
- Timeline Builder usage correlates with Pro conversions and Book-a-Call taps
  (tracked via analytics).

## Open Questions

- Exact tolerance for "derived" times when matching the six fixtures (anchors are
  exact; what minute tolerance is acceptable for chained items?).
- Default placement for "show me both": which branch is the persisted default if
  the couple never explicitly chooses?
- Should reordering a sequenced moment ever change its default duration, or only
  its position?
- Does the Book-a-Call upsell at the end of the timeline need different copy than
  the Settings one?
- Deferred-but-cheap: planner lines (1.6) are low-effort — pull into v1 if desired?

---

## Appendix A — Item types

| Type | Examples | How the tool sets it |
|---|---|---|
| Anchor | Ceremony start, cocktail hour start, reception end, after-party end, venue access | Asked directly (often fixed by venue/church) |
| Derived | HMU start, bouquet delivery, prelude, photos complete, room reveal, salad, entrée | Anchor ± default offset, editable |
| Sequenced | Toasts, first dance, parent dances, cake cutting, bouquet toss, 2nd look | Couple picks order; tool spaces with default durations |
| Lookup | Sunset, golden hour | Date + venue location |
| Vendor-driven | Photo/video departure, band setup, shuttle runs | Contract hours / vendor setup needs |

Two answers reshape the whole day:
- **First look (yes/no).** Yes moves couple/party/family photos before the
  ceremony, so HMU starts ~1.5–2 hrs earlier. No puts those photos in cocktail
  hour (or between a church ceremony and the reception).
- **Same venue? (yes/no).** No adds travel legs + transportation and a gap often
  used for photos (Caroline & Chris: Holy Redeemer → Eastward Ho! added 2 hrs
  between ceremony end and cocktail hour).

Build note: Partner 1 / Partner 2 with per-person getting-ready tracks, not
bride/groom. Mallory & Morgan needed two full bride tracks, each with its own HMU
team and photographer.

## Appendix B — Questionnaire (41 questions, 9 sections)

★ = required. All others offer "Not sure" → the default shown.

### 1. The basics
- 1.1 ★ Wedding date → sunset time, weekend calendar.
- 1.2 Names + how to refer to you (Bride/Groom/Partner) → labels on every line.
  Default: Partner.
- 1.3 Approx. guest count → prelude length, shuttle needs. Default: 100.
- 1.4 ★ Ceremony location (venue + city/ZIP) → sunset lookup, time zone.
- 1.5 Reception same place? If not, drive minutes → travel between ceremony and
  reception. Default: 20 min.
- 1.6 Which vendors (checklist: planner/coordinator, photographer, videographer,
  hair, makeup, florist, officiant, ceremony musicians, band, DJ, transportation,
  rentals/tent, photo booth, other) → which vendor lines appear.
- 1.7 Vendor setup start time at reception (check with venue) → earliest setup and
  delivery. Default: 3 hrs before cocktail hour.
- 1.8 Any part outdoors? Rain backup? (Yes/No + text) → rain plan notes.

### 2. Ceremony
- 2.1 ★ Ceremony start time → the main anchor.
- 2.2 Ceremony type (Civil / Religious / Full religious service / Cultural) →
  length 30/45/60. Default: Civil.
- 2.3 Traditions (ketubah/license signing, unity candle, handfasting, tea
  ceremony, readings, other) → extra minutes, pre-ceremony signing slot. Default:
  None.
- 2.4 Ceremony exit (Walk out / Petal toss / Bubbles / Other) → ceremony end line.
  Default: Walk out.

### 3. Getting ready (answered per partner → one track each)
- 3.1 Where getting ready (address/hotel) → delivery & pickup locations.
- 3.2 Known HMU start & end times → HMU lines (else estimate via 3.3–3.4).
- 3.3 How many getting hair / makeup (two numbers) → estimated start.
- 3.4 How many hair artists / makeup artists → estimated start. Default: 2.
- 3.5 Plan lunch while getting ready? (Yes/No) → lunch line. Default: Yes.
- 3.6 Flowers delivered to you? (Yes/No) → flower delivery line. Default: Yes.
- 3.7 Drive from getting-ready to ceremony (minutes / on site) → departure time
  (no-first-look counts back from this). Default: 15 min.

### 4. Photos
- 4.1 ★ First look? (Yes / No / Show me both) → photos before vs after ceremony.
  Default: show both side by side.
- 4.2 Other special pre-ceremony moments (first look with a parent, wedding party
  reveal, letters/gifts, private vows, photos with a pet) → 15-min slots. Default:
  None.
- 4.3 Family photo groupings (Under 10 / 10–20 / 20+) → block 15/30/45 min.
  Default: 10–20.
- 4.4 Sunset photos? (Yes/No) → golden-hour slot. Default: Yes.
- 4.5 Photographer start + hours → arrival/departure. Default: 1 hr before dressed;
  8 hrs.
- 4.6 Videographer start + hours → arrival/departure. Default: same as
  photographer.

### 5. Getting around
- 5.1 Wedding party to ceremony (Driving / Shuttle or trolley / Already there) →
  departure lines. Default: Already there.
- 5.2 Guest shuttles? From where? (Yes/No + hotel list) → shuttle pickups + end-of-
  night runs. Default: No.
- 5.3 Getaway car? (Yes/No) → couple exit line. Default: No.

### 6. Cocktail hour
- 6.1 ★ Cocktail hour length (60 / 90 min; starts right after ceremony + travel) →
  when guests move to dinner. Default: 60 with first look, 90 without.
- 6.2 Spend time at cocktail hour? (Whole time / Part of it / Taking photos) →
  couple photo block. Default: Part of it.

### 7. Reception
- 7.1 ★ Reception end time (often venue-set) → end anchor.
- 7.2 Grand entrance? (No / Just us / With wedding party) → entrance line. Default:
  Just us.
- 7.3 First dance when? (Right after entrance / After dinner / Skipping) →
  placement. Default: Right after entrance.
- 7.4 Toasts: who + when (Before / During / After dinner) → 5-min slots. Default:
  Before dinner.
- 7.5 Dinner service (Plated / Buffet / Stations / Family style) → course timing.
  Default: Plated.
- 7.6 Special dances (parent dances, wedding party dance, anniversary dance,
  other) → dance block after dinner. Default: Parent dances.
- 7.7 Cake cutting (In front of guests / Privately / No cake) → cake line. Default:
  In front of guests.
- 7.8 Other moments (bouquet toss, garter toss, hora, money dance, other) → slots
  during dancing. Default: None.
- 7.9 Second outfit? (Yes/No) → 2nd look line. Default: No.
- 7.10 Late-night snack? (Yes/No) → late-night line. Default: No.
- 7.11 End of night (Last dance / Send-off / Nothing planned) → final line.
  Default: Last dance.

### 8. After the reception
- 8.1 After party? Where + until when (Yes/No + place + end) → after-party lines.
  Default: No.
- 8.2 Who takes gifts/cards/personal items home (name) → end-of-night note.

### 9. The rest of the weekend
- 9.1 Rehearsal (date + time) → rehearsal line. Default: day before, 4 PM.
- 9.2 Rehearsal dinner / welcome party (per event: date, time, place) → event
  lines.
- 9.3 Pre-wedding appointments/activities (nails, hair trial, golf: date/time/
  place) → pre-wedding lines.
- 9.4 Day-after brunch? (Yes/No + time + place) → brunch line. Default: 10 AM.

## Appendix C — Timing rules

Shorthand: **C** = ceremony start · **CE** = ceremony end (C + length) · **CH** =
cocktail hour start · **R** = cocktail hour end (guests go in) · **E** = reception
end.

### Hair & makeup start (both versions)
If the stylist gave a start time, use it. Otherwise:
`Start = End − (rounds × 45) − 45 (bride) − 30 (touch-ups)`
Rounds = ceil of the larger of (hair people ÷ hair artists) and (makeup people ÷
makeup artists). Example: 6 hair + 6 makeup, 2 hair + 2 makeup artists = 3 rounds =
3.5 hrs total.

### Before the ceremony: first look (example: 5:00 PM ceremony)
| Item | Rule | Example |
|---|---|---|
| Groom & groomsmen start | First look − 1.5 hrs | 1:30 |
| Bouquets delivered | Dress on − 60 min | 1:30 |
| Photographer arrives | Dress on − 60 min | 1:30 |
| Hair & makeup end | First look − 60 min | 2:00 |
| Getting-ready photos | Dress on − 15 min | 2:15 |
| Dress on | First look − 30 min | 2:30 |
| First look + couple portraits | Guest arrival − 1.5 hrs | 3:00 |
| Family photos | First look + 30 min | 3:30 |
| Wedding party photos | Family photos + 30 min | 4:00 |
| Photos done, couple hides | Guest arrival | 4:30 |
| Guest arrival / prelude | C − 30 min | 4:30 |
| Officiant arrives, mic check | C − 15 min | 4:45 |

### Before the ceremony: no first look (example: 4:00 PM ceremony, 15-min drive)
Everything counts back from departing, which = that partner's arrival − their
drive (on site → drive = 0).
| Item | Rule | Example |
|---|---|---|
| Groom & groomsmen start | Groom's departure − 1.5 hrs (groom's departure = groom arrival − his drive) | 1:30 |
| Bouquets delivered | Dress on − 60 min | 1:45 |
| Photographer arrives | Dress on − 60 min | 1:45 |
| Hair & makeup end | Departing − 60 min | 2:15 |
| Getting-ready photos | Dress on − 15 min | 2:30 |
| Dress on | Departing − 30 min | 2:45 |
| Groom & groomsmen arrive | C − 45 min | 3:15 |
| Bride departs | Bride arrival − drive time | 3:15 |
| Guest arrival / prelude | C − 30 min | 3:30 |
| Bride & bridesmaids arrive | C − 15 min | 3:45 |

Change from the team sheet: the groom's start ties to **his own** departure, not
the bride's, so a groom getting ready farther away still gets a full 1.5 hrs.

### Ceremony and cocktail hour
| Item | Rule |
|---|---|
| Ceremony length | 30 civil · 45 religious · 60 full service |
| Cocktail hour start (CH) | CE, + drive time if reception elsewhere |
| Cocktail hour length | 60 min (first look) / 90 min (no first look) |
| Couple photos (no first look) | CE until CH + 45 min |
| Couple returns to cocktail hour (no first look) | CH + 45 min |
| Bouquets moved to reception | CH |
| Room reveal to couple | R − 10 min |
| Band/DJ setup | CH − 2 hrs (C − 1 hr if they also do ceremony sound) |
| Ceremony musicians arrive | C − 45 min |

### Reception (both versions, example: cocktail hour ends 6:00)
| Item | Rule | Example |
|---|---|---|
| Introductions | R + 20 min | 6:20 |
| First dance | Introductions + 5 min | 6:25 |
| Welcome toast | First dance + 5 min | 6:30 |
| 1st peer toast | Welcome toast + 5 min | 6:35 |
| 2nd peer toast | 1st peer toast + 5 min | 6:40 |
| Blessing (optional) | 2nd peer toast + 5 min | 6:45 |
| Salad served | Last toast or blessing + 5 min | 6:50 |
| Vendor meals | With salad | 6:50 |
| Dinner served | Salad + 30 min | 7:20 |
| Cake cutting | Dinner + 30 min | 7:50 |
| Parent dance 1 | Cake cutting + 10 min | 8:00 |
| Parent dance 2 | Parent dance 1 + 5 min | 8:05 |
| Open dance floor | Parent dance 2 + 5 min | 8:10 |
| Dessert served | Open dance floor + 15 min | 8:25 |
| Bouquet toss | Open dance floor + 30 min | 8:40 |
| 2nd look | Open dance floor + 45 min | 8:55 |
| Late-night snack | E − 60 min | — |
| Photo/video depart | Arrival + hours booked | — |
| Sunset photos | Sunset − 30 min (separate couple track) | — |
| Reception end | E (fixed) | — |
| After party | Start and end fixed | — |

### When items are skipped or moved
- Skipped item: next item moves into its slot; everything after shifts earlier.
- No grand entrance: couple seated at R + 20 min; chain continues.
- Toasts during dinner: peer toasts move to salad + 15 min, 5 min each; dinner
  stays at salad + 30 min.
- First dance after dinner: right before parent dance 1.
- Sunset photos on a must-attend moment (introductions→salad, cake, parent
  dances): move to nearest open gap (usually cocktail hour or after dinner served).

### Warnings to show
- HMU starts before 7 AM → suggest adding an artist.
- No first look with 60-min cocktail hour → ~5 min with guests; suggest 90.
- No first look with 20+ family photo groupings → 45 min is tight.
- Photographer coverage ends before cake cutting or parent dances.
- Sunset falls before ceremony end → sunset photos not possible.

### Rest of the weekend
| Item | Default |
|---|---|
| Rehearsal | Day before, 4 PM |
| Rentals and tent | Delivered day before / morning of; picked up next morning |
| Brunch | Day after, 10 AM |

## Appendix D — Supabase schema (draft)

```sql
create table if not exists wedding_timelines (
  user_id            text primary key,
  questionnaire      jsonb not null default '{}'::jsonb,
  overrides          jsonb not null default '[]'::jsonb,
  first_look_choice  text,              -- 'yes' | 'no' | 'both'
  updated_at         timestamptz not null default now()
);
-- RLS to match the app's existing anon-key pattern (see other DailyIDo tables).
```
