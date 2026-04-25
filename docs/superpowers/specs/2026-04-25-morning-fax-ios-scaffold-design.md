# Morning Fax iOS Scaffold Design

**Date:** 2026-04-25
**Status:** Pending review
**Source PRD:** `morning-fax-prd.md`
**Foundation spec:** `docs/superpowers/specs/2026-04-24-morning-fax-technical-foundation-design.md`
**Stitch project:** `projects/3459311465286439458` (Morning Fax App)

## Summary

This spec covers a SwiftUI iOS-18+ core visual scaffold for the v1 app. It includes the full navigation graph, finished treatments for the primary Stitch-designed surfaces, and placeholders for screens whose final Stitch designs have not landed yet. The scaffold sits inside the module shape defined by the technical foundation spec and uses mock data exclusively. Codex picks up the scaffold and replaces clearly marked seams (`MockFactStore`, `MockAuthService`, etc.) with real Supabase, RevenueCat, and notification implementations.

The scaffold's job is to prove the design language and the navigation graph end to end. It does not prove correctness of any service. There is no backend, no persistence, no entitlement enforcement, and no notification scheduling in this deliverable. The foundation spec governs what those layers must look like when Codex builds them.

## Relationship To The Foundation Spec

The foundation spec (`2026-04-24-morning-fax-technical-foundation-design.md`) defines the vertical slice: real auth, real Supabase, real RevenueCat, real notifications. This scaffold spec defines the visual surface of that slice using mock services that conform to the same protocols. The two specs co-exist by design.

When this scaffold lands and Codex begins implementation, the foundation spec governs all behavior. This spec governs only the design language, the screen inventory, the navigation graph, and the mock seams.

## Locked Decisions

- Platform: iOS only.
- App framework: native SwiftUI.
- Deployment target: iOS 18+. This supersedes the foundation spec's "17+ baseline, revisit" guidance based on the brainstorming conversation that produced this spec. Rationale below in iOS Deployment Target.
- Scope: UI-only scaffold with mock data and working navigation.
- Visual fidelity: spec-faithful, not pixel-faithful. The Brand Guideline drives the look; idiomatic SwiftUI fills the rest.
- Architecture: pragmatic SwiftUI with `@Observable` view models only where state is non-trivial.
- Project tooling: XcodeGen. The `.xcodeproj` is a build artifact, not a source file.
- Fonts: Newsreader (serif) and Inter (sans), bundled as `.ttf` resources and registered via `Info.plist`.
- Module layout: aligned with the foundation spec's `App/` + `Core/` + `Features/` structure.
- Onboarding flow: Sign in is pre-onboarding. The onboarding setup flow contains six screens: Welcome, Morning Time, Evening Edition, Categories, Premium Offer, and Notification Permission.
- Persistence: none in v0. `AppState` resets on relaunch. Codex chooses the persistence layer per the foundation spec.

## iOS Deployment Target

iOS 18+ is the right baseline for this app in 2026. The decision is driven by visual capability, not market-share math.

- `MeshGradient` enables the organic sage-tone backdrops the Editorial Calm aesthetic asks for. Without it the same effect requires either bitmap assets or stacked `LinearGradient` hacks, and neither animates well.
- The new SwiftUI `Tab` API and floating tab bar are forward-compatible with later screens (Today, Archive, Settings) if a tab structure is adopted.
- The new scroll position APIs (`onScrollGeometryChange`, `scrollPosition(id:)` with anchor) make the swipeable Daily Fact stack natural rather than fragile.
- `@Animatable` and improved keyframe `withAnimation` reduce the cost of any future "transmission received" card animation.
- `Color.mix(with:by:)` lets the design system express tonal layering rules without hand-tuning hex values.
- Install base: by April 2026 iOS 18 has been generally available for roughly 18 months. iOS 19 is approaching. Targeting 17 is conservative-by-default; 18 is current.

The known cost is that Codex's training data is thinner on iOS 18 APIs. Every iOS-18-specific call site receives an inline comment naming the API and what it replaces, so a human reviewer (or Codex itself) can spot it during integration work.

## Architecture

The scaffold uses pragmatic SwiftUI:

- A single `@Observable` `AppState` injected at the root via `.environment(_:)` carries all cross-screen state.
- Per-screen `@Observable` view models exist only where a screen has non-trivial state. Today, Onboarding, Settings, and CategoryFilter have view models. Splash, SignIn placeholder, Welcome placeholder, and similar screens do not.
- All services from the foundation spec exist as protocols in `Core/`. Each protocol has a `Mock` implementation that the scaffold uses. Codex replaces the mocks with real implementations.
- All design tokens live in `Core/DesignSystem/`. No hex values, font sizes, or spacing constants appear inside feature views.

This is the lowest-ceremony architecture that still aligns with the foundation spec and gives Codex a clean handoff surface.

## Module Layout

```text
MorningFax/
  project.yml
  README.md
  App/
    MorningFaxApp.swift
    AppRouter.swift
    AppState.swift
    Info.plist
  Core/
    Auth/
      AuthService.swift
      MockAuthService.swift
    Entitlements/
      EntitlementService.swift
      MockEntitlementService.swift
    Supabase/
      SupabaseClientProvider.swift
    Notifications/
      NotificationService.swift
      MockNotificationService.swift
    Persistence/
      PersistenceService.swift
    DesignSystem/
      Theme.swift
      Typography.swift
      Spacing.swift
      Radius.swift
      Components/
        PrimaryButton.swift
        SecondaryButton.swift
        GhostBorder.swift
        SunkenShadow.swift
        FrostedSurface.swift
        FactCard.swift
        CategoryChip.swift
    Sharing/
      ShareImageService.swift
  Features/
    SignIn/
      SignInView.swift
    Onboarding/
      OnboardingFlow.swift
      WelcomeView.swift
      MorningTimeView.swift
      EveningEditionView.swift
      CategoriesView.swift
      CategoriesViewModel.swift
      PremiumOfferView.swift
      NotificationPermissionView.swift
    Today/
      TodayView.swift
      TodayViewModel.swift
    Archive/
      ArchiveView.swift
    Paywall/
      PaywallView.swift
    CategoryFilter/
      CategoryFilterView.swift
      CategoryFilterViewModel.swift
    Settings/
      SettingsView.swift
      SettingsViewModel.swift
  Domain/
    Fact.swift
    Category.swift
    Mood.swift
    Obscurity.swift
    Tier.swift
    Edition.swift
  Mock/
    MockFactStore.swift
    MockCategories.swift
  Resources/
    Fonts/
      Newsreader-Regular.ttf
      Newsreader-Italic.ttf
      Newsreader-SemiBold.ttf
      Inter-Regular.ttf
      Inter-Medium.ttf
      Inter-SemiBold.ttf
```

## Design System

The Brand Guideline becomes Swift in `Core/DesignSystem/`. Every color, font, spacing value, radius, and shadow used in the app comes from this module.

### Colors

Token names use an `mf` prefix to avoid colliding with system colors. Hex values are taken directly from the Stitch project's `namedColors` payload.

| Token | Hex | Role |
| --- | --- | --- |
| `mfSurface` | `#F9F9F7` | base paper layer |
| `mfSurfaceContainerLow` | `#F2F4F2` | secondary sections |
| `mfSurfaceContainerHigh` | `#E5E9E6` | small high-contrast UI |
| `mfSurfaceContainerHighest` | `#DEE4E0` | chips and badges |
| `mfPrimary` | `#536257` | sage; brand and primary actions |
| `mfPrimaryDim` | `#47564C` | gradient companion to `mfPrimary` |
| `mfPrimaryContainer` | `#D6E7D9` | highlight background behind serif text |
| `mfOnSurface` | `#2D3432` | text and shadow tint; never `Color.black` |
| `mfOutlineVariant` | `#ADB3B0` | base for the ghost border at 15% opacity |

Full palette mirrors the Stitch theme.

### Typography

Newsreader and Inter, exposed through a `MFFont` enum and a `View.font(.mf(_:))` modifier.

| Token | Font | Size | Line height | Use |
| --- | --- | --- | --- | --- |
| `.displayLG` | Newsreader Italic | 56 | 1.05 | hero numbers, daily-fact display moments |
| `.headlineMD` | Newsreader Regular | 28 | 1.2 | section headers |
| `.body` | Newsreader Regular | 17 | 1.6 | fact body |
| `.uiLabel` | Inter Medium | 13 | 1.4 | buttons, metadata |
| `.overline` | Inter SemiBold all-caps `+0.05` tracking | 12 | 1.4 | category labels |

### Spacing

`MFSpacing` exposes `xs: 4`, `sm: 8`, `md: 16`, `lg: 24`, `xl: 32`, `xxl: 48`. No magic numbers in feature code.

### Radius

`MFRadius` exposes `sm: 8`, `md: 12`, `lg: 16`, `xl: 24`, `full: 9999`. Cards use `lg`/`xl`. Buttons use `xl`/`full`.

### Brand-rule modifiers

Three modifiers encode the Brand Guideline's hard rules so feature code cannot drift:

- `.ghostBorder()`: 1pt stroke of `mfOutlineVariant` at 15% opacity. The only approved way to draw a border.
- `.sunkenShadow()`: tinted with `mfOnSurface` at 6%, radius 40, y-offset 20. Replaces all system shadows.
- `.frostedSurface()`: `mfSurface` at 80% opacity over `Material.regular`. Used by floating headers and the share-sheet bridge.

### Components

`PrimaryButton`, `SecondaryButton`, `CategoryChip`, and `FactCard` are the base set. Each is built from the tokens above. `FactCard` is the visual centerpiece: `mfSurfaceContainerLow` fill on a surface background, `xl` corner radius, no border, optional `MeshGradient` accent reserved for hero moments.

## Screens

### SplashView

Brand moment lasting roughly 1.2 seconds. Centered fax-mark plus a spark glyph (SF Symbol stand-in until brand assets land), Newsreader Italic wordmark "Morning Fax", subtle `MeshGradient` sage backdrop. No state. Fades into whichever route `AppRouter` resolves.

### SignInView (placeholder)

Apple sign-in screen as defined by the foundation spec. The scaffold ships a placeholder with correct typography, a single primary button labelled "Continue", and a top-of-file `INTEGRATION(codex)` marker for the real Sign in with Apple wiring. Tapping the button calls `AuthService.signIn()` on the mock, which sets `isSignedIn = true` so navigation continues.

### OnboardingFlow

A `NavigationStack` coordinator that pushes the six onboarding setup screens in order. The flow does not pop on completion; instead it flips `appState.hasOnboarded`, which causes `AppRouter` to re-evaluate and swap the root to `TodayView`.

### WelcomeView (placeholder)

Quiet introduction to the product. Placeholder treatment: correct typography, single body line, primary button "Continue".

### MorningTimeView

Picks the morning delivery time. Visual language taken from the Stitch "Onboarding: Notifications" screen: Newsreader headline, body copy from the PRD ("Your Morning Fax is curated overnight…"), a `DatePicker` styled with `mfSurfaceContainerLow` background and a bottom-only ghost border. Footer primary button "Continue".

### EveningEditionView

Single `Toggle` for the optional evening edition (off by default). Same visual language as `MorningTimeView`. If toggled on, an inline `DatePicker` appears below for the evening time. Footer primary button "Continue".

### CategoriesView

The Stitch "Onboarding: Categories" design, rendered faithfully. Newsreader headline "Pick your palette", overline "STEP 4 OF 6", a vertical list of `CategoryChip` rows for the six PRD launch categories, with "Everything" rendered first and visually distinct. Footer primary button "Continue", disabled until at least one selection. `CategoriesViewModel` holds `Set<UUID>` and `everythingSelected: Bool`, mutually exclusive with individual picks.

### PremiumOfferView (placeholder)

Soft offer for premium per the foundation spec. Placeholder treatment with two buttons: "Try Premium" (no-op in scaffold, advances flow) and "Continue Free" (advances flow). `INTEGRATION(codex)` marker for RevenueCat offerings.

### NotificationPermissionView (placeholder)

Asks for notification permission after delivery preferences are set. Placeholder treatment, single primary button "Allow notifications" that invokes `NotificationService.requestAuthorization()` on the mock and advances the flow regardless of result.

### TodayView

The Stitch "Daily Fact Home" design, rendered as a vertically-paged `ScrollView` with `scrollTargetBehavior(.paging)` and a scroll-position binding. Each page is a `FactCard` containing an overline category label, italic Newsreader fact body, and a bottom action row (save, share, flag). A frosted-glass top bar carries the date and a gear button to Settings. The bottom edge shows a subtle "Morning Progress" tracker per the Brand Guideline.

`TodayViewModel` holds the array of `Fact` returned by `factStore.todayFacts(for: tier, in: selectedCategoryIDs)`, the current index, and `savedFactIDs`. The mock returns one fact for `.free` and three for `.premium`. The signature is `async throws` so the seam matches the foundation spec; the mock simply returns its static array.

### ArchiveView (placeholder)

Lists past cards (last 7 days for free, full for premium). Placeholder treatment: correct typography, single line "Design TBD — placeholder for Codex", a fake list of three rows so the navigation graph is exercised.

### PaywallView (placeholder)

Premium offer reachable from natural upgrade moments per `freemium-rules.md`. Same placeholder treatment as the others.

### CategoryFilterView

The Stitch "Category Filter" design. Sheet, full height. Header "Your palette", search field with a bottom-only ghost border, grouped list by descriptor (`CULTURE`, `HUMANITY`, `INNOVATION`, etc.) with inline `CategoryChip` toggles. Footer primary button "Apply". Edits a local working copy of `Set<UUID>` and only commits to `AppState` on Apply. Swipe-down or "Cancel" discards.

### SettingsView

The Stitch "Settings" design. Sectioned list rendered with the no-line rule: sections separated by `xl` whitespace and `mfSurfaceContainerLow` background blocks instead of dividers. Sections:

- Ritual: morning time `DatePicker`, evening edition `Toggle`.
- Palette: row that pushes to `CategoryFilterView`.
- Account: restore purchases, sign out, delete account (placeholders for Codex).
- About: version, Privacy, Terms (static rows).

The "Writing Style" picker is intentionally omitted per PRD section 8.

## AppState And Domain

### AppState

```swift
@MainActor
@Observable
final class AppState {
    let auth: any AuthService
    let entitlements: any EntitlementService
    let notifications: any NotificationService
    let factStore: any FactStore

    var isSignedIn: Bool = false
    var hasOnboarded: Bool = false

    var morningTime: Date = .now
    var eveningEnabled: Bool = false
    var eveningTime: Date = .now

    var selectedCategoryIDs: Set<UUID> = []
    var everythingSelected: Bool = true

    var savedFactIDs: Set<UUID> = []
    var seenFactIDs: Set<UUID> = []

    var tier: Tier = .free

    init(
        auth: any AuthService,
        entitlements: any EntitlementService,
        notifications: any NotificationService,
        factStore: any FactStore
    ) {
        self.auth = auth
        self.entitlements = entitlements
        self.notifications = notifications
        self.factStore = factStore
    }
}
```

`AppState` does not persist. Relaunch resets everything. The top of the file carries an `INTEGRATION(codex)` marker calling out persistence as a Codex responsibility per the foundation spec.

### Domain types

- `Fact`: `id: UUID`, `body: String` (free length), `premiumBody: String?` (extended), `category: Category`, `mood: Mood`, `obscurity: Obscurity`, `sourceURL: URL?`.
- `Category`: `id: UUID`, `descriptor: String`, `name: String`.
- `Mood`: `.spark | .settle | .both`.
- `Obscurity`: `.common | .moderate | .deepCut`.
- `Tier`: `.free | .trial | .premium | .expired` (matches the foundation spec).
- `Edition`: `.morning | .evening`.

### Mock data

`MockCategories` ships the six PRD launch categories: `CULTURE — Architecture`, `HUMANITY — History`, `INNOVATION — Science`, `THE MIND — Philosophy & Thought`, `FUTURE — Space`, `OUTDOORS — Ecology`.

`MockFactStore` ships exactly twelve hand-written facts (two per category) in Morning Fax voice. Each has both a free body (two to three sentences) and a premium body (four to six sentences) so the scaffold demonstrates both rendering paths. Selection is deterministic, not random, so previews and screenshots are reproducible.

## Navigation Flow

`AppRouter` owns the root decision:

```text
if !auth.isSignedIn         -> SignInView
else if !hasOnboarded       -> OnboardingFlow
else                        -> TodayView
```

A 1.2 second `SplashView` overlay covers the root on first appear, then fades.

`OnboardingFlow` pushes the six setup screens in order:

```text
Welcome -> MorningTime -> EveningEdition -> Categories -> PremiumOffer -> NotificationPermission
```

`SignIn` is rendered by `AppRouter`, not by `OnboardingFlow`. Once `isSignedIn` flips, the router swaps to `OnboardingFlow` starting at `Welcome`. When Notification Permission completes, `appState.hasOnboarded` flips and `AppRouter` swaps the root to `TodayView`.

From `TodayView`:

| Trigger | Destination | Style |
| --- | --- | --- |
| Tap gear in top bar | `SettingsView` | sheet |
| Tap filter affordance | `CategoryFilterView` | sheet |
| Swipe vertically | next/prev fact in stack | scroll-paging |
| Tap share | system share sheet | sheet (UIKit-bridged) |
| Tap a paywall trigger (source on free, archive limit, etc.) | `PaywallView` | sheet |

From `SettingsView`:

| Trigger | Destination | Style |
| --- | --- | --- |
| Tap "Palette" | `CategoryFilterView` | push within the Settings sheet's own `NavigationStack` |
| Tap account rows | placeholders | no-op for scaffold |

`CategoryFilterView` always uses an apply-or-discard semantic. Edits live in a local `Set<UUID>` and only write to `AppState` on Apply.

Deep linking and notification routing are explicitly out of scope for the scaffold. `AppRouter` carries an `INTEGRATION(codex)` marker for `onOpenURL` and `UNNotificationContent` handlers.

## Codex Handoff Surface

### README.md

Ships at the repo root and contains:

- One-paragraph statement of what the scaffold is and what it is not.
- Setup instructions: `brew install xcodegen`, `xcodegen generate`, `open MorningFax.xcodeproj`, run on any iPhone simulator on iOS 18+.
- One-paragraph architecture summary.
- A Codex Integration Map table that lists every mock-to-real seam with the contract Codex must honor.
- The five hard design-system rules ("no 1px borders, no `Color.black`, no system shadows, all fonts via `.mf`, all spacing via `MFSpacing`").
- A "where Codex extends" section listing folders to create (`Domain/Repositories/`, `App/Persistence/`, `Tests/`).

### Integration markers in code

Every seam Codex needs to touch carries a uniform comment:

```swift
// MARK: - INTEGRATION(codex): Replace MockFactStore with FactRepository
//   contract: func todayFacts(for tier: Tier, in: Set<UUID>) async throws -> [Fact]
//   constraints: production dedupe comes from Supabase user_served_facts; sourceURL only when tier == .premium
```

Grep target: `INTEGRATION(codex)`. The README references this. A single search produces the entire handoff surface.

### Things the README does not pre-decide

- Supabase schema details. The schema is defined in `docs/architecture/supabase-schema.md`. Codex implements against that, not against the scaffold's mock shape.
- Notification scheduling strategy. Codex picks.
- RevenueCat offering structure. Codex picks.
- Persistence layer (UserDefaults vs SwiftData vs server-backed). Codex picks per the foundation spec.

## Error Handling

The scaffold has effectively no error handling. Mock data does not fail. Every seam that will need real error handling once Codex integrates carries a `// TODO(codex): handle network and decoding failures` marker so the gaps cannot be forgotten.

## Testing

No tests in v0. UI-only scaffolds with static mocks are not worth testing. The `Tests/` directory is created when Codex begins wiring real services. The README states this explicitly so it is not interpreted as an oversight.

## Out Of Scope For The Scaffold

- Real Sign in with Apple. Mock only.
- Real Supabase fetches. Mock only.
- Real RevenueCat integration. Mock only.
- Real `UNUserNotificationCenter` scheduling. Mock only.
- Persistence of any kind.
- Share image rendering (the share button shows a system text share with a placeholder string).
- Deep linking and notification deep links.
- Analytics.
- Final visual designs for `SignInView`, `WelcomeView`, `PremiumOfferView`, `NotificationPermissionView`, `ArchiveView`, `PaywallView`. These ship as placeholders pending Stitch designs.
- Tests.
