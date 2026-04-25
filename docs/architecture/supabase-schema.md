# Supabase Schema

## Goal

The v1 schema should support account-based delivery, category preferences, freemium access, repeat prevention, saving, and feedback. It should not attempt to solve the full content generation pipeline yet.

## Tables

### profiles

One row per authenticated user.

Fields:

- `id uuid primary key references auth.users(id)`
- `created_at timestamptz not null default now()`
- `display_name text`
- `onboarding_completed_at timestamptz`
- `deleted_at timestamptz`

### user_preferences

Stores durable app preferences.

Fields:

- `user_id uuid primary key references profiles(id)`
- `category_mode text not null check (category_mode in ('everything', 'selected'))`
- `created_at timestamptz not null default now()`
- `updated_at timestamptz not null default now()`

### user_notification_settings

Stores delivery preferences.

Fields:

- `user_id uuid primary key references profiles(id)`
- `morning_enabled boolean not null default true`
- `morning_time time not null`
- `evening_enabled boolean not null default false`
- `evening_time time`
- `timezone text not null`
- `updated_at timestamptz not null default now()`

### categories

Curated taxonomy exposed in onboarding and settings.

Fields:

- `id uuid primary key default gen_random_uuid()`
- `descriptor text not null`
- `name text not null`
- `is_v1_onboarding boolean not null default false`
- `is_premium_only boolean not null default false`
- `sort_order int not null`

### user_selected_categories

Join table for selected category mode.

Fields:

- `user_id uuid references profiles(id)`
- `category_id uuid references categories(id)`
- `created_at timestamptz not null default now()`
- primary key: `(user_id, category_id)`

### user_category_blacklist

Premium-only future-ready blacklist for Everything mode.

Fields:

- `user_id uuid references profiles(id)`
- `category_id uuid references categories(id)`
- `created_at timestamptz not null default now()`
- primary key: `(user_id, category_id)`

### facts

Verified fact card content.

Fields:

- `id uuid primary key default gen_random_uuid()`
- `primary_category_id uuid references categories(id)`
- `body text not null`
- `premium_body text`
- `mood text not null check (mood in ('spark', 'settle', 'both'))`
- `obscurity text not null check (obscurity in ('common', 'moderate', 'deep_cut'))`
- `status text not null check (status in ('draft', 'verified', 'retired'))`
- `created_at timestamptz not null default now()`

### fact_sources

Source metadata for verification and premium attribution.

Fields:

- `id uuid primary key default gen_random_uuid()`
- `fact_id uuid not null references facts(id)`
- `title text not null`
- `url text not null`
- `publisher text`
- `accessed_at date`

### user_served_facts

Repeat-prevention ledger.

Fields:

- `user_id uuid references profiles(id)`
- `fact_id uuid references facts(id)`
- `edition text not null check (edition in ('morning', 'evening'))`
- `served_at timestamptz not null default now()`
- primary key: `(user_id, fact_id)`

### saved_facts

Personal saved archive.

Fields:

- `user_id uuid references profiles(id)`
- `fact_id uuid references facts(id)`
- `saved_at timestamptz not null default now()`
- primary key: `(user_id, fact_id)`

### fact_feedback

Content feedback loop.

Fields:

- `id uuid primary key default gen_random_uuid()`
- `user_id uuid references profiles(id)`
- `fact_id uuid references facts(id)`
- `feedback_type text not null check (feedback_type in ('seems_wrong', 'already_knew', 'loved_this'))`
- `created_at timestamptz not null default now()`

### user_entitlements

RevenueCat-backed entitlement snapshot.

Fields:

- `user_id uuid primary key references profiles(id)`
- `tier text not null check (tier in ('free', 'trial', 'premium', 'expired'))`
- `revenuecat_app_user_id text`
- `active_entitlement text`
- `current_period_ends_at timestamptz`
- `updated_at timestamptz not null default now()`

## RLS Requirements

Enable RLS on every table in the exposed schema. Users may read and update their own profile, preferences, notification settings, selected categories, saved facts, feedback, and entitlement snapshot only through approved paths.

Users may read verified facts and onboarding categories. Premium-only fields and full archive access should be exposed through controlled queries or Edge Functions that enforce entitlement rules.

Do not use user-editable metadata for authorization.
