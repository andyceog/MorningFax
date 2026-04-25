# Auth And Entitlements

## Goal

Morning Fax requires accounts in v1. Authentication should be simple for launch while leaving room for email login later.

## Auth Model

V1 supports Sign in with Apple only. Supabase Auth owns the app session and user ID. The app must not build a custom account system around Apple identity.

Future email login should attach to the same app-level auth boundary. App code should depend on `AuthService`, not on Apple-specific types outside the Sign In feature.

## Account Timing

Sign-in happens before onboarding:

```text
Launch
  -> Sign in with Apple
  -> Supabase session
  -> Profile bootstrap
  -> Onboarding
```

This means onboarding preferences, notification settings, category choices, saved facts, feedback, and entitlement snapshots can all be tied to the Supabase user immediately.

## RevenueCat Model

RevenueCat manages subscriptions, trials, restore purchases, and App Store subscription state. The app maps RevenueCat customer info into a simple tier model:

```text
free
trial
premium
expired
```

Supabase stores a server-controlled entitlement snapshot in `user_entitlements`. Backend functions and RLS policies should use this snapshot for access decisions where possible.

## Entitlement Sync

The implementation should support two sync paths:

- App refresh: after purchase, restore, app launch, and foregrounding, the app refreshes RevenueCat state and updates the backend through a protected endpoint.
- Webhook refresh: RevenueCat webhooks update `user_entitlements` from server to server.

The app should be resilient if webhooks arrive late. A successful purchase should update the local app experience quickly, then reconcile with Supabase.

## App Store Requirements

The app must include in-app account deletion before App Store submission. Because the app has subscriptions, Settings must also include restore purchases and clear subscription management affordances.

The privacy policy must disclose account data, subscription handling, analytics if added, and whether any user data is used in AI systems. The v1 app should not send personal user data to LLM providers.

## Failure Behavior

If entitlement status cannot be verified, the app may temporarily show the last known local state, but backend access must fail closed. Premium-only source attribution, full archive access, and extra facts should not be granted based only on stale client state.
