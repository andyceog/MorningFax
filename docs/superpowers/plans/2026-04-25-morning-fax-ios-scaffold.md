# Morning Fax iOS Scaffold Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a SwiftUI iOS-18+ core visual scaffold for the v1 Morning Fax app with mock data, working navigation, design-system tokens, finished treatments for the primary Stitch-designed surfaces, placeholders for unfinished screens, and clean integration seams for Codex to wire real services into.

**Architecture:** Pragmatic SwiftUI. One `@Observable` `AppState` injected at root carries cross-screen state. Per-screen `@Observable` view models only where state is non-trivial. All foundation-spec services exist as protocols with `Mock` implementations. Design tokens centralized in `Core/DesignSystem/`. Project tooling: XcodeGen.

**Tech Stack:** Swift 5.10+, SwiftUI, iOS 18+, XcodeGen, Newsreader + Inter fonts (bundled OFL).

**Source spec:** `docs/superpowers/specs/2026-04-25-morning-fax-ios-scaffold-design.md`
**Foundation spec:** `docs/superpowers/specs/2026-04-24-morning-fax-technical-foundation-design.md`

## Verification strategy (no XCTest)

Per the spec, the scaffold ships zero tests. Each task is verified by:

1. **Build success** — `xcodegen generate && xcodebuild -scheme MorningFax -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16' build` returns 0.
2. **Simulator boot** — launch the app on an iOS 18+ simulator and visually confirm the new screen renders.
3. **No SwiftLint / SwiftFormat in scaffold** — keep the surface lean. Codex picks linting at integration time.

`Tests/` is created when Codex begins wiring real services; the scaffold's README states this explicitly.

## Spec alignment note

The committed scaffold spec is the source of truth. `FactCard` uses `mfSurfaceContainerLow` for its fill, matching `docs/superpowers/specs/2026-04-25-morning-fax-ios-scaffold-design.md`. Do not add competing color tokens in this scaffold plan unless the scaffold spec is updated first.

---

## Task 1: Repo bootstrap (XcodeGen + project.yml + .gitignore)

**Files:**
- Create: `project.yml`
- Create: `.gitignore`
- Create: `App/MorningFaxApp.swift` (minimal placeholder so XcodeGen has a source file to find)

- [ ] **Step 1: Verify XcodeGen is installed**

Run: `which xcodegen || brew install xcodegen`
Expected: outputs a path or installs cleanly.

- [ ] **Step 2: Create `.gitignore`**

```gitignore
# Xcode
build/
DerivedData/
*.xcodeproj
*.xcworkspace

# Swift
.swiftpm/
.build/
Packages
xcuserdata/

# macOS
.DS_Store
```

- [ ] **Step 3: Create `project.yml`**

```yaml
name: MorningFax
options:
  bundleIdPrefix: com.morningfax
  createIntermediateGroups: true
  deploymentTarget:
    iOS: "18.0"
  groupOrdering:
    - order: [App, Core, Features, Domain, Mock, Resources]

settings:
  base:
    SWIFT_VERSION: "5.10"
    SWIFT_STRICT_CONCURRENCY: complete
    ENABLE_USER_SCRIPT_SANDBOXING: YES

targets:
  MorningFax:
    type: application
    platform: iOS
    sources:
      - path: App
      - path: Core
      - path: Features
      - path: Domain
      - path: Mock
    resources:
      - path: Resources
        optional: true
    info:
      path: App/Info.plist
      properties:
        CFBundleDisplayName: Morning Fax
        UILaunchScreen: {}
        UIApplicationSceneManifest:
          UIApplicationSupportsMultipleScenes: false
        UIAppFonts:
          - Newsreader-Regular.ttf
          - Newsreader-Italic.ttf
          - Newsreader-SemiBold.ttf
          - Inter-Regular.ttf
          - Inter-Medium.ttf
          - Inter-SemiBold.ttf
        UISupportedInterfaceOrientations:
          - UIInterfaceOrientationPortrait
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.morningfax.app
        TARGETED_DEVICE_FAMILY: "1"
        CURRENT_PROJECT_VERSION: 1
        MARKETING_VERSION: "0.1"
        IPHONEOS_DEPLOYMENT_TARGET: "18.0"
```

- [ ] **Step 4: Create minimal `App/MorningFaxApp.swift`**

```swift
import SwiftUI

@main
struct MorningFaxApp: App {
    var body: some Scene {
        WindowGroup {
            Text("Morning Fax")
        }
    }
}
```

- [ ] **Step 5: Generate the Xcode project**

Run: `xcodegen generate`
Expected: `Created project at MorningFax.xcodeproj`

- [ ] **Step 6: Build the project**

Run: `xcodebuild -scheme MorningFax -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16' build -quiet`
Expected: exit code 0.

- [ ] **Step 7: Commit**

```bash
git add project.yml .gitignore App/MorningFaxApp.swift
git commit -m "chore: bootstrap XcodeGen project for iOS scaffold"
```

---

## Task 2: Bundle Newsreader and Inter fonts

**Files:**
- Create: `Resources/Fonts/Newsreader-Regular.ttf`
- Create: `Resources/Fonts/Newsreader-Italic.ttf`
- Create: `Resources/Fonts/Newsreader-SemiBold.ttf`
- Create: `Resources/Fonts/Inter-Regular.ttf`
- Create: `Resources/Fonts/Inter-Medium.ttf`
- Create: `Resources/Fonts/Inter-SemiBold.ttf`

- [ ] **Step 1: Download Newsreader (OFL)**

Source: https://fonts.google.com/specimen/Newsreader → Download family. Extract:
- `Newsreader-Regular.ttf` → `Resources/Fonts/Newsreader-Regular.ttf`
- `Newsreader-Italic.ttf` → `Resources/Fonts/Newsreader-Italic.ttf`
- `Newsreader-SemiBold.ttf` → `Resources/Fonts/Newsreader-SemiBold.ttf`

- [ ] **Step 2: Download Inter (OFL)**

Source: https://fonts.google.com/specimen/Inter → Download family. Extract:
- `Inter-Regular.ttf` → `Resources/Fonts/Inter-Regular.ttf`
- `Inter-Medium.ttf` → `Resources/Fonts/Inter-Medium.ttf`
- `Inter-SemiBold.ttf` → `Resources/Fonts/Inter-SemiBold.ttf`

- [ ] **Step 3: Regenerate the Xcode project**

Run: `xcodegen generate`
Expected: rebuilds `MorningFax.xcodeproj` with `Resources/Fonts/*.ttf` bundled.

- [ ] **Step 4: Verify fonts load — temporary canary in `MorningFaxApp.swift`**

Replace the `Text("Morning Fax")` body with:

```swift
VStack(spacing: 12) {
    Text("Newsreader Italic").font(.custom("Newsreader-Italic", size: 32))
    Text("Newsreader Regular").font(.custom("Newsreader-Regular", size: 24))
    Text("Inter Medium").font(.custom("Inter-Medium", size: 18))
}
```

- [ ] **Step 5: Build and visually verify in simulator**

Run: `xcodebuild ... build` then launch simulator. Confirm each line renders in the correct font (not falling back to system).
Expected: serif rendering for Newsreader lines; sans for Inter line. If any line falls back to SF, the `UIAppFonts` registration is wrong — re-check `project.yml` step 3 of Task 1 and the file names in `Resources/Fonts/`.

- [ ] **Step 6: Revert canary**

Restore `Text("Morning Fax")` in `MorningFaxApp.swift`.

- [ ] **Step 7: Commit**

```bash
git add Resources/Fonts/ App/MorningFaxApp.swift
git commit -m "chore: bundle Newsreader and Inter fonts"
```

---

## Task 3: Design system — color tokens (`Theme.swift`)

**Files:**
- Create: `Core/DesignSystem/Theme.swift`

- [ ] **Step 1: Create `Core/DesignSystem/Theme.swift`**

```swift
import SwiftUI

extension Color {
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red:   Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 8)  & 0xff) / 255,
            blue:  Double( hex        & 0xff) / 255,
            opacity: 1
        )
    }

    // Surfaces
    static let mfSurface                  = Color(hex: 0xF9F9F7)
    static let mfSurfaceContainerLow      = Color(hex: 0xF2F4F2)
    static let mfSurfaceContainer         = Color(hex: 0xEBEFEC)
    static let mfSurfaceContainerHigh     = Color(hex: 0xE5E9E6)
    static let mfSurfaceContainerHighest  = Color(hex: 0xDEE4E0)

    // Brand
    static let mfPrimary                  = Color(hex: 0x536257)
    static let mfPrimaryDim               = Color(hex: 0x47564C)
    static let mfPrimaryContainer         = Color(hex: 0xD6E7D9)
    static let mfPrimaryFixedDim          = Color(hex: 0xC8D9CB)

    // Text & on-colors
    static let mfOnSurface                = Color(hex: 0x2D3432)
    static let mfOnSurfaceVariant         = Color(hex: 0x5A605E)
    static let mfOnPrimary                = Color(hex: 0xEBFCEE)
    static let mfOnPrimaryContainer       = Color(hex: 0x46554B)

    // Outlines
    static let mfOutline                  = Color(hex: 0x767C79)
    static let mfOutlineVariant           = Color(hex: 0xADB3B0)

    // Tertiary (warm accent for occasional moments — sourced from Stitch theme)
    static let mfTertiary                 = Color(hex: 0x675E4C)
    static let mfTertiaryContainer        = Color(hex: 0xF4E6CF)
}
```

- [ ] **Step 2: Build to verify**

Run: `xcodebuild ... build -quiet`
Expected: exit 0.

- [ ] **Step 3: Commit**

```bash
git add Core/DesignSystem/Theme.swift
git commit -m "feat(design-system): add color tokens"
```

---

## Task 4: Design system — typography (`Typography.swift`)

**Files:**
- Create: `Core/DesignSystem/Typography.swift`

- [ ] **Step 1: Create `Core/DesignSystem/Typography.swift`**

```swift
import SwiftUI

enum MFFont {
    case displayLG     // hero numbers, daily-fact display
    case headlineMD    // section headers
    case body          // fact body
    case uiLabel       // buttons, metadata
    case overline      // category labels (all-caps, +0.05 tracking)
}

extension Font {
    static func mf(_ token: MFFont) -> Font {
        switch token {
        case .displayLG:  return .custom("Newsreader-Italic",   size: 56)
        case .headlineMD: return .custom("Newsreader-Regular",  size: 28)
        case .body:       return .custom("Newsreader-Regular",  size: 17)
        case .uiLabel:    return .custom("Inter-Medium",        size: 13)
        case .overline:   return .custom("Inter-SemiBold",      size: 12)
        }
    }
}

extension View {
    /// Applies an MFFont token plus the line-height and tracking it expects.
    /// Use instead of `.font(.mf(...))` when the spec calls for specific line height.
    func mfTextStyle(_ token: MFFont) -> some View {
        let (lineSpacing, tracking, transform): (CGFloat, CGFloat, Bool) = {
            switch token {
            case .displayLG:  return (3,  0,    false)
            case .headlineMD: return (5,  0,    false)
            case .body:       return (10, 0,    false)
            case .uiLabel:    return (3,  0,    false)
            case .overline:   return (3,  0.6,  true)   // overlines are uppercased + tracked
            }
        }()
        return self
            .font(.mf(token))
            .lineSpacing(lineSpacing)
            .tracking(tracking)
            .textCase(transform ? .uppercase : nil)
    }
}
```

- [ ] **Step 2: Build to verify**

Run: `xcodebuild ... build -quiet`
Expected: exit 0.

- [ ] **Step 3: Commit**

```bash
git add Core/DesignSystem/Typography.swift
git commit -m "feat(design-system): add typography tokens"
```

---

## Task 5: Design system — spacing and radius

**Files:**
- Create: `Core/DesignSystem/Spacing.swift`
- Create: `Core/DesignSystem/Radius.swift`

- [ ] **Step 1: Create `Core/DesignSystem/Spacing.swift`**

```swift
import CoreGraphics

enum MFSpacing {
    static let xs:  CGFloat = 4
    static let sm:  CGFloat = 8
    static let md:  CGFloat = 16
    static let lg:  CGFloat = 24
    static let xl:  CGFloat = 32
    static let xxl: CGFloat = 48
}
```

- [ ] **Step 2: Create `Core/DesignSystem/Radius.swift`**

```swift
import CoreGraphics

enum MFRadius {
    static let sm:   CGFloat = 8
    static let md:   CGFloat = 12
    static let lg:   CGFloat = 16
    static let xl:   CGFloat = 24
    static let full: CGFloat = 9999
}
```

- [ ] **Step 3: Build to verify**

Run: `xcodebuild ... build -quiet`
Expected: exit 0.

- [ ] **Step 4: Commit**

```bash
git add Core/DesignSystem/Spacing.swift Core/DesignSystem/Radius.swift
git commit -m "feat(design-system): add spacing and radius tokens"
```

---

## Task 6: Design system — brand-rule modifiers

**Files:**
- Create: `Core/DesignSystem/Components/GhostBorder.swift`
- Create: `Core/DesignSystem/Components/SunkenShadow.swift`
- Create: `Core/DesignSystem/Components/FrostedSurface.swift`

- [ ] **Step 1: Create `Core/DesignSystem/Components/GhostBorder.swift`**

```swift
import SwiftUI

extension View {
    /// 1pt stroke of `mfOutlineVariant` at 15% opacity. The only approved way
    /// to draw a border in the app per Brand Guideline §4 ("Ghost Border").
    func ghostBorder(cornerRadius: CGFloat = MFRadius.md) -> some View {
        overlay {
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.mfOutlineVariant.opacity(0.15), lineWidth: 1)
        }
    }

    /// Bottom-only ghost border for inputs that follow the "no-line" rule
    /// at every edge except the underline.
    func ghostBorderBottom() -> some View {
        overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.mfOutlineVariant.opacity(0.15))
                .frame(height: 1)
        }
    }
}
```

- [ ] **Step 2: Create `Core/DesignSystem/Components/SunkenShadow.swift`**

```swift
import SwiftUI

extension View {
    /// Shadow tinted with `mfOnSurface` (#2D3432) at 6% — replaces all
    /// system shadows per Brand Guideline §4.
    func sunkenShadow() -> some View {
        shadow(color: Color.mfOnSurface.opacity(0.06), radius: 40, x: 0, y: 20)
    }
}
```

- [ ] **Step 3: Create `Core/DesignSystem/Components/FrostedSurface.swift`**

```swift
import SwiftUI

extension View {
    /// Frosted-glass treatment for floating headers and tab bars per
    /// Brand Guideline §2 ("Glass & Gradient" rule). Renders `mfSurface`
    /// at 80% opacity over a regular blur material.
    func frostedSurface() -> some View {
        background {
            ZStack {
                Rectangle().fill(.regularMaterial)
                Color.mfSurface.opacity(0.8)
            }
            .ignoresSafeArea(edges: .top)
        }
    }
}
```

- [ ] **Step 4: Build to verify**

Run: `xcodebuild ... build -quiet`
Expected: exit 0.

- [ ] **Step 5: Commit**

```bash
git add Core/DesignSystem/Components/
git commit -m "feat(design-system): add ghostBorder, sunkenShadow, frostedSurface modifiers"
```

---

## Task 7: Design system — shared components

**Files:**
- Create: `Core/DesignSystem/Components/PrimaryButton.swift`
- Create: `Core/DesignSystem/Components/SecondaryButton.swift`
- Create: `Core/DesignSystem/Components/CategoryChip.swift`
- Create: `Core/DesignSystem/Components/FactCard.swift`

- [ ] **Step 1: Create `Core/DesignSystem/Components/PrimaryButton.swift`**

```swift
import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isEnabled: Bool = true

    @GestureState private var isPressed = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.mf(.uiLabel))
                .foregroundStyle(Color.mfOnPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, MFSpacing.md)
                .background {
                    RoundedRectangle(cornerRadius: MFRadius.xl)
                        .fill(
                            LinearGradient(
                                colors: [Color.mfPrimary, Color.mfPrimaryDim],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .scaleEffect(isPressed ? 0.98 : 1.0)
                .animation(.easeOut(duration: 0.12), value: isPressed)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.5)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .updating($isPressed) { _, state, _ in state = true }
        )
    }
}
```

- [ ] **Step 2: Create `Core/DesignSystem/Components/SecondaryButton.swift`**

```swift
import SwiftUI

struct SecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.mf(.uiLabel))
                .foregroundStyle(Color.mfPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, MFSpacing.md)
                .background {
                    RoundedRectangle(cornerRadius: MFRadius.xl)
                        .fill(Color.clear)
                }
                .ghostBorder(cornerRadius: MFRadius.xl)
        }
        .buttonStyle(.plain)
    }
}
```

- [ ] **Step 3: Create `Core/DesignSystem/Components/CategoryChip.swift`**

```swift
import SwiftUI

struct CategoryChip: View {
    let descriptor: String
    let name: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: MFSpacing.sm) {
                Text(descriptor)
                    .mfTextStyle(.overline)
                Text(name)
                    .font(.mf(.uiLabel))
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .imageScale(.small)
                        .bold()
                }
            }
            .foregroundStyle(isSelected ? Color.mfOnPrimary : Color.mfOnSurface)
            .padding(.horizontal, MFSpacing.md)
            .padding(.vertical, MFSpacing.md)
            .background {
                RoundedRectangle(cornerRadius: MFRadius.full)
                    .fill(isSelected ? Color.mfPrimary : Color.mfSurfaceContainerHigh)
            }
        }
        .buttonStyle(.plain)
    }
}
```

- [ ] **Step 4: Create `Core/DesignSystem/Components/FactCard.swift`**

```swift
import SwiftUI

/// The visual centerpiece of the app. `mfSurfaceContainerLow` fill on a
/// `mfSurface` background creates the tonal lift. Do not change the fill token
/// without updating the scaffold spec and Brand Guideline reference.
struct FactCard: View {
    let descriptor: String      // category descriptor, e.g. "FUTURE"
    let name: String            // category name, e.g. "Space"
    let body: String            // fact body
    let sourceURL: URL?         // visible only when premium-tier rendering
    let isSaved: Bool
    let onSave: () -> Void
    let onShare: () -> Void
    let onFlag: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: MFSpacing.lg) {
            HStack(spacing: MFSpacing.sm) {
                Text(descriptor).mfTextStyle(.overline)
                Text("—").mfTextStyle(.overline)
                Text(name).mfTextStyle(.overline)
            }
            .foregroundStyle(Color.mfOnSurfaceVariant)

            Text(body)
                .font(.mf(.body))
                .foregroundStyle(Color.mfOnSurface)
                .lineSpacing(8)

            if let sourceURL {
                Text(sourceURL.host ?? sourceURL.absoluteString)
                    .font(.mf(.uiLabel))
                    .foregroundStyle(Color.mfPrimary)
                    .underline(true, color: Color.mfPrimary.opacity(0.5))
            }

            Spacer(minLength: MFSpacing.lg)

            HStack(spacing: MFSpacing.xl) {
                actionButton(systemName: isSaved ? "bookmark.fill" : "bookmark", action: onSave)
                actionButton(systemName: "square.and.arrow.up", action: onShare)
                actionButton(systemName: "flag", action: onFlag)
            }
            .foregroundStyle(Color.mfOnSurfaceVariant)
        }
        .padding(MFSpacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: MFRadius.xl)
                .fill(Color.mfSurfaceContainerLow)
        }
        .padding(.horizontal, MFSpacing.md)
    }

    private func actionButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .imageScale(.medium)
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
    }
}
```

- [ ] **Step 5: Build to verify**

Run: `xcodebuild ... build -quiet`
Expected: exit 0.

- [ ] **Step 6: Commit**

```bash
git add Core/DesignSystem/Components/PrimaryButton.swift \
        Core/DesignSystem/Components/SecondaryButton.swift \
        Core/DesignSystem/Components/CategoryChip.swift \
        Core/DesignSystem/Components/FactCard.swift
git commit -m "feat(design-system): add PrimaryButton, SecondaryButton, CategoryChip, FactCard"
```

---

## Task 8: Domain types

**Files:**
- Create: `Domain/Tier.swift`
- Create: `Domain/Edition.swift`
- Create: `Domain/Mood.swift`
- Create: `Domain/Obscurity.swift`
- Create: `Domain/Category.swift`
- Create: `Domain/Fact.swift`

- [ ] **Step 1: Create `Domain/Tier.swift`**

```swift
import Foundation

enum Tier: String, Codable, Sendable {
    case free
    case trial
    case premium
    case expired
}
```

- [ ] **Step 2: Create `Domain/Edition.swift`**

```swift
import Foundation

enum Edition: String, Codable, Sendable {
    case morning
    case evening
}
```

- [ ] **Step 3: Create `Domain/Mood.swift`**

```swift
import Foundation

enum Mood: String, Codable, Sendable {
    case spark
    case settle
    case both
}
```

- [ ] **Step 4: Create `Domain/Obscurity.swift`**

```swift
import Foundation

enum Obscurity: String, Codable, Sendable {
    case common
    case moderate
    case deepCut
}
```

- [ ] **Step 5: Create `Domain/Category.swift`**

```swift
import Foundation

struct Category: Identifiable, Hashable, Codable, Sendable {
    let id: UUID
    let descriptor: String   // e.g. "CULTURE"
    let name: String         // e.g. "Architecture"
}
```

- [ ] **Step 6: Create `Domain/Fact.swift`**

```swift
import Foundation

struct Fact: Identifiable, Hashable, Codable, Sendable {
    let id: UUID
    let body: String              // free-tier length: 2–3 sentences
    let premiumBody: String?      // premium-tier extended: 4–6 sentences
    let category: Category
    let mood: Mood
    let obscurity: Obscurity
    let sourceURL: URL?           // surfaced only when tier == .premium
}
```

- [ ] **Step 7: Build to verify**

Run: `xcodebuild ... build -quiet`
Expected: exit 0.

- [ ] **Step 8: Commit**

```bash
git add Domain/
git commit -m "feat(domain): add Fact, Category, Tier, Edition, Mood, Obscurity"
```

---

## Task 9: Core service protocols and Mock implementations

**Files:**
- Create: `Core/Auth/AuthService.swift`
- Create: `Core/Auth/MockAuthService.swift`
- Create: `Core/Entitlements/EntitlementService.swift`
- Create: `Core/Entitlements/MockEntitlementService.swift`
- Create: `Core/Notifications/NotificationService.swift`
- Create: `Core/Notifications/MockNotificationService.swift`
- Create: `Core/Persistence/PersistenceService.swift`
- Create: `Core/Sharing/ShareImageService.swift`
- Create: `Core/Supabase/SupabaseClientProvider.swift`
- Create: `Domain/FactStore.swift`

- [ ] **Step 1: Create `Domain/FactStore.swift` (the protocol the mock and future repository both conform to)**

```swift
import Foundation

protocol FactStore: Sendable {
    /// Returns the facts to render for today's edition.
    /// - Free tier: one fact. Premium tier: up to three.
    /// - Categories filter empty means "everything".
    func todayFacts(for tier: Tier, in categories: Set<UUID>) async throws -> [Fact]
}
```

- [ ] **Step 2: Create `Core/Auth/AuthService.swift`**

```swift
import Foundation

protocol AuthService: AnyObject, Sendable {
    var isSignedIn: Bool { get }
    func signIn() async throws
    func signOut() async throws
}
```

- [ ] **Step 3: Create `Core/Auth/MockAuthService.swift`**

```swift
import Foundation

// MARK: - INTEGRATION(codex): Replace with real Sign in with Apple via Supabase Auth.
//   contract: AuthService protocol in Core/Auth/AuthService.swift
//   foundation spec: docs/architecture/auth-and-entitlements.md
final class MockAuthService: AuthService, @unchecked Sendable {
    private(set) var isSignedIn: Bool = false

    func signIn() async throws { isSignedIn = true }
    func signOut() async throws { isSignedIn = false }
}
```

- [ ] **Step 4: Create `Core/Entitlements/EntitlementService.swift`**

```swift
import Foundation

protocol EntitlementService: AnyObject, Sendable {
    var currentTier: Tier { get }
    func refresh() async throws
}
```

- [ ] **Step 5: Create `Core/Entitlements/MockEntitlementService.swift`**

```swift
import Foundation

// MARK: - INTEGRATION(codex): Replace with RevenueCat-backed entitlements that read
//   user_entitlements from Supabase per docs/architecture/auth-and-entitlements.md.
final class MockEntitlementService: EntitlementService, @unchecked Sendable {
    var currentTier: Tier = .free
    func refresh() async throws { /* no-op in scaffold */ }
}
```

- [ ] **Step 6: Create `Core/Notifications/NotificationService.swift`**

```swift
import Foundation

protocol NotificationService: AnyObject, Sendable {
    func requestAuthorization() async throws -> Bool
    func scheduleMorning(at time: Date) async throws
    func scheduleEvening(at time: Date) async throws
    func cancelAll() async throws
}
```

- [ ] **Step 7: Create `Core/Notifications/MockNotificationService.swift`**

```swift
import Foundation

// MARK: - INTEGRATION(codex): Replace with UNUserNotificationCenter scheduling.
//   contract: NotificationService protocol
//   constraints: silent by default, no streak reminders, time-zone-aware per
//   docs/product/onboarding-flow.md
final class MockNotificationService: NotificationService, @unchecked Sendable {
    func requestAuthorization() async throws -> Bool { true }
    func scheduleMorning(at time: Date) async throws { print("[mock] schedule morning at \(time)") }
    func scheduleEvening(at time: Date) async throws { print("[mock] schedule evening at \(time)") }
    func cancelAll() async throws { print("[mock] cancel all") }
}
```

- [ ] **Step 8: Create `Core/Persistence/PersistenceService.swift`**

```swift
import Foundation

// MARK: - INTEGRATION(codex): Replace with SwiftData-backed persistence per
//   foundation spec. The scaffold has no persistence — AppState resets on relaunch.
protocol PersistenceService: AnyObject, Sendable {
    func loadOnboardingComplete() async -> Bool
    func saveOnboardingComplete(_ value: Bool) async
}
```

- [ ] **Step 9: Create `Core/Sharing/ShareImageService.swift`**

```swift
import SwiftUI

// MARK: - INTEGRATION(codex): Replace with ImageRenderer-based card-to-image
//   rendering driving UIActivityViewController. Scaffold falls back to a plain
//   text share at the call site.
protocol ShareImageService: AnyObject, Sendable {
    @MainActor func renderCardImage(body: String) async -> UIImage?
}
```

- [ ] **Step 10: Create `Core/Supabase/SupabaseClientProvider.swift`**

```swift
import Foundation

// MARK: - INTEGRATION(codex): Configure Supabase client with project URL + anon key.
//   schema definition: docs/architecture/supabase-schema.md
//   The scaffold does not depend on Supabase; this file holds the seam.
enum SupabaseClientProvider {
    static let placeholder: Void = ()
}
```

- [ ] **Step 11: Build to verify**

Run: `xcodebuild ... build -quiet`
Expected: exit 0.

- [ ] **Step 12: Commit**

```bash
git add Core/ Domain/FactStore.swift
git commit -m "feat(core): add service protocols and Mock implementations"
```

---

## Task 10: Mock data — categories and facts

**Files:**
- Create: `Mock/MockCategories.swift`
- Create: `Mock/MockFactStore.swift`

- [ ] **Step 1: Create `Mock/MockCategories.swift`**

```swift
import Foundation

enum MockCategories {
    static let architecture   = Category(id: UUID(uuidString: "11111111-0000-0000-0000-000000000001")!, descriptor: "CULTURE",    name: "Architecture")
    static let history        = Category(id: UUID(uuidString: "11111111-0000-0000-0000-000000000002")!, descriptor: "HUMANITY",   name: "History")
    static let science        = Category(id: UUID(uuidString: "11111111-0000-0000-0000-000000000003")!, descriptor: "INNOVATION", name: "Science")
    static let philosophy     = Category(id: UUID(uuidString: "11111111-0000-0000-0000-000000000004")!, descriptor: "THE MIND",   name: "Philosophy & Thought")
    static let space          = Category(id: UUID(uuidString: "11111111-0000-0000-0000-000000000005")!, descriptor: "FUTURE",     name: "Space")
    static let ecology        = Category(id: UUID(uuidString: "11111111-0000-0000-0000-000000000006")!, descriptor: "OUTDOORS",   name: "Ecology")

    static let all: [Category] = [architecture, history, science, philosophy, space, ecology]
}
```

- [ ] **Step 2: Create `Mock/MockFactStore.swift`**

Twelve hand-written facts in Morning Fax voice — two per category. Each has a free body (2–3 sentences) and a premium body (4–6 sentences).

```swift
import Foundation

// MARK: - INTEGRATION(codex): Replace with FactRepository backed by Supabase `facts`
//   table per docs/architecture/supabase-schema.md.
//   contract preserved: func todayFacts(for: Tier, in: Set<UUID>) async throws -> [Fact]
//   constraints: production dedupe comes from Supabase user_served_facts;
//                sourceURL only surfaced when tier == .premium.
final class MockFactStore: FactStore, @unchecked Sendable {

    private let facts: [Fact] = [
        // CULTURE — Architecture
        Fact(id: UUID(), body: """
            The Pantheon's concrete dome has stood unreinforced for nearly two thousand years. Roman engineers \
            graded their aggregate by weight, using heavy basalt at the base and feather-light pumice at the crown.
            """,
            premiumBody: """
            The Pantheon's concrete dome has stood unreinforced for nearly two thousand years, and we are still \
            arguing about how. Roman engineers graded their aggregate by weight, using heavy basalt at the base \
            and feather-light pumice at the crown — a tonnage gradient that quietly shifts the structural load. \
            The oculus, often described as decoration, is in fact load-shedding: removing the keystone region \
            reduces the dome's overall weight by enough to be measurable. It is a structure that improves by \
            being incomplete.
            """,
            category: MockCategories.architecture, mood: .spark, obscurity: .moderate,
            sourceURL: URL(string: "https://www.britannica.com/topic/Pantheon-building-Rome-Italy")),

        Fact(id: UUID(), body: """
            Brutalist concrete was originally meant to be temporary. Postwar architects expected the rough \
            shuttering marks to weather away into a polished gray within a generation.
            """,
            premiumBody: """
            Brutalist concrete was originally meant to be temporary. Postwar architects expected the rough \
            shuttering marks — the imprint of the wooden form-work — to weather away into a polished gray \
            within a generation. Instead the marks proved durable. The texture we now read as the defining \
            feature of the movement was, in many cases, a side effect waiting to disappear.
            """,
            category: MockCategories.architecture, mood: .settle, obscurity: .moderate, sourceURL: nil),

        // HUMANITY — History
        Fact(id: UUID(), body: """
            Cleopatra lived closer in time to the moon landing than to the construction of the Great Pyramid \
            of Giza. The pyramid was already two thousand years old in her childhood.
            """,
            premiumBody: """
            Cleopatra lived closer in time to the moon landing than to the construction of the Great Pyramid \
            of Giza. The pyramid was already two thousand years old in her childhood — older to her than the \
            Roman Forum is to us. Egyptian history was, even from the inside, mostly archaeology by the time \
            the figures we recognize as 'ancient Egyptians' were alive.
            """,
            category: MockCategories.history, mood: .spark, obscurity: .common, sourceURL: nil),

        Fact(id: UUID(), body: """
            Oxford University was already two centuries old when the Aztec capital of Tenochtitlán was founded. \
            Both have been called 'ancient' in the same sentence.
            """,
            premiumBody: """
            Oxford University was already two centuries old when the Aztec capital of Tenochtitlán was founded. \
            Both have been called 'ancient' in the same sentence, despite being separated by an ocean and a \
            century of overlap. Time depth is uneven across the world's institutions in ways that resist a tidy \
            single-line history.
            """,
            category: MockCategories.history, mood: .settle, obscurity: .moderate, sourceURL: nil),

        // INNOVATION — Science
        Fact(id: UUID(), body: """
            Honey buried in Egyptian tombs has been unearthed still edible after three thousand years. Its \
            chemistry — low water, low pH, mild peroxide — refuses to spoil.
            """,
            premiumBody: """
            Honey buried in Egyptian tombs has been unearthed still edible after three thousand years. Its \
            chemistry is the trick: bees concentrate nectar to a sugar saturation that bacteria cannot live in, \
            then add the enzyme glucose oxidase, which produces small amounts of hydrogen peroxide. Combined with \
            a low pH and very little free water, this makes honey one of the most quietly hostile environments \
            in the kitchen.
            """,
            category: MockCategories.science, mood: .spark, obscurity: .common,
            sourceURL: URL(string: "https://www.smithsonianmag.com/science-nature/the-science-behind-honeys-eternal-shelf-life-1218690/")),

        Fact(id: UUID(), body: """
            The longest-running scientific experiment is a single drop of pitch. It has been falling, very \
            slowly, in a Brisbane laboratory since 1927.
            """,
            premiumBody: """
            The longest-running scientific experiment is a single drop of pitch. Bitumen looks solid at room \
            temperature but is, in fact, a liquid of staggering viscosity. The Pitch Drop Experiment at the \
            University of Queensland, started in 1927, has produced nine drops in nearly a century. The first \
            drop ever caught on camera fell in 2014 — and the camera missed it.
            """,
            category: MockCategories.science, mood: .settle, obscurity: .moderate, sourceURL: nil),

        // THE MIND — Philosophy & Thought
        Fact(id: UUID(), body: """
            Descartes wrote "I think, therefore I am" not as a triumph but as the only thing he could not bring \
            himself to doubt. The line is the floor of his skepticism, not its ceiling.
            """,
            premiumBody: """
            Descartes wrote "I think, therefore I am" not as a triumph but as the only thing he could not bring \
            himself to doubt. He had spent the preceding pages systematically dismantling everything else: the \
            senses can lie, mathematics could be a deception, even the existence of his own body was suspect. \
            The famous line is the floor of his skepticism, not its ceiling — a single floorboard he could not \
            pry up.
            """,
            category: MockCategories.philosophy, mood: .settle, obscurity: .moderate, sourceURL: nil),

        Fact(id: UUID(), body: """
            The Stoics held that emotions are not events that happen to us, but judgments we make. Anger is a \
            decision, repeatable, and therefore answerable.
            """,
            premiumBody: """
            The Stoics held that emotions are not events that happen to us, but judgments we make. Anger, in \
            this view, is a decision: the decision that something has been taken from us, that we are owed, that \
            the offender deserves response. Because the decision is repeated, it can be examined, and because it \
            can be examined, it can be answered. The practice is uncomfortable. It refuses to grant emotion the \
            status of weather.
            """,
            category: MockCategories.philosophy, mood: .both, obscurity: .moderate, sourceURL: nil),

        // FUTURE — Space
        Fact(id: UUID(), body: """
            A day on Venus is longer than its year. The planet rotates so slowly — and backwards — that the sun \
            crosses its sky just twice per Venusian year.
            """,
            premiumBody: """
            A day on Venus is longer than its year. The planet rotates so slowly — and in the opposite direction \
            from Earth — that a single rotation takes 243 Earth days, while a complete orbit of the sun takes \
            only 225. The sun, when it is visible at all through the sulfuric acid haze, rises in the west and \
            sets in the east, and crosses the sky just twice per Venusian year.
            """,
            category: MockCategories.space, mood: .spark, obscurity: .common, sourceURL: nil),

        Fact(id: UUID(), body: """
            There is a planet of solid diamond circling a pulsar. It is denser than lead and probably the \
            crystalline corpse of a star.
            """,
            premiumBody: """
            There is a planet of solid diamond circling a pulsar. PSR J1719-1438 b is denser than lead and \
            probably the crystalline corpse of a star — a former white dwarf that had its outer layers stripped \
            away by its neutron-star companion until only its carbon core remained. At those pressures, carbon \
            crystallizes. A planet, in the technical sense, made of diamond.
            """,
            category: MockCategories.space, mood: .settle, obscurity: .deepCut,
            sourceURL: URL(string: "https://www.nasa.gov/news-release/nasa-telescope-finds-elusive-buckyballs-in-space-for-first-time/")),

        // OUTDOORS — Ecology
        Fact(id: UUID(), body: """
            A single mature oak can host more than two thousand other species over its lifetime. The tree is \
            less an organism than a slow-moving city.
            """,
            premiumBody: """
            A single mature oak can host more than two thousand other species over its lifetime, from gall wasps \
            and lichens to fungi, beetles, and the small mammals that depend on the acorns. The tree is less an \
            organism than a slow-moving city, providing housing on a timescale that overlaps with the entire \
            recorded history of some of its tenants.
            """,
            category: MockCategories.ecology, mood: .settle, obscurity: .moderate, sourceURL: nil),

        Fact(id: UUID(), body: """
            The clonal aspen colony Pando is one of the largest living organisms on Earth — forty thousand \
            trunks rising from a single, ancient root system.
            """,
            premiumBody: """
            The clonal aspen colony Pando — Latin for 'I spread' — is one of the largest living organisms on \
            Earth. Roughly forty thousand trunks rise from a single, genetically identical root system that \
            covers more than a hundred acres of Utah forest. Estimates of its age range from several thousand \
            to nearly a million years; we have, charmingly, no agreed-upon way to measure the age of a thing \
            that has never died.
            """,
            category: MockCategories.ecology, mood: .both, obscurity: .deepCut,
            sourceURL: URL(string: "https://www.nps.gov/places/pando.htm"))
    ]

    func todayFacts(for tier: Tier, in categories: Set<UUID>) async throws -> [Fact] {
        let pool = facts.filter { categories.isEmpty || categories.contains($0.category.id) }
        switch tier {
        case .free:
            return Array(pool.prefix(1))
        case .trial, .premium:
            return Array(pool.prefix(3))
        case .expired:
            return Array(pool.prefix(1))
        }
    }
}
```

- [ ] **Step 3: Build to verify**

Run: `xcodebuild ... build -quiet`
Expected: exit 0.

- [ ] **Step 4: Commit**

```bash
git add Mock/
git commit -m "feat(mock): add 12 seeded facts across 6 launch categories"
```

---

## Task 11: AppState and AppRouter

**Files:**
- Create: `App/AppState.swift`
- Create: `App/AppRouter.swift`
- Modify: `App/MorningFaxApp.swift` (full app entry now)

- [ ] **Step 1: Create `App/AppState.swift`**

```swift
import SwiftUI
import Foundation

// MARK: - INTEGRATION(codex): Persist AppState via the persistence layer chosen
//   at integration time (UserDefaults, SwiftData, or server-backed). The scaffold
//   resets on relaunch by design.
@MainActor
@Observable
final class AppState {
    let auth: any AuthService
    let entitlements: any EntitlementService
    let notifications: any NotificationService
    let factStore: any FactStore

    // Auth + onboarding gating
    var isSignedIn: Bool = false
    var hasOnboarded: Bool = false

    // Ritual
    var morningTime: Date = .now
    var eveningEnabled: Bool = false
    var eveningTime: Date = .now

    // Palette
    var selectedCategoryIDs: Set<UUID> = []
    var everythingSelected: Bool = true

    // Reader
    var savedFactIDs: Set<UUID> = []
    var seenFactIDs: Set<UUID> = []

    // Tier mirror (mock; Codex wires the real read path)
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

- [ ] **Step 2: Create `App/AppRouter.swift`**

```swift
import SwiftUI

// MARK: - INTEGRATION(codex): handle deep links via .onOpenURL and notification
//   routing via UNNotificationContent → fact detail per docs/product/onboarding-flow.md.
struct AppRouter: View {
    @Environment(AppState.self) private var appState
    @State private var showSplash = true

    var body: some View {
        ZStack {
            rootView

            if showSplash {
                SplashView()
                    .transition(.opacity)
            }
        }
        .task {
            try? await Task.sleep(for: .seconds(1.2))
            withAnimation(.easeOut(duration: 0.4)) { showSplash = false }
        }
    }

    @ViewBuilder
    private var rootView: some View {
        if !appState.isSignedIn {
            SignInView()
        } else if !appState.hasOnboarded {
            OnboardingFlow()
        } else {
            TodayView()
        }
    }
}
```

- [ ] **Step 3: Replace the placeholder `App/MorningFaxApp.swift`**

```swift
import SwiftUI

@main
struct MorningFaxApp: App {
    @State private var appState: AppState = {
        AppState(
            auth: MockAuthService(),
            entitlements: MockEntitlementService(),
            notifications: MockNotificationService(),
            factStore: MockFactStore()
        )
    }()

    var body: some Scene {
        WindowGroup {
            AppRouter()
                .environment(appState)
                .preferredColorScheme(.light)
                .background(Color.mfSurface.ignoresSafeArea())
        }
    }
}
```

- [ ] **Step 4: Build (will fail — `SplashView`, `SignInView`, `OnboardingFlow`, `TodayView` not defined yet)**

Run: `xcodebuild ... build -quiet`
Expected: build errors naming the four undefined views. This is fine — the next tasks define them. Do NOT commit yet.

- [ ] **Step 5: Defer commit until Task 12**

Skip the commit; the next tasks will resolve the missing views and the project will build cleanly at that point.

---

## Task 12: SplashView (and the project compiles again)

**Files:**
- Create: `Features/Splash/SplashView.swift`
- Create: `Features/SignIn/SignInView.swift` (stub so the project builds; full content in Task 13)
- Create: `Features/Onboarding/OnboardingFlow.swift` (stub; full content in Task 17)
- Create: `Features/Today/TodayView.swift` (stub; full content in Task 18)

- [ ] **Step 1: Create `Features/Splash/SplashView.swift`**

```swift
import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            // Subtle sage MeshGradient backdrop. iOS 18 API.
            MeshGradient(
                width: 3, height: 3,
                points: [
                    [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                    [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
                    [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
                ],
                colors: [
                    .mfSurface,                .mfPrimaryContainer.opacity(0.4), .mfSurface,
                    .mfPrimaryContainer.opacity(0.6), .mfSurface, .mfPrimaryContainer.opacity(0.4),
                    .mfSurface,                .mfPrimaryContainer.opacity(0.3), .mfSurface
                ]
            )
            .ignoresSafeArea()

            VStack(spacing: MFSpacing.md) {
                ZStack {
                    Image(systemName: "envelope")
                        .font(.mf(.displayLG))
                        .foregroundStyle(Color.mfPrimary)
                    Image(systemName: "sparkle")
                        .font(.mf(.uiLabel))
                        .foregroundStyle(Color.mfPrimaryFixedDim)
                        .offset(x: 28, y: -22)
                }
                Text("Morning Fax")
                    .font(.mf(.headlineMD))
                    .foregroundStyle(Color.mfOnSurface)
            }
        }
    }
}

#Preview { SplashView() }
```

- [ ] **Step 2: Create `Features/SignIn/SignInView.swift` (stub)**

```swift
import SwiftUI

// MARK: - INTEGRATION(codex): Replace with Sign in with Apple via Supabase Auth
//   per docs/architecture/auth-and-entitlements.md. The scaffold's Continue button
//   simply calls the mock so the navigation graph runs end to end.
struct SignInView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        ZStack {
            Color.mfSurface.ignoresSafeArea()
            VStack(spacing: MFSpacing.lg) {
                Spacer()
                Text("Morning Fax")
                    .font(.mf(.headlineMD))
                    .foregroundStyle(Color.mfOnSurface)
                Text("Design TBD — placeholder for Codex.")
                    .font(.mf(.uiLabel))
                    .foregroundStyle(Color.mfOnSurfaceVariant)
                Spacer()
                PrimaryButton(title: "Continue") {
                    Task {
                        try? await appState.auth.signIn()
                        appState.isSignedIn = appState.auth.isSignedIn
                    }
                }
                .padding(.horizontal, MFSpacing.xl)
                .padding(.bottom, MFSpacing.xl)
            }
        }
    }
}
```

- [ ] **Step 3: Create `Features/Onboarding/OnboardingFlow.swift` (stub — full body in Task 17)**

```swift
import SwiftUI

struct OnboardingFlow: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        // Full implementation arrives in Task 17.
        VStack(spacing: MFSpacing.lg) {
            Text("Onboarding (stub)").font(.mf(.headlineMD))
            PrimaryButton(title: "Skip onboarding (scaffold)") {
                appState.hasOnboarded = true
            }
            .padding(.horizontal, MFSpacing.xl)
        }
    }
}
```

- [ ] **Step 4: Create `Features/Today/TodayView.swift` (stub — full body in Task 18)**

```swift
import SwiftUI

struct TodayView: View {
    var body: some View {
        // Full implementation arrives in Task 18.
        ZStack {
            Color.mfSurface.ignoresSafeArea()
            Text("Today (stub)").font(.mf(.headlineMD))
        }
    }
}
```

- [ ] **Step 5: Build to verify**

Run: `xcodebuild ... build -quiet`
Expected: exit 0. The project compiles end to end with stubs.

- [ ] **Step 6: Run on simulator and confirm splash → SignIn → onboarding stub → Today stub**

Boot iPhone 16 simulator, install, launch. Expected:
1. Splash for 1.2s with sage MeshGradient and "Morning Fax" wordmark.
2. Splash fades; SignInView appears with "Continue".
3. Tap Continue → OnboardingFlow stub.
4. Tap "Skip onboarding (scaffold)" → TodayView stub.

If any step fails, the AppRouter logic in Task 11 is wrong.

- [ ] **Step 7: Commit**

```bash
git add App/AppState.swift App/AppRouter.swift App/MorningFaxApp.swift \
        Features/Splash/SplashView.swift \
        Features/SignIn/SignInView.swift \
        Features/Onboarding/OnboardingFlow.swift \
        Features/Today/TodayView.swift
git commit -m "feat(app): add AppState, AppRouter, SplashView, and feature stubs"
```

---

## Task 13: SignInView placeholder polish

The Task 12 stub already satisfies the spec for `SignInView`. No additional code needed — the placeholder treatment, mock signIn invocation, and INTEGRATION marker are all in place.

- [ ] **Step 1: Verify the SignInView in `Features/SignIn/SignInView.swift` matches the spec**

Open the file. Confirm:
- Top-of-file `INTEGRATION(codex)` marker present.
- Renders a `Text` placeholder line.
- Single `PrimaryButton("Continue")` that calls `appState.auth.signIn()` and flips `isSignedIn`.

If any are missing, add them now and commit. Otherwise no commit is needed and proceed to Task 14.

---

## Task 14: Onboarding placeholder views (Welcome, PremiumOffer, NotificationPermission)

**Files:**
- Create: `Features/Onboarding/WelcomeView.swift`
- Create: `Features/Onboarding/PremiumOfferView.swift`
- Create: `Features/Onboarding/NotificationPermissionView.swift`

- [ ] **Step 1: Create `Features/Onboarding/WelcomeView.swift`**

```swift
import SwiftUI

// MARK: - INTEGRATION(codex): Final design TBD. Quiet welcome introducing the
//   product as a daily ritual for curiosity per docs/product/onboarding-flow.md.
struct WelcomeView: View {
    let onContinue: () -> Void

    var body: some View {
        OnboardingPlaceholderScaffold(
            title: "Welcome",
            body: "Design TBD — placeholder for Codex.",
            primaryTitle: "Continue",
            primaryAction: onContinue
        )
    }
}
```

- [ ] **Step 2: Create `Features/Onboarding/PremiumOfferView.swift`**

```swift
import SwiftUI

// MARK: - INTEGRATION(codex): Soft premium offer wired to RevenueCat offerings
//   per docs/product/freemium-rules.md. Scaffold advances regardless of choice.
struct PremiumOfferView: View {
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            Color.mfSurface.ignoresSafeArea()
            VStack(spacing: MFSpacing.lg) {
                Spacer()
                Text("Premium")
                    .font(.mf(.headlineMD))
                    .foregroundStyle(Color.mfOnSurface)
                Text("Design TBD — placeholder for Codex.")
                    .font(.mf(.uiLabel))
                    .foregroundStyle(Color.mfOnSurfaceVariant)
                Spacer()
                VStack(spacing: MFSpacing.md) {
                    PrimaryButton(title: "Try Premium", action: onContinue)
                    SecondaryButton(title: "Continue Free", action: onContinue)
                }
                .padding(.horizontal, MFSpacing.xl)
                .padding(.bottom, MFSpacing.xl)
            }
        }
    }
}
```

- [ ] **Step 3: Create `Features/Onboarding/NotificationPermissionView.swift`**

```swift
import SwiftUI

// MARK: - INTEGRATION(codex): Wire the system permission prompt and persist the
//   user's choice via NotificationService per docs/architecture/auth-and-entitlements.md.
struct NotificationPermissionView: View {
    @Environment(AppState.self) private var appState
    let onComplete: () -> Void

    var body: some View {
        OnboardingPlaceholderScaffold(
            title: "Notifications",
            body: "Notifications are silent by default to preserve the morning's quietude.",
            primaryTitle: "Allow notifications",
            primaryAction: {
                Task {
                    _ = try? await appState.notifications.requestAuthorization()
                    onComplete()
                }
            }
        )
    }
}
```

- [ ] **Step 4: Create `Features/Onboarding/OnboardingPlaceholderScaffold.swift` (shared template for placeholder onboarding screens)**

```swift
import SwiftUI

struct OnboardingPlaceholderScaffold: View {
    let title: String
    let body: String
    let primaryTitle: String
    let primaryAction: () -> Void

    var bodyView: some View {
        ZStack {
            Color.mfSurface.ignoresSafeArea()
            VStack(spacing: MFSpacing.lg) {
                Spacer()
                Text(title)
                    .font(.mf(.headlineMD))
                    .foregroundStyle(Color.mfOnSurface)
                Text(body)
                    .font(.mf(.body))
                    .foregroundStyle(Color.mfOnSurfaceVariant)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, MFSpacing.xl)
                Spacer()
                PrimaryButton(title: primaryTitle, action: primaryAction)
                    .padding(.horizontal, MFSpacing.xl)
                    .padding(.bottom, MFSpacing.xl)
            }
        }
    }

    var body: some View { bodyView }
}
```

- [ ] **Step 5: Build to verify**

Run: `xcodebuild ... build -quiet`
Expected: exit 0.

- [ ] **Step 6: Commit**

```bash
git add Features/Onboarding/WelcomeView.swift \
        Features/Onboarding/PremiumOfferView.swift \
        Features/Onboarding/NotificationPermissionView.swift \
        Features/Onboarding/OnboardingPlaceholderScaffold.swift
git commit -m "feat(onboarding): add Welcome, PremiumOffer, NotificationPermission placeholders"
```

---

## Task 15: Onboarding setup screens — MorningTime + EveningEdition

**Files:**
- Create: `Features/Onboarding/MorningTimeView.swift`
- Create: `Features/Onboarding/EveningEditionView.swift`

- [ ] **Step 1: Create `Features/Onboarding/MorningTimeView.swift`**

```swift
import SwiftUI

struct MorningTimeView: View {
    @Environment(AppState.self) private var appState
    let onContinue: () -> Void

    var body: some View {
        @Bindable var appState = appState

        ZStack {
            Color.mfSurface.ignoresSafeArea()
            VStack(alignment: .leading, spacing: MFSpacing.lg) {
                Text("STEP 2 OF 6").mfTextStyle(.overline).foregroundStyle(Color.mfOnSurfaceVariant)

                Text("When should we slide it under your digital door?")
                    .font(.mf(.headlineMD))
                    .foregroundStyle(Color.mfOnSurface)
                    .lineSpacing(6)

                Text("Your Morning Fax is curated overnight. Pick a time that feels like the start of your day.")
                    .font(.mf(.body))
                    .foregroundStyle(Color.mfOnSurfaceVariant)
                    .lineSpacing(8)

                DatePicker("Morning time", selection: $appState.morningTime, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .datePickerStyle(.wheel)
                    .padding(MFSpacing.md)
                    .background(Color.mfSurfaceContainerLow)
                    .ghostBorderBottom()
                    .clipShape(RoundedRectangle(cornerRadius: MFRadius.md))

                Spacer()

                PrimaryButton(title: "Continue", action: onContinue)
            }
            .padding(.horizontal, MFSpacing.xl)
            .padding(.top, MFSpacing.xxl)
            .padding(.bottom, MFSpacing.xl)
        }
    }
}
```

- [ ] **Step 2: Create `Features/Onboarding/EveningEditionView.swift`**

```swift
import SwiftUI

struct EveningEditionView: View {
    @Environment(AppState.self) private var appState
    let onContinue: () -> Void

    var body: some View {
        @Bindable var appState = appState

        ZStack {
            Color.mfSurface.ignoresSafeArea()
            VStack(alignment: .leading, spacing: MFSpacing.lg) {
                Text("STEP 3 OF 6").mfTextStyle(.overline).foregroundStyle(Color.mfOnSurfaceVariant)

                Text("Care for an evening edition?")
                    .font(.mf(.headlineMD))
                    .foregroundStyle(Color.mfOnSurface)

                Text("A reflective fact to wind down with. Off by default, on whenever you like.")
                    .font(.mf(.body))
                    .foregroundStyle(Color.mfOnSurfaceVariant)
                    .lineSpacing(8)

                Toggle("Evening edition", isOn: $appState.eveningEnabled)
                    .font(.mf(.uiLabel))
                    .padding(MFSpacing.md)
                    .background(Color.mfSurfaceContainerLow)
                    .clipShape(RoundedRectangle(cornerRadius: MFRadius.md))

                if appState.eveningEnabled {
                    DatePicker("Evening time", selection: $appState.eveningTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .datePickerStyle(.wheel)
                        .padding(MFSpacing.md)
                        .background(Color.mfSurfaceContainerLow)
                        .ghostBorderBottom()
                        .clipShape(RoundedRectangle(cornerRadius: MFRadius.md))
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }

                Spacer()
                PrimaryButton(title: "Continue", action: onContinue)
            }
            .animation(.easeInOut(duration: 0.2), value: appState.eveningEnabled)
            .padding(.horizontal, MFSpacing.xl)
            .padding(.top, MFSpacing.xxl)
            .padding(.bottom, MFSpacing.xl)
        }
    }
}
```

- [ ] **Step 3: Build to verify**

Run: `xcodebuild ... build -quiet`
Expected: exit 0.

- [ ] **Step 4: Commit**

```bash
git add Features/Onboarding/MorningTimeView.swift Features/Onboarding/EveningEditionView.swift
git commit -m "feat(onboarding): add MorningTimeView and EveningEditionView"
```

---

## Task 16: CategoriesView + CategoriesViewModel

**Files:**
- Create: `Features/Onboarding/CategoriesViewModel.swift`
- Create: `Features/Onboarding/CategoriesView.swift`

- [ ] **Step 1: Create `Features/Onboarding/CategoriesViewModel.swift`**

```swift
import Foundation

@MainActor
@Observable
final class CategoriesViewModel {
    var selectedIDs: Set<UUID> = []
    var everythingSelected: Bool = true

    let allCategories: [Category]

    init(allCategories: [Category] = MockCategories.all) {
        self.allCategories = allCategories
    }

    var canContinue: Bool {
        everythingSelected || !selectedIDs.isEmpty
    }

    func tapEverything() {
        everythingSelected = true
        selectedIDs.removeAll()
    }

    func tapCategory(_ id: UUID) {
        everythingSelected = false
        if selectedIDs.contains(id) {
            selectedIDs.remove(id)
        } else {
            selectedIDs.insert(id)
        }
    }

    func commit(to appState: AppState) {
        appState.everythingSelected = everythingSelected
        appState.selectedCategoryIDs = everythingSelected ? [] : selectedIDs
    }
}
```

- [ ] **Step 2: Create `Features/Onboarding/CategoriesView.swift`**

```swift
import SwiftUI

struct CategoriesView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = CategoriesViewModel()
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            Color.mfSurface.ignoresSafeArea()
            VStack(alignment: .leading, spacing: MFSpacing.lg) {
                Text("STEP 4 OF 6").mfTextStyle(.overline).foregroundStyle(Color.mfOnSurfaceVariant)

                Text("Pick your palette")
                    .font(.mf(.headlineMD))
                    .foregroundStyle(Color.mfOnSurface)

                Text("Start broad with Everything, or curate the categories you want to see.")
                    .font(.mf(.body))
                    .foregroundStyle(Color.mfOnSurfaceVariant)
                    .lineSpacing(8)

                ScrollView {
                    VStack(spacing: MFSpacing.sm) {
                        CategoryChip(
                            descriptor: "ALL",
                            name: "Everything",
                            isSelected: viewModel.everythingSelected,
                            action: { viewModel.tapEverything() }
                        )
                        ForEach(viewModel.allCategories) { category in
                            CategoryChip(
                                descriptor: category.descriptor,
                                name: category.name,
                                isSelected: viewModel.selectedIDs.contains(category.id),
                                action: { viewModel.tapCategory(category.id) }
                            )
                        }
                    }
                }

                PrimaryButton(title: "Continue", action: {
                    viewModel.commit(to: appState)
                    onContinue()
                }, isEnabled: viewModel.canContinue)
            }
            .padding(.horizontal, MFSpacing.xl)
            .padding(.top, MFSpacing.xxl)
            .padding(.bottom, MFSpacing.xl)
        }
    }
}
```

- [ ] **Step 3: Build to verify**

Run: `xcodebuild ... build -quiet`
Expected: exit 0.

- [ ] **Step 4: Commit**

```bash
git add Features/Onboarding/CategoriesView.swift Features/Onboarding/CategoriesViewModel.swift
git commit -m "feat(onboarding): add CategoriesView with mutually exclusive Everything/select"
```

---

## Task 17: OnboardingFlow coordinator (full body)

**Files:**
- Modify: `Features/Onboarding/OnboardingFlow.swift`

- [ ] **Step 1: Replace the stub `OnboardingFlow.swift` with the full coordinator**

```swift
import SwiftUI

struct OnboardingFlow: View {
    @Environment(AppState.self) private var appState
    @State private var path: [Step] = []

    enum Step: Hashable {
        case morningTime
        case eveningEdition
        case categories
        case premiumOffer
        case notificationPermission
    }

    var body: some View {
        NavigationStack(path: $path) {
            WelcomeView(onContinue: { path.append(.morningTime) })
                .navigationDestination(for: Step.self) { step in
                    switch step {
                    case .morningTime:
                        MorningTimeView(onContinue: { path.append(.eveningEdition) })
                    case .eveningEdition:
                        EveningEditionView(onContinue: { path.append(.categories) })
                    case .categories:
                        CategoriesView(onContinue: { path.append(.premiumOffer) })
                    case .premiumOffer:
                        PremiumOfferView(onContinue: { path.append(.notificationPermission) })
                    case .notificationPermission:
                        NotificationPermissionView(onComplete: completeOnboarding)
                    }
                }
        }
        .tint(Color.mfPrimary)
    }

    private func completeOnboarding() {
        appState.hasOnboarded = true
        // AppRouter re-evaluates and swaps root to TodayView.
    }
}
```

- [ ] **Step 2: Build to verify**

Run: `xcodebuild ... build -quiet`
Expected: exit 0.

- [ ] **Step 3: Run end-to-end onboarding on simulator**

Boot, launch, tap through Splash → SignIn → Welcome → MorningTime → EveningEdition → Categories → PremiumOffer → NotificationPermission. Expected: each transition pushes; back chevron returns; "Allow notifications" lands on TodayView stub.

If any step fails to push, the `path.append(.next)` chain is wrong — re-check Task 17 step 1.

- [ ] **Step 4: Commit**

```bash
git add Features/Onboarding/OnboardingFlow.swift
git commit -m "feat(onboarding): wire OnboardingFlow coordinator"
```

---

## Task 18: TodayView + TodayViewModel

**Files:**
- Create: `Features/Today/TodayViewModel.swift`
- Modify: `Features/Today/TodayView.swift`

- [ ] **Step 1: Create `Features/Today/TodayViewModel.swift`**

```swift
import Foundation

@MainActor
@Observable
final class TodayViewModel {
    var facts: [Fact] = []
    var currentIndex: Int = 0
    var isLoading: Bool = false
    var loadError: Error?

    func load(tier: Tier, categories: Set<UUID>, store: any FactStore) async {
        isLoading = true
        loadError = nil
        do {
            facts = try await store.todayFacts(for: tier, in: categories)
        } catch {
            loadError = error
            // TODO(codex): handle network and decoding failures with quiet retry per spec.
        }
        isLoading = false
    }
}
```

- [ ] **Step 2: Replace the stub `Features/Today/TodayView.swift`**

```swift
import SwiftUI

struct TodayView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = TodayViewModel()
    @State private var showSettings = false
    @State private var showFilter = false
    @State private var scrollPosition: Fact.ID?

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color.mfSurface.ignoresSafeArea()

                ScrollView(.vertical) {
                    LazyVStack(spacing: MFSpacing.lg) {
                        ForEach(viewModel.facts) { fact in
                            let isPremium = appState.tier == .premium || appState.tier == .trial
                            FactCard(
                                descriptor: fact.category.descriptor,
                                name: fact.category.name,
                                body: isPremium ? (fact.premiumBody ?? fact.body) : fact.body,
                                sourceURL: isPremium ? fact.sourceURL : nil,
                                isSaved: appState.savedFactIDs.contains(fact.id),
                                onSave: { toggleSave(fact.id) },
                                onShare: { /* TODO(codex): wire ShareImageService */ },
                                onFlag: { /* TODO(codex): wire feedback ingest */ }
                            )
                            .containerRelativeFrame(.vertical)
                            .id(fact.id)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.paging)
                .scrollPosition(id: $scrollPosition)
                .ignoresSafeArea(edges: .bottom)

                topBar
            }
            .task(id: appState.selectedCategoryIDs) {
                await viewModel.load(
                    tier: appState.tier,
                    categories: effectiveCategories,
                    store: appState.factStore
                )
            }
            .sheet(isPresented: $showSettings) { SettingsView() }
            .sheet(isPresented: $showFilter)   { CategoryFilterView() }
        }
        .tint(Color.mfPrimary)
    }

    private var effectiveCategories: Set<UUID> {
        appState.everythingSelected ? [] : appState.selectedCategoryIDs
    }

    private var topBar: some View {
        HStack {
            Text(Date.now, format: .dateTime.weekday(.wide).month(.abbreviated).day())
                .mfTextStyle(.overline)
                .foregroundStyle(Color.mfOnSurfaceVariant)
            Spacer()
            Button(action: { showFilter = true }) {
                Image(systemName: "line.3.horizontal.decrease")
                    .frame(width: 44, height: 44)
            }
            Button(action: { showSettings = true }) {
                Image(systemName: "gearshape")
                    .frame(width: 44, height: 44)
            }
        }
        .foregroundStyle(Color.mfOnSurface)
        .padding(.horizontal, MFSpacing.md)
        .padding(.vertical, MFSpacing.sm)
        .frostedSurface()
    }

    private func toggleSave(_ id: UUID) {
        if appState.savedFactIDs.contains(id) {
            appState.savedFactIDs.remove(id)
        } else {
            appState.savedFactIDs.insert(id)
        }
    }
}
```

- [ ] **Step 3: Build (will fail — `SettingsView` and `CategoryFilterView` not defined yet)**

Run: `xcodebuild ... build -quiet`
Expected: build errors naming the two undefined views. The next two tasks add them. Do NOT commit yet.

- [ ] **Step 4: Defer commit until after Task 19 (CategoryFilterView) and Task 20 (SettingsView)**

Skip the commit; the project won't build cleanly until both are present.

---

## Task 19: CategoryFilterView + view model

**Files:**
- Create: `Features/CategoryFilter/CategoryFilterViewModel.swift`
- Create: `Features/CategoryFilter/CategoryFilterView.swift`

- [ ] **Step 1: Create `Features/CategoryFilter/CategoryFilterViewModel.swift`**

```swift
import Foundation

@MainActor
@Observable
final class CategoryFilterViewModel {
    var workingSelectedIDs: Set<UUID>
    var workingEverything: Bool
    var searchText: String = ""
    let allCategories: [Category]

    init(initial: AppState, allCategories: [Category] = MockCategories.all) {
        self.workingSelectedIDs = initial.selectedCategoryIDs
        self.workingEverything = initial.everythingSelected
        self.allCategories = allCategories
    }

    var grouped: [(descriptor: String, items: [Category])] {
        let filtered = allCategories.filter {
            searchText.isEmpty
            || $0.name.localizedCaseInsensitiveContains(searchText)
            || $0.descriptor.localizedCaseInsensitiveContains(searchText)
        }
        return Dictionary(grouping: filtered, by: { $0.descriptor })
            .map { (descriptor: $0.key, items: $0.value) }
            .sorted { $0.descriptor < $1.descriptor }
    }

    func tapEverything() {
        workingEverything = true
        workingSelectedIDs.removeAll()
    }

    func tapCategory(_ id: UUID) {
        workingEverything = false
        if workingSelectedIDs.contains(id) {
            workingSelectedIDs.remove(id)
        } else {
            workingSelectedIDs.insert(id)
        }
    }

    func apply(to state: AppState) {
        state.everythingSelected = workingEverything
        state.selectedCategoryIDs = workingEverything ? [] : workingSelectedIDs
    }
}
```

- [ ] **Step 2: Create `Features/CategoryFilter/CategoryFilterView.swift`**

```swift
import SwiftUI

struct CategoryFilterView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    @State private var viewModel: CategoryFilterViewModel?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.mfSurface.ignoresSafeArea()

                if let viewModel {
                    VStack(alignment: .leading, spacing: MFSpacing.lg) {
                        Text("Your palette")
                            .font(.mf(.headlineMD))
                            .foregroundStyle(Color.mfOnSurface)

                        TextField("Search categories", text: bindingForSearch(viewModel))
                            .font(.mf(.uiLabel))
                            .padding(MFSpacing.md)
                            .background(Color.mfSurfaceContainerLow)
                            .ghostBorderBottom()
                            .clipShape(RoundedRectangle(cornerRadius: MFRadius.md))

                        ScrollView {
                            VStack(spacing: MFSpacing.lg) {
                                CategoryChip(
                                    descriptor: "ALL",
                                    name: "Everything",
                                    isSelected: viewModel.workingEverything,
                                    action: { viewModel.tapEverything() }
                                )
                                ForEach(viewModel.grouped, id: \.descriptor) { group in
                                    VStack(alignment: .leading, spacing: MFSpacing.sm) {
                                        Text(group.descriptor)
                                            .mfTextStyle(.overline)
                                            .foregroundStyle(Color.mfOnSurfaceVariant)
                                        ForEach(group.items) { category in
                                            CategoryChip(
                                                descriptor: category.descriptor,
                                                name: category.name,
                                                isSelected: viewModel.workingSelectedIDs.contains(category.id),
                                                action: { viewModel.tapCategory(category.id) }
                                            )
                                        }
                                    }
                                }
                            }
                        }

                        PrimaryButton(title: "Apply", action: {
                            viewModel.apply(to: appState)
                            dismiss()
                        })
                    }
                    .padding(.horizontal, MFSpacing.xl)
                    .padding(.top, MFSpacing.xl)
                    .padding(.bottom, MFSpacing.xl)
                } else {
                    ProgressView()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.mfPrimary)
                }
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = CategoryFilterViewModel(initial: appState)
            }
        }
        .tint(Color.mfPrimary)
    }

    private func bindingForSearch(_ vm: CategoryFilterViewModel) -> Binding<String> {
        Binding(
            get: { vm.searchText },
            set: { vm.searchText = $0 }
        )
    }
}
```

- [ ] **Step 3: Build (still will fail — SettingsView missing)**

Run: `xcodebuild ... build -quiet`
Expected: build errors naming `SettingsView`. Do NOT commit yet — Task 20 finishes the chain.

---

## Task 20: SettingsView + view model

**Files:**
- Create: `Features/Settings/SettingsViewModel.swift`
- Create: `Features/Settings/SettingsView.swift`

- [ ] **Step 1: Create `Features/Settings/SettingsViewModel.swift`**

```swift
import Foundation

@MainActor
@Observable
final class SettingsViewModel {
    var showFilter: Bool = false
}
```

- [ ] **Step 2: Create `Features/Settings/SettingsView.swift`**

```swift
import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    @State private var viewModel = SettingsViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.mfSurface.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: MFSpacing.xl) {
                        section(title: "Ritual") {
                            ritualSection
                        }
                        section(title: "Palette") {
                            paletteSection
                        }
                        section(title: "Account") {
                            accountSection
                        }
                        section(title: "About") {
                            aboutSection
                        }
                    }
                    .padding(.horizontal, MFSpacing.xl)
                    .padding(.vertical, MFSpacing.xl)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Color.mfPrimary)
                }
            }
            .navigationDestination(isPresented: $viewModel.showFilter) {
                CategoryFilterView()
            }
        }
        .tint(Color.mfPrimary)
    }

    @ViewBuilder
    private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: MFSpacing.md) {
            Text(title)
                .mfTextStyle(.overline)
                .foregroundStyle(Color.mfOnSurfaceVariant)
            VStack(alignment: .leading, spacing: MFSpacing.md) {
                content()
            }
            .padding(MFSpacing.md)
            .background(Color.mfSurfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: MFRadius.lg))
        }
    }

    private var ritualSection: some View {
        @Bindable var appState = appState
        return VStack(alignment: .leading, spacing: MFSpacing.md) {
            DatePicker("Morning time", selection: $appState.morningTime, displayedComponents: .hourAndMinute)
                .font(.mf(.uiLabel))
            Toggle("Evening edition", isOn: $appState.eveningEnabled)
                .font(.mf(.uiLabel))
            if appState.eveningEnabled {
                DatePicker("Evening time", selection: $appState.eveningTime, displayedComponents: .hourAndMinute)
                    .font(.mf(.uiLabel))
            }
        }
    }

    private var paletteSection: some View {
        Button(action: { viewModel.showFilter = true }) {
            HStack {
                Text("Manage your palette").font(.mf(.uiLabel))
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(Color.mfOnSurfaceVariant)
            }
            .foregroundStyle(Color.mfOnSurface)
        }
    }

    @ViewBuilder
    private var accountSection: some View {
        // INTEGRATION(codex): wire restore purchases, sign out, delete account
        // per docs/architecture/auth-and-entitlements.md (App Store requires
        // in-app account deletion).
        VStack(alignment: .leading, spacing: MFSpacing.md) {
            placeholderRow("Restore purchases")
            placeholderRow("Sign out")
            placeholderRow("Delete account")
        }
    }

    @ViewBuilder
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: MFSpacing.md) {
            HStack {
                Text("Version").font(.mf(.uiLabel))
                Spacer()
                Text("0.1").font(.mf(.uiLabel)).foregroundStyle(Color.mfOnSurfaceVariant)
            }
            placeholderRow("Privacy")
            placeholderRow("Terms")
        }
    }

    private func placeholderRow(_ title: String) -> some View {
        HStack {
            Text(title).font(.mf(.uiLabel))
            Spacer()
            Image(systemName: "chevron.right").foregroundStyle(Color.mfOnSurfaceVariant)
        }
        .foregroundStyle(Color.mfOnSurface)
    }
}
```

- [ ] **Step 3: Build to verify**

Run: `xcodebuild ... build -quiet`
Expected: exit 0. The full chain compiles.

- [ ] **Step 4: Run the full app on simulator and verify**

Boot, launch. Walk: Splash → SignIn → all 6 onboarding steps → TodayView with FactCard. Tap gear → SettingsView with all four sections. Tap "Manage your palette" → CategoryFilterView pushed inside settings. Apply → returns to settings. From TodayView, tap filter affordance → CategoryFilterView as sheet. Apply → fact list re-loads with the new selection.

If any of these break, the bug is in the affected view or in the AppState bindings.

- [ ] **Step 5: Commit (single commit covers Tasks 18 + 19 + 20 since the build only goes green here)**

```bash
git add Features/Today/TodayView.swift Features/Today/TodayViewModel.swift \
        Features/CategoryFilter/CategoryFilterView.swift Features/CategoryFilter/CategoryFilterViewModel.swift \
        Features/Settings/SettingsView.swift Features/Settings/SettingsViewModel.swift
git commit -m "feat: add Today, CategoryFilter, and Settings views"
```

---

## Task 21: Archive and Paywall placeholder views

**Files:**
- Create: `Features/Archive/ArchiveView.swift`
- Create: `Features/Paywall/PaywallView.swift`

- [ ] **Step 1: Create `Features/Archive/ArchiveView.swift`**

```swift
import SwiftUI

// MARK: - INTEGRATION(codex): Wire to FactStore archive query, gated by tier
//   (last 7 days for free, full for premium) per docs/product/freemium-rules.md.
struct ArchiveView: View {
    var body: some View {
        ZStack {
            Color.mfSurface.ignoresSafeArea()
            VStack(alignment: .leading, spacing: MFSpacing.lg) {
                Text("Archive")
                    .font(.mf(.headlineMD))
                    .foregroundStyle(Color.mfOnSurface)
                Text("Design TBD — placeholder for Codex.")
                    .font(.mf(.uiLabel))
                    .foregroundStyle(Color.mfOnSurfaceVariant)

                VStack(spacing: MFSpacing.md) {
                    ForEach(0..<3) { _ in
                        RoundedRectangle(cornerRadius: MFRadius.lg)
                            .fill(Color.mfSurfaceContainerLow)
                            .frame(height: 80)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, MFSpacing.xl)
            .padding(.top, MFSpacing.xxl)
        }
    }
}
```

- [ ] **Step 2: Create `Features/Paywall/PaywallView.swift`**

```swift
import SwiftUI

// MARK: - INTEGRATION(codex): Wire to RevenueCat offerings, purchase, and restore flow.
//   Paywall is reachable from natural upgrade moments per docs/product/freemium-rules.md.
struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.mfSurface.ignoresSafeArea()
            VStack(spacing: MFSpacing.lg) {
                Spacer()
                Text("Premium")
                    .font(.mf(.headlineMD))
                    .foregroundStyle(Color.mfOnSurface)
                Text("Design TBD — placeholder for Codex.")
                    .font(.mf(.uiLabel))
                    .foregroundStyle(Color.mfOnSurfaceVariant)
                Spacer()
                VStack(spacing: MFSpacing.md) {
                    PrimaryButton(title: "Try Premium", action: { dismiss() })
                    SecondaryButton(title: "Maybe later", action: { dismiss() })
                }
                .padding(.horizontal, MFSpacing.xl)
                .padding(.bottom, MFSpacing.xl)
            }
        }
    }
}
```

- [ ] **Step 3: Build to verify**

Run: `xcodebuild ... build -quiet`
Expected: exit 0.

- [ ] **Step 4: Commit**

```bash
git add Features/Archive/ArchiveView.swift Features/Paywall/PaywallView.swift
git commit -m "feat: add Archive and Paywall placeholders"
```

---

## Task 22: README with Codex Integration Map

**Files:**
- Create: `README.md`

- [ ] **Step 1: Create `README.md`**

```markdown
# Morning Fax — iOS Scaffold

SwiftUI iOS-18+ core visual scaffold for the v1 Morning Fax app. It includes the full navigation graph, finished treatments for the primary Stitch-designed surfaces, and placeholders for unfinished screens. Mock data only — no backend, no persistence, no real notifications, no real auth. Codex picks this up and replaces the marked seams with real Supabase, RevenueCat, and notification implementations per the foundation spec at `docs/superpowers/specs/2026-04-24-morning-fax-technical-foundation-design.md`.

## Run it

```bash
brew install xcodegen
xcodegen generate
open MorningFax.xcodeproj
```

Pick any iPhone simulator running iOS 18+.

## Architecture

Pragmatic SwiftUI. One `@Observable` `AppState` injected at the root via `.environment(_:)` carries cross-screen state. Per-screen `@Observable` view models exist only where a screen has non-trivial state (`Today`, `Onboarding/Categories`, `CategoryFilter`, `Settings`). All foundation-spec services exist as protocols in `Core/` with `Mock` implementations. Design tokens centralized in `Core/DesignSystem/`. AppState resets on relaunch — persistence is a Codex responsibility.

## Codex Integration Map

| Concern | Current (mock) | Replace with |
| --- | --- | --- |
| Auth | `MockAuthService` (always-on signIn) | Sign in with Apple → Supabase Auth |
| Entitlements | `MockEntitlementService` (`.free` hardcoded) | RevenueCat → `user_entitlements` snapshot |
| Fact source | `MockFactStore` (12 static seeded facts) | `FactRepository` → Supabase `facts` |
| Notifications | `MockNotificationService` (logs only) | `UNUserNotificationCenter` scheduling |
| Persistence | none | UserDefaults / SwiftData / server-backed |
| Share image | text fallback in `FactCard.onShare` | `ImageRenderer` → `UIActivityViewController` |
| Paywall | `PaywallView` placeholder | RevenueCat offerings + purchase flow |
| Archive | `ArchiveView` placeholder | Tier-gated query against `facts` |
| Deep links | none | `onOpenURL` + `UNNotificationContent` handlers in `AppRouter` |

Grep target for every seam: `INTEGRATION(codex)`. Single search produces the full handoff surface.

## Design system rules (do not violate)

1. **No 1pt solid borders for sectioning.** Use tonal surface shifts or `.ghostBorder()`.
2. **No `Color.black`.** Use `Color.mfOnSurface` (`#2D3432`).
3. **No system shadows.** Use `.sunkenShadow()`.
4. **All fonts come through `Font.mf(_:)` or `.mfTextStyle(_:)`.** Never `.system(.title)`.
5. **All spacing comes from `MFSpacing`.** No magic CGFloat literals.

## Where Codex extends, by folder

- New repositories → create `Domain/Repositories/`
- New persistence → create `App/Persistence/`
- New tests → create `Tests/`

Do NOT edit files in `Core/DesignSystem/Components/` without updating the Brand Guideline reference (Stitch project `3459311465286439458`, "Morning Fax Brand Guideline" screen).

## What is not yet wired

- Real Sign in with Apple
- Real Supabase fetches
- RevenueCat purchases
- `UNUserNotificationCenter` scheduling
- Persistence
- Share image rendering
- Deep linking and notification deep links
- Analytics
- Final designs for `SignInView`, `WelcomeView`, `PremiumOfferView`, `NotificationPermissionView`, `ArchiveView`, `PaywallView`
- Tests

Each carries an `INTEGRATION(codex)` or `TODO(codex)` marker in the relevant file.
```

- [ ] **Step 2: Build (sanity)**

Run: `xcodebuild ... build -quiet`
Expected: exit 0.

- [ ] **Step 3: Commit**

```bash
git add README.md
git commit -m "docs: add Codex Integration Map README"
```

---

## Final verification (no commit)

- [ ] **Step 1: Walk the app end-to-end on simulator**

Splash → SignIn → Welcome → MorningTime → EveningEdition → Categories (toggle a few) → PremiumOffer → NotificationPermission → TodayView (FactCard renders, swipe vertically through facts).

From TodayView: gear → SettingsView, all sections present. Settings → "Manage your palette" → CategoryFilterView push. Filter affordance from TodayView → CategoryFilterView sheet. Apply with new selection → fact list reloads.

- [ ] **Step 2: Grep verification**

```bash
grep -r "INTEGRATION(codex)" --include="*.swift" .
```
Expected: at least 9 hits (Auth, Entitlements, Notifications, Persistence, Sharing, Supabase, AppState, AppRouter, MockFactStore — and any placeholder views).

- [ ] **Step 3: Confirm build is clean**

```bash
xcodebuild -scheme MorningFax -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16' clean build -quiet
```
Expected: exit 0, no warnings about missing fonts or unresolved symbols.

The scaffold is complete. Hand the repo to Codex for integration.
