# Morning Fax Technical Foundation Design

**Date:** 2026-04-24
**Status:** Approved for implementation planning
**Source PRD:** `morning-fax-prd.md`

## Summary

Morning Fax v1 will be a native SwiftUI iOS app backed by Supabase and RevenueCat. The first milestone is a technical foundation vertical slice: Sign in with Apple, onboarding, freemium entitlement awareness, category preferences, notification settings, and a live card rendered in the app's editorial design language.

The product should feel like a calm daily ritual, not a content feed. The technical foundation must protect that shape: account-based delivery, restrained notifications, verified facts, shareable card imagery, and premium access rules that are clear without making the free tier feel hostile.

## Locked Decisions

- Platform: iOS only for v1.
- App framework: native SwiftUI.
- Auth: account required before onboarding.
- V1 sign-in provider: Sign in with Apple only.
- Future auth: email login may be added later.
- Backend: Supabase Auth, Postgres, Row Level Security, and Edge Functions.
- Subscriptions: RevenueCat to begin with.
- Business model: freemium.
- Premium offer: shown during onboarding and available throughout the app.
- Category onboarding: users can choose Everything or selected categories.
- Evening edition: available to free users, off by default.
- Free archive: last 7 days.

## Architecture

The app uses SwiftUI feature modules layered on top of small core services. Views should not talk directly to SDKs. Instead, they use app-level services such as `AuthService`, `EntitlementService`, `FactService`, `PreferencesService`, `NotificationService`, and `ShareImageService`.

Supabase owns user identity and product data. RevenueCat owns subscription state and App Store subscription complexity. Supabase stores an entitlement snapshot for backend access decisions and app rendering. SwiftData is used for local cache, saved UI state, and resilient display when a request is slow or unavailable.

Initial implementation should optimize for a working vertical slice rather than a complete content engine. The app can fetch seeded facts from Supabase while the later generation and verification pipeline is designed separately.

## User Flow

```text
Launch
  -> Sign in with Apple
  -> Create or load Supabase user
  -> Welcome and positioning
  -> Morning notification time
  -> Optional evening edition
  -> Category choice: Everything or selected categories
  -> Premium offer
  -> Notification permission
  -> First live card
```

Sign-in happens before onboarding so every preference, served fact, saved fact, feedback event, and entitlement maps to a durable Supabase user ID from the start.

## Freemium Rules

Free users get one morning fact, optional one evening fact, a 7-day archive, card sharing, and basic category selection. Premium users get up to three facts per delivery, longer cards, visible sources, full archive, expanded categories, and category blacklist controls.

The app should never hide its core identity behind a paywall. Premium should feel like depth, not ransom.

## Backend Model

The first schema should include these areas:

- `profiles`: one row per authenticated user.
- `user_preferences`: onboarding completion, category mode, and product preferences.
- `user_notification_settings`: morning and evening delivery configuration.
- `categories`: curated v1 category taxonomy.
- `facts`: verified fact cards available for delivery.
- `fact_sources`: source metadata for premium attribution and verification.
- `user_served_facts`: repeat-prevention ledger.
- `saved_facts`: user archive saves.
- `fact_feedback`: "seems wrong", "already knew this", and "loved this" feedback.
- `user_entitlements`: current entitlement snapshot synced from RevenueCat.

All exposed tables must use RLS. Authorization decisions must not depend on user-editable metadata. Premium checks should use server-controlled entitlement data, not client claims.

## iOS App Structure

```text
MorningFax/
  App/
  Core/
    Auth/
    Entitlements/
    Supabase/
    Notifications/
    Persistence/
    DesignSystem/
    Sharing/
  Features/
    SignIn/
    Onboarding/
    Today/
    Archive/
    Paywall/
    Settings/
```

The card component is the center of the design system. Typography, spacing, color, source presentation, save state, feedback affordances, and share rendering should be designed around the card before secondary screens become elaborate.

## Error Handling

Auth errors should return the user to a clear sign-in state. Entitlement fetch failures should keep the last known local entitlement briefly, then fall back to free behavior if the state cannot be verified. Fact fetch failures should show a quiet retry state, not an empty feed. Notification permission denial should not block the app; settings should offer a route to enable notifications later.

Any backend access failure caused by RLS should fail closed. Free users should not be able to access premium-only source details, full archives, or extra daily facts through direct client queries.

## Testing

The foundation should include unit tests for service boundaries and app logic, plus a small number of UI tests for the critical flow. The first implementation plan should test:

- Auth state routing.
- Onboarding completion and preference persistence.
- Entitlement mapping from RevenueCat state to app tier.
- Free vs premium archive limits.
- Morning and evening notification settings.
- Category mode behavior for Everything and selected categories.
- Card rendering with and without premium source attribution.

## Supporting Documents

- `docs/architecture/ios-app-architecture.md`
- `docs/architecture/auth-and-entitlements.md`
- `docs/architecture/supabase-schema.md`
- `docs/product/freemium-rules.md`
- `docs/product/onboarding-flow.md`

## Out Of Scope For This Foundation

- Full fact generation pipeline.
- Admin verification UI.
- Android.
- Web landing page.
- Social features.
- Multiple writing styles.
- Behavioral personalization.
- Audio narration.
- Offline mode.

These can be designed after the app spine is working.
