# Morning Fax — Product Requirements Document

**Version:** 0.1 (Draft)
**Status:** Planning
**Owner:** Gonzo
**Last updated:** April 2026

---

## 1. Vision & Positioning

### One-line pitch (primary)
Morning Fax is a daily ritual for people who'd rather learn something than scroll something.

### One-line pitch (alternate, for anti-scroll marketing)
Two small hits of curiosity a day, instead of an endless feed.

### Positioning statement
Morning Fax is slow media for curious people. It takes content as seriously as a learning app, feels as beautiful as a literary magazine, and asks nothing of the user except thirty seconds, twice a day.

### What we believe
1. The first thing you touch in the morning shapes the rest of your day.
2. Curiosity is a muscle, and it atrophies when fed infinite feeds.
3. Restraint is a feature. Less content, chosen well, beats more content chosen by an algorithm.
4. Beautiful design signals respect for the reader's attention.

---

## 2. Target Audience

### Primary archetypes
1. **The recovering doomscroller.** Reaches for their phone first thing in the morning, knows Instagram and TikTok are bad for them, wants a healthier default. Will switch to Morning Fax because it occupies the same hand-reach moment with something they feel good about afterward.
2. **The lifelong learner.** Buys nonfiction books they never finish, listens to podcasts at 1.5x, loves the feeling of learning but doesn't have time for long-form. Morning Fax gives them a daily dose of "I learned something today" without the commitment.
3. **The trivia nerd.** Collects random facts, loves being the person at dinner who says "actually, did you know…". Morning Fax is ammunition and identity.

### Who this is NOT for
- People who want games, quizzes, or gamified learning.
- People who want social features, comments, or discussion.
- People looking for deep courses or structured education.

---

## 3. The Market Gap

Existing products in this space fall into three buckets, and all of them miss the gap Morning Fax fills.

**Trivia and fact apps** (Curiosity, Factbook, 1 Second Everyday-style). These treat facts like snack food. Bright colors, heavy gamification, streaks, push notifications all day. Content skews toward listicle quality. Optimized for engagement, not reflection.

**Learning platforms** (Brilliant, Duolingo-for-knowledge clones). Serious content but they require work. Lessons, problems, progress tracking. Morning Fax is explicitly not work.

**Newsletters and feeds** (Now I Know, TIL on Reddit, Big Think). Good content but they live inside email or a social feed. No ritual, no beautiful object, no sense of "this was made for me this morning."

**The gap:** A product that takes the content as seriously as Brilliant does, feels as beautiful as a literary magazine, and costs nothing but thirty seconds of attention. Nobody is building slow media for curious people in app form. Morning Fax is that product.

---

## 4. Core Experience

### The card is the product
Everything in Morning Fax revolves around the card. A card is a single, beautifully typeset fact delivered at a chosen time of day. Cards are designed to be read, shared, and occasionally revisited.

### Free card specification
- One fact per delivery, two to three sentences.
- Category label at the top of the card (e.g., "SPACE", "PHILOSOPHY").
- No clickbait headline. The fact is the headline.
- Share button and "next fact" navigation at the bottom of the card.
- Typography: serif for the fact body, small caps for the category label.
- Sourced and verified (source not shown in free tier).

### Premium card specification
- Up to three facts per delivery instead of one.
- Longer form: facts can be four to six sentences with additional context.
- Source attribution visible (tap to see where the fact came from).
- Access to full archive of past cards (free users get a limited recent history, exact length TBD).
- Thematic depth: premium cards may include related facts, images, or extended context.

### Card interaction model
- User opens the app (or taps the notification) and lands on today's card.
- Swipe or tap "Next Fact" to see additional cards (for premium users with multiple daily facts).
- Share button opens native iOS share sheet. Shared cards render as an image that preserves the Morning Fax aesthetic.
- Tap to save a card to a personal archive.
- Long-press or dedicated button to flag a fact as "feels wrong" or "loved this" (feedback loop for the content engine).

### Time per card
Target reading time is thirty seconds for free, up to two minutes for premium with multiple facts. Users can always return to the app to re-read.

### Morning vs Evening cards (thematic difference)
- **Morning Edition** (primary, default enabled): Energizing facts that spark curiosity. "Did you know" style. Leaves the reader wanting to learn more.
- **Evening Edition** (optional, toggleable): Reflective facts that invite wonder. Calmer tone. Leaves the reader with something to think about as they wind down.
- Same fact engine, different selection and tone tuning. Facts are tagged internally as "spark" or "settle" (or both) to support this.

### The share experience
When a user shares a card, the output is a rendered image of the card itself, not a text blurb. This is critical for the building-in-public strategy and for organic growth. Every shared card is a micro-ad for the aesthetic.

---

## 5. Content & Fact Engine

This is the hardest problem in the product. Fact quality is the product, so the engine must be reliable, scalable, and on-brand.

### Approach: Hybrid source-seeded generation with human verification
1. **Seed from trusted sources.** Pull raw factual content from public-domain and reputable sources (Wikipedia featured articles, curated science publications, verified trivia databases, Project Gutenberg, etc.).
2. **Rewrite in the Morning Fax voice.** Use an LLM to reformat the source material into the tight, editorial Morning Fax tone. The LLM is instructed to preserve every factual claim and not invent new ones.
3. **Human verification.** Every rewritten fact is checked by a human against the original source before it enters the active pool. Verification takes roughly thirty seconds per fact.
4. **Store with source attribution.** Every fact in the database has a source URL attached. This powers the premium "see source" feature and protects the brand against accuracy complaints.
5. **Reuse across users.** Facts are not regenerated per user. A verified fact enters a shared pool and is served to any user whose category preferences match.

### Why not pure LLM generation?
LLMs hallucinate confidently. For a product whose entire value proposition is "this is a true and interesting thing," even a two percent hallucination rate is brand-ending. Users will catch it, screenshot it, and trust is broken.

### Why not only human-written?
Math doesn't work. Hundreds of categories times hundreds of facts per category to avoid repeats equals thousands of facts for launch alone. Single-author production can't keep up.

### Why not only licensed databases?
Voice mismatch. Existing fact databases don't sound like Morning Fax. They need a voice layer, which is exactly what the LLM rewriting step provides.

### Repeat prevention
Track which facts each user has been served. Never serve the same fact twice within a rolling window (suggested: eighteen months). If a user exhausts all available facts in their categories, prompt them to expand their palette.

### Feedback loop
Every card has a subtle flag button. Users can mark facts as:
- "Seems wrong" (triggers re-verification by a human)
- "I already knew this" (deprioritizes similar facts for this user)
- "Loved this" (boosts similar facts for this user and globally)

The flags are not gamified or noisy. Just a small icon. Over time the aggregate data reveals which facts land, which ones are borderline, and which should be retired.

### Category tagging
Every fact is tagged with:
- Primary category (required)
- Secondary categories (optional, for cross-category surfacing)
- Mood tag: spark, settle, or both (for morning/evening tuning)
- Obscurity level (common knowledge, moderately known, deep cut) for future personalization

---

## 6. Categories & Personalization

### Taxonomy structure
Categories use a two-level naming convention: a descriptor word paired with the category name. For example:
- CULTURE — Architecture
- HUMANITY — History
- INNOVATION — Science
- THE MIND — Philosophy & Thought
- FUTURE — Space
- OUTDOORS — Ecology

This gives the taxonomy a point of view. It feels curated rather than dumped from a database.

### Target category count
Hundreds of categories will be generated (external agent). For v1, a curated subset of roughly twenty to thirty categories is exposed in onboarding to avoid overwhelm. The full taxonomy becomes accessible in settings under "Expand your palette."

### Onboarding flow
1. Splash and one-line pitch.
2. Ritual setup: pick morning notification time, optionally enable evening.
3. Category selection: pick "Everything" (recommended) or select individual categories.
4. Confirmation and first card delivery.

### Note on onboarding alignment
The current mockups show two different category selectors. The simple onboarding screen (step one) and the richer settings view use different taxonomies. For v1, the onboarding uses the simple version and settings reveals the deeper taxonomy. This creates a natural "expand your palette" upgrade moment.

### Personalization (v2 consideration)
Learning from user behavior (which cards they save, flag, or skip) is a v2 feature. V1 serves based on declared category preferences only. Keeps the v1 scope manageable.

### Blacklisting
Users can exclude specific categories even when "Everything" is selected. This is important for people who want broad curiosity but specifically don't want politics, religion, or other sensitive topics.

---

## 7. Notifications & Ritual

### Default cadence
- One morning notification at user-selected time.
- One optional evening notification, disabled by default, enabled via toggle.
- No mid-day notifications. No promotional notifications. No streak-break warnings.

### Notification tone
Silent by default. The copy is quiet and literary ("Your Morning Fax has arrived"). Never urgent, never clickbait, never "YOU HAVEN'T OPENED THIS IN THREE DAYS."

### Missed card behavior
If a user misses a notification, the card stays available in the app for that day. Past cards are accessible via the archive (limited for free, full for premium).

### Time zones and travel
Notifications respect the device's local time zone and automatically adjust when the user travels.

### No streaks
Morning Fax does not use streaks. Streaks create anxiety and turn the product into a chore. The ritual is the reward, not a metric.

---

## 8. Monetization

### Free tier
- One fact per day (morning).
- Optional evening edition (one fact).
- Limited recent history (exact length TBD, suggested: last seven days).
- Core share functionality.
- Basic category selection.

### Premium tier
- Up to three facts per delivery.
- Longer-form facts with more depth.
- Source attribution on every fact.
- Full archive access (all past cards).
- Full category palette (expand-your-palette in settings).
- Ability to blacklist specific categories.

### Pricing
- Monthly: $4.99/month with a 3-day free trial.
- Annual: $29.99/year with a 7-day free trial (effectively $2.50/month, a 50% discount).
- No lifetime option at launch (evaluate after six months of data).
- No ads, ever, in any tier.

### Trial design rationale
The monthly trial is shorter because the commitment is smaller and users can cancel anytime. The annual trial is longer because seven days is roughly how long it takes for the twice-daily ritual to feel like part of a user's routine, which increases the chance of conversion.

### Post-trial fallback behavior
When a trial ends without conversion, the user automatically falls back to the free tier. Premium access disappears, but the app remains installed and usable. This is intentional: a hostile "convert or lose everything" flow increases deletion rates. Keeping users on the free tier preserves them for future conversion attempts.

### Writing Style (deferred to v2)
The settings mockup includes a "Writing Style" dropdown (Editorial Minimalist, etc.). This is intentionally deferred to v2. V1 ships with one perfect Morning Fax voice to establish brand identity. Alternate voices become a premium expansion feature once the core voice is locked in.

---

## 9. Aesthetic & Voice

### Visual direction
- Palette: sage green, cream, warm off-white. Soft, paper-like backgrounds.
- Typography: serif for display and body, small caps for labels, italic reserved for emphasis and headline moments.
- Layout: generous whitespace, single-focus screens, minimal chrome.
- Iconography: thin-line, editorial style. Small fax machine motif as a brand signature.

### The fax metaphor
Lean into it hard. The aesthetic, the copy, the interactions should all reinforce the feeling that something has been deliberately prepared and delivered. Suggested touches:
- "Your Morning Fax has arrived" notification copy.
- "Slide it under your digital door" onboarding microcopy.
- Subtle paper texture on card backgrounds.
- Possible "transmission received" animation on card open (evaluate for delight vs. overhead).

### Voice and copywriting principles
- Quiet, literary, never shouty.
- Never uses exclamation points unless quoting something.
- Never uses emoji in product copy.
- Prefers "your" to "you" to "user."
- Occasionally playful, never silly.
- Writes like an editor, not a marketer.

Reference lines from the current mockups that capture the voice:
- "Your Morning Fax is curated overnight. When should we slide it under your digital door?"
- "Notifications are silent by default to preserve the morning's quietude."
- "Curiosity is the wick in the candle of learning."

---

## 10. Platform & Scope

### Platforms at launch
- iOS only.
- Minimum iOS version: TBD (suggested: iOS 17+).
- No Android at launch. Reevaluate after six months.

### Web presence
A minimal landing page at launch. One screen, logo, one-line pitch, sample card rendered in the app's visual style, and an email capture for launch notifications. No blog, no features page. Decision on whether to build this is still open but leaning yes.

### Explicitly out of scope for v1
- Social features (comments, likes, following, user profiles).
- User-submitted facts.
- AI chat or conversational features.
- Android.
- Multiple writing styles.
- Behavioral personalization (learning from user actions).
- Gamification (streaks, points, badges).
- Lifetime pricing.
- Audio narration of facts.
- Offline mode (nice-to-have but not v1).

Naming what is out of scope is as important as naming what is in scope. It protects against feature creep during development.

---

## 11. Success Metrics

### North star
Day 30 retention. If users are still opening the app thirty days after install, the ritual has taken hold and the product is working.

### Target metrics for first 90 days post-launch
- Day 7 retention: 40%+
- Day 30 retention: 20%+
- Notification tap-through rate: 25%+
- Free-to-premium conversion: 3-5%
- Average cards viewed per active day: 1.5+
- Share rate: 5%+ of active users share at least one card per week

These are initial targets and will be recalibrated based on actual data.

---

## 12. Technical Considerations (High-Level)

This section is intentionally light. Technical architecture will be decided once the product scope is locked.

### Known technical needs
- Mobile app (likely Expo/React Native based on prior experience, but TBD).
- Backend for fact storage, user preferences, and delivery scheduling (Supabase is a strong candidate given prior familiarity).
- Fact generation and verification pipeline (LLM + human review workflow).
- Push notification service.
- Share image generation (server-side rendering of cards as images).
- Analytics for retention, conversion, and content feedback.

### Known technical risks
- Fact engine reliability and scale.
- Push notification deliverability at the exact user-requested time.
- Share image rendering quality across platforms.
- LLM cost management if rewriting is done at scale.

---

## 13. Open Questions

These are decisions still to be made before development begins.

1. Exact number of free archive days (7? 14? 30?).
2. Minimum iOS version at launch.
3. Whether to build the launch landing page or skip it.
4. Specific launch category list (which of the hundreds to expose in onboarding).
5. Whether "transmission received" card animation is worth the build cost.
6. Exact content of evening vs morning tone guidelines for the fact generation pipeline.
7. Who handles human fact verification at launch (Gonzo personally, contractor, or hybrid).
8. Whether to include a founder's note or welcome card in first-time user experience.
9. Beta testing plan and recruitment strategy (leverage climbing community? general TestFlight?).

---

## 14. Risks & Mitigations

**Risk:** Fact engine produces inaccurate content. **Mitigation:** Human verification on every fact before it enters the pool. Source attribution for every fact. User flag system for fast retirement of bad facts.

**Risk:** Users find the content boring after a few weeks. **Mitigation:** Broad category taxonomy, feedback loop that surfaces higher-rated facts, expand-your-palette mechanic to pull users into new categories.

**Risk:** Low free-to-premium conversion. **Mitigation:** Ensure free tier is genuinely a taste, not a full meal. Premium value (three facts, longer form, sources, full archive) should feel clearly differentiated.

**Risk:** Aesthetic appeals to a narrow audience. **Mitigation:** Accept this. Morning Fax is not for everyone. The narrow, strong appeal is the strategy.

**Risk:** Scope creep during development. **Mitigation:** The "out of scope" section in this PRD. Revisit it whenever a new feature is proposed.

---

## 15. Changelog

- **v0.1 (April 2026):** Initial draft based on brainstorming session. Primary decisions locked: positioning, pricing, trial structure, fact engine approach, morning/evening thematic split, writing style deferred to v2, free tier fallback after trial.
