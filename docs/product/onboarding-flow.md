# Onboarding Flow

## Goal

Onboarding should establish the ritual before asking the user to make too many choices. Because accounts are required, Sign in with Apple happens first.

## Flow

```text
Launch
  -> Sign in with Apple
  -> Welcome
  -> Morning time
  -> Evening edition
  -> Category choice
  -> Premium offer
  -> Notification permission
  -> First card
```

## Screens

### Sign In

Offer only Sign in with Apple for v1. The screen should be minimal and trustworthy.

### Welcome

Introduce the product as a daily ritual for curiosity. Keep copy quiet and short.

### Morning Time

Ask when the user wants the morning edition delivered. Morning notifications are enabled by default once permission is granted.

### Evening Edition

Offer the evening edition as optional and off by default. Free users can enable it.

### Category Choice

Offer two paths:

- Everything, recommended.
- Choose categories.

The v1 list should be curated and limited to avoid overwhelming the user.

### Premium Offer

Show the premium offer during onboarding. This should be a soft offer, not a hard wall. Users can continue as free.

### Notification Permission

Ask after the user has chosen delivery preferences so the permission request has context. If denied, the app should still work and Settings should allow the user to revisit notification setup.

### First Card

Show the first live card after onboarding completes. This confirms the app is not just setup screens.

## Saved State

Because sign-in happens first, onboarding state can be stored directly in Supabase. SwiftData can cache progress locally for resilience, but Supabase remains the durable source.
