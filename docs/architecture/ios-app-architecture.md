# iOS App Architecture

## Goal

Morning Fax should be a native SwiftUI app that feels quiet, editorial, and reliable. The architecture should keep UI code expressive while isolating SDKs and network details in small services.

## Minimum Target

Use iOS 17+ as the current planning baseline. Revisit the target before project creation after checking which SwiftUI APIs we want from the SwiftUI Pro guidance and the installed Xcode version.

## Module Layout

```text
MorningFax/
  App/
    MorningFaxApp.swift
    AppRouter.swift
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

## Core Services

- `AuthService`: wraps Supabase Auth and Sign in with Apple. Keep the public interface provider-neutral so email auth can be added later.
- `EntitlementService`: reads RevenueCat customer info and maps it into app tiers: free, trial, premium, expired.
- `SupabaseClientProvider`: configures the Supabase Swift client and exposes typed repositories.
- `FactService`: fetches today's facts, archive facts, saved facts, and source details when allowed.
- `PreferencesService`: manages onboarding, category mode, and delivery preferences.
- `NotificationService`: requests permission and schedules or syncs delivery settings.
- `ShareImageService`: renders card imagery for the native iOS share sheet.
- `PersistenceService`: owns SwiftData cache models and local app state.

## Feature Boundaries

`SignIn` owns the Apple sign-in screen and auth callback UI.

`Onboarding` owns the first-run ritual setup: welcome, delivery times, evening toggle, category choice, premium offer, and notification prompt.

`Today` owns the main card-reading experience.

`Archive` owns recent history for free users and full history for premium users.

`Paywall` owns RevenueCat offerings, purchase, restore, and entitlement refresh.

`Settings` owns account deletion, restore purchases, notification preferences, category preferences, and legal links.

## Design System

The design system should start with the card. Build colors, typography, spacing, buttons, labels, and feedback controls around the card's editorial feel. Prefer semantic component names such as `FaxCardView`, `EditionLabel`, `SourceAttribution`, and `QuietIconButton`.

## Local Persistence

Use SwiftData for local cache and durable UI state. Do not use local state as an authorization source. The backend remains the source of truth for user identity, entitlements, served facts, and archive access.

## Testing Shape

Unit-test services with mocked clients. UI-test only critical journeys: sign-in routing, onboarding completion, paywall entry points, and today's card display.
