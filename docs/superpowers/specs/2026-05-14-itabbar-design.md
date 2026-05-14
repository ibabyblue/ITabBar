# ITabBar Design Spec

**Date:** 2026-05-14
**Package:** ITabBar
**Platform:** iOS 17+
**Approach:** Pure SwiftUI, zero UIKit, zero third-party dependencies

---

## Overview

A custom TabBar SPM package. Provides three shape styles (concave water-drop, convex dome, plain flat), built-in tab item animations, FAB center button, double-tap / long-press callbacks, badge support, and three background modes (solid color, blur material, iOS 26+ liquid glass).

---

## 1. Architecture

```
ITabBar (public View)
├── ITabBarStyle          — appearance configuration
├── ITabBarShape          — .concave / .convex / .plain
├── ITabBarItemConfig     — per-tab configuration (icon, title, animation, badge)
├── ITabBarAnimation      — .bounce / .wiggle / .pop / .none / .custom
│
└── Internal/
    ├── _TabBarBackground — draws the Path shape + applies background material
    ├── _TabBarItem       — single tab item (default icon+label or custom View)
    └── _FABButton        — center + button (concave / convex only)
```

**Data flow:**
- Caller owns selection state via `@Binding<Tab>`. ITabBar holds no selection state internally.
- Gestures (tap / double-tap / long-press) fire callbacks to caller; ITabBar makes no routing decisions.
- Animations are driven inside `_TabBarItem` via `withAnimation`; not exposed to callers.

---

## 2. Public API

### ITabBar

```swift
public struct ITabBar<Tab: Hashable, Content: View, TabItemView: View>: View {
    public init(
        tabs: [Tab],
        selection: Binding<Tab>,
        shape: ITabBarShape = .plain,
        style: ITabBarStyle = .init(),
        onCenterTap: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (Tab) -> Content,
        @ViewBuilder tabItem: @escaping (Tab, Bool) -> TabItemView  // (tab, isSelected)
    )
}

// Convenience init using default icon+label template
public extension ITabBar where TabItemView == _DefaultTabItemView {
    init(
        tabs: [Tab],
        selection: Binding<Tab>,
        shape: ITabBarShape = .plain,
        style: ITabBarStyle = .init(),
        configs: [Tab: ITabBarItemConfig],
        onCenterTap: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (Tab) -> Content
    )
}
```

### ITabBarShape

```swift
public enum ITabBarShape {
    case plain             // flat top edge, no FAB
    case concave           // center top edge dips down (water-drop notch), FAB floats above
    case convex            // center top edge rises up (dome), FAB enclosed inside dome
}
```

### ITabBarItemConfig

```swift
public struct ITabBarItemConfig {
    public var icon: String                        // SF Symbol name (unselected)
    public var selectedIcon: String?               // nil → same icon, color distinguishes
    public var title: String
    public var animation: ITabBarAnimation = .bounce
    public var badge: String? = nil                // nil → no badge; truncated at 3 chars
}
```

### ITabBarAnimation

```swift
public enum ITabBarAnimation {
    case bounce   // scaleEffect 1.0 → 1.3 → 1.0, spring(duration: 0.3)
    case wiggle   // rotationEffect -15° → +15° → 0°, two frames
    case pop      // scaleEffect 1.0 → 1.4 → 1.0, interpolatingSpring
    case none     // icon/color swap only, no motion
    case custom((Bool) -> AnyView)  // caller supplies view; isSelected drives it
}
```

### ViewModifier callbacks

```swift
ITabBar(...)
    .onTabDoubleTap { tab in ... }
    .onTabLongPress { tab in ... }
```

### ITabBarStyle

```swift
public struct ITabBarStyle {
    // Tab item
    public var selectedColor: Color       = .primary
    public var unselectedColor: Color     = .secondary
    public var selectedFont: Font         = .system(size: 10, weight: .medium)
    public var unselectedFont: Font       = .system(size: 10, weight: .regular)

    // Background (priority: liquidGlass > backgroundColor > backgroundMaterial)
    public var backgroundColor: Color?    = nil
    public var backgroundMaterial: Material = .ultraThinMaterial
    public var useLiquidGlass: Bool       = false  // iOS 26+ only; silently falls back on older OS

    // Dimensions
    public var height: CGFloat            = 56     // TabBar height, excluding dome overhang
    public var fabSize: CGFloat           = 52     // FAB button diameter
    public var fabColor: Color            = .blue
    public var itemSpacing: CGFloat       = 0      // 0 = distribute evenly

    // Badge
    public var badgeColor: Color          = .red
    public var badgeFont: Font            = .system(size: 10, weight: .bold)

    // Shape curve (advanced)
    public var curveRadius: CGFloat       = 28     // arc radius for concave/convex curve
}
```

---

## 3. Shape Drawing

All three shapes are described as SwiftUI `Path` inside `_TabBarBackground`. The concave/convex arc dimensions are derived from `style.fabSize` and `style.curveRadius` so the arc always fits the FAB precisely.

```
Plain:    ┌────────────────────────────┐
          │                            │

Concave:  ┌─────────╮       ╭─────────┐
          │          ╰──v──╯           │  ← arc bottom = fabSize/2 + margin

Convex:   │          ╭──^──╮           │
          └─────────╯       ╰─────────┘  ← arc top = fabSize/2 + margin
                                          FAB enclosed inside dome
```

The convex dome overhangs above the TabBar top edge. The `ZStack` overlay carrying `_FABButton` uses `allowsHitTesting(true)` with `.clipped(false)` so the hit target is correct.

---

## 4. Animations

Animations fire once on tap-select. Double-tap and long-press only fire callbacks; no built-in animation beyond what the caller adds.

| Preset | Implementation |
|---|---|
| `.bounce` | `scaleEffect` 1.0 → 1.3 → 1.0 with `spring(duration: 0.3)` |
| `.wiggle` | `rotationEffect` -15° → +15° → 0° across two animation phases |
| `.pop` | `scaleEffect` 1.0 → 1.4 → 1.0 with `interpolatingSpring` |
| `.none` | icon/color swap only |
| `.custom` | caller provides `(Bool) -> AnyView`; triggered when `isSelected` changes |

**Gesture priority:** long press (0.5 s threshold) > double tap > single tap, using `.simultaneousGesture` + `LongPressGesture.sequenced` to avoid conflicts.

---

## 5. Background Modes

| Condition | Result |
|---|---|
| `useLiquidGlass == true` && iOS 26+ | `.glassEffect()` or equivalent liquid glass API |
| `useLiquidGlass == true` && iOS < 26 | silently falls back to `backgroundMaterial` |
| `backgroundColor != nil` | solid `Color` fill |
| default | `backgroundMaterial` (`.ultraThinMaterial`) |

---

## 6. Edge-Case Behavior

| Scenario | Behavior |
|---|---|
| `tabs` is empty | renders blank, no crash |
| `tabs.count == 1` | single tab shown, no switching |
| `selection` not in `tabs` | corrected to `tabs.first` automatically |
| `tabs` replaced at runtime | selection snaps to nearest valid tab |
| `onCenterTap` is nil, shape is concave/convex | FAB renders but taps are no-ops |
| custom `tabItem` closure provided | default icon+label template not used |
| badge text > 3 chars | truncated, layout not broken |
| landscape orientation | TabBar height unchanged, safe area handled automatically |
| `useLiquidGlass` on iOS < 26 | silent fallback, no warning, no crash |

---

## 7. Testing

- **Unit tests:** `validatedSelection` boundary logic, `ITabBarStyle` default values, badge truncation
- **Shape tests:** verify key Path coordinate points for concave/convex arcs
- **Demo app:** covers all three shapes × default / custom tabItem × all animation presets × badge × double-tap / long-press callbacks

---

## 8. File Structure

```
Sources/ITabBar/
├── ITabBar.swift               — public entry point
├── ITabBarShape.swift          — shape enum
├── ITabBarStyle.swift          — style config struct
├── ITabBarItemConfig.swift     — per-tab config struct
├── ITabBarAnimation.swift      — animation enum
├── ITabBarViewModifiers.swift  — .onTabDoubleTap / .onTabLongPress
└── Internal/
    ├── _TabBarBackground.swift
    ├── _TabBarItem.swift
    ├── _FABButton.swift
    └── _SelectionHelpers.swift

Tests/ITabBarTests/
└── ITabBarTests.swift

demo/ITabBarDemo/
└── (Xcode project — BasicDemo, ConvexDemo, ConcaveDemo, AnimationDemo)
```

---

## Out of Scope

- Vertical tab bar
- Tab reorder
- macOS / tvOS / watchOS
- Built-in page transition animations (caller manages page content)
