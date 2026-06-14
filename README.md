# ITabBar

A custom tab bar component for iOS 17+. Three shape styles (plain, concave water-drop, convex dome), built-in animations, FAB center button, badge support, and zero-delay single/double-tap & long-press callbacks. Pure SwiftUI, zero third-party dependencies.

![iOS 17+](https://img.shields.io/badge/iOS-17%2B-blue)
![Swift 6.0](https://img.shields.io/badge/Swift-6.0%2B-orange)
![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen)
![License](https://img.shields.io/badge/license-MIT-lightgrey)

## Features

- **Three shapes** — plain flat, concave water-drop notch, convex dome whose top edge wraps the FAB at a fixed gap
- **Built-in animations** — bounce, wiggle, pop, none, or fully custom per tab item via `ITabBarAnimationContext`
- **Tap-driven view container** — `ITabBarTapPlayView` swaps a default view for an active view (Lottie, SwiftUI animation, video frames) on every tap and snaps back automatically
- **FAB center button** — optional center action button for concave / convex styles
- **Badge support** — numeric or text badge on any tab
- **Zero-delay tap** — single tap fires immediately, double tap arrives as an additional event (mirrors UIKit's `touchDown` + `touchDownRepeat`), so registering a double-tap handler doesn't slow down single taps
- **Long-press callback** — per-tab long-press recognition with default 0.5s threshold
- **Equal-width items** — tabs always distribute evenly across the bar regardless of item content width
- **Flexible tab items** — default icon + label template or fully custom `ViewBuilder`
- **Background modes** — solid color, blur material, iOS 26+ liquid glass

## Requirements

| | Minimum |
|---|---|
| iOS | 17.0 |
| Swift | 6.0 |
| Xcode | 16.0 |

## Installation

### Swift Package Manager

In Xcode choose **File → Add Package Dependencies**, enter the repository URL, or add to `Package.swift` directly:

```swift
dependencies: [
    .package(url: "https://github.com/ibabyblue/ITabBar", from: "0.1.1")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            .product(name: "ITabBar", package: "ITabBar")
        ]
    )
]
```

## Quick Start

```swift
import ITabBar

enum Tab: String, CaseIterable, Hashable {
    case home, explore, messages, profile
}

struct ContentView: View {
    @State private var selection: Tab = .home

    var body: some View {
        ITabBar(
            tabs: Tab.allCases,
            selection: $selection,
            shape: .concave,
            configs: [
                .home:     ITabBarItemConfig(icon: "house",           title: "Home"),
                .explore:  ITabBarItemConfig(icon: "magnifyingglass", title: "Explore"),
                .messages: ITabBarItemConfig(icon: "message",         title: "Messages", badge: "3"),
                .profile:  ITabBarItemConfig(icon: "person",          title: "Profile"),
            ],
            onCenterTap: { print("FAB tapped") }
        ) { tab in
            Text(tab.rawValue)
        }
        .onTabDoubleTap { tab in print("double tap: \(tab)") }
        .onTabLongPress { tab in print("long press: \(tab)") }
    }
}
```

## Shapes

| Style | Description |
|---|---|
| `.plain` | Flat top edge, no FAB |
| `.concave` | Top edge dips at center (water-drop notch); FAB floats above the notch |
| `.convex` | Top edge wraps the FAB with a circular arc concentric to it (gap = `fabGap`); two smooth cubic shoulders connect the wrap arc back to the flat bar edge |

## Custom Style

```swift
var style: ITabBarStyle {
    var s = ITabBarStyle()
    s.selectedColor      = .orange
    s.fabColor           = .orange
    s.height             = 60
    s.fabSize            = 56
    s.fabGap             = 8
    s.curveRadius        = 32
    s.convexProtrusion   = 15   // FAB top above bar top in convex mode
    return s
}
```

## Custom Tab Item

```swift
ITabBar(
    tabs: tabs,
    selection: $selection,
    shape: .plain
) { tab in
    pageView(tab)
} tabItem: { tab, isSelected in
    MyCustomTabItem(tab: tab, isSelected: isSelected)
}
```

## Animations

```swift
// Built-in presets
ITabBarItemConfig(
    icon: "star",
    selectedIcon: "star.fill",
    title: "Favorites",
    animation: .wiggle   // .bounce | .wiggle | .pop | .none | .custom(...)
)

// Fully custom — receives ITabBarAnimationContext (isSelected + tapTrigger)
ITabBarItemConfig(
    icon: "star",
    title: "Favorites",
    animation: .custom { ctx in
        AnyView(
            Image(systemName: ctx.isSelected ? "star.fill" : "star")
                .symbolEffect(.bounce, value: ctx.tapTrigger)
        )
    }
)
```

`ctx.tapTrigger` flips on every tap on this tab — including re-taps of the currently-selected tab — so animations driven by `.onChange(of:)` or `.id(...)` reliably replay.

## Tap-Driven View (Lottie / replay-on-tap animations)

`ITabBarTapPlayView` is a drop-in container for `.custom { ... }` that handles the full lifecycle of "show default, swap to active on tap, snap back after a duration, cancel on tab switch, restart on re-tap":

```swift
import Lottie

animation: .custom { ctx in
    AnyView(
        ITabBarTapPlayView(
            context: ctx,
            duration: LottieAnimation.named("heart")?.duration ?? 1.0
        ) {
            // Default view — shown at rest
            Image(systemName: "heart")
        } active: {
            // Active view — mounted on tap, internally restarted on every re-tap
            // via SwiftUI identity (the container applies `.id(ctx.tapTrigger)`)
            if let animation = LottieAnimation.named("heart") {
                LottieView(animation: animation)
                    .resizable()
                    .playbackMode(.playing(.fromProgress(0, toProgress: 1, loopMode: .playOnce)))
            }
        }
    )
}
```

Behavior handled internally:

- On tap → mounts the active view; auto-reverts after `duration` seconds.
- On re-tap of the same tab → restarts the active view from scratch (changes its SwiftUI identity).
- On switching to another tab → cancels the in-flight playback immediately and reverts to the default view.

Works with any view (Lottie, `Image` + `symbolEffect`, custom `withAnimation` blocks, video frame sequences) — no Lottie dependency in the library itself.

## Edge-Case Behavior

| Scenario | Behavior |
|---|---|
| `tabs` is empty | Renders blank, no crash |
| `selection` not in `tabs` | Corrected to `tabs.first` automatically |
| `onCenterTap` is nil | FAB renders but taps are no-ops |
| Badge text > 3 chars | Truncated to 3 characters |
| `useLiquidGlass` on iOS < 26 | Silent fallback to `backgroundMaterial` |
| Single tap with no double-tap handler | Fires immediately, no detection delay |
| Single tap with double-tap handler | Fires immediately; second tap within 0.3s becomes the double-tap event |
| Long press (≥ 0.5s) | Fires `onLongPress`; resets any in-flight double-tap timing |

## Demo

Open `demo/ITabBarDemo.xcodeproj`, select a simulator and run. Covers five scenarios:

- **Plain** — flat tab bar with badges, double-tap / long-press callbacks
- **Concave** — water-drop notch with FAB; live slider panel for tuning `fabGap` / `fabSize` / `curveRadius`
- **Convex** — wrap-arc dome with FAB; live slider panel for tuning `fabGap` / `convexProtrusion` / `fabSize` / `curveRadius`
- **Animations** — all built-in animation presets side by side
- **Lottie Animation** — `ITabBarTapPlayView` swapping SF Symbol → Lottie on tap, using bundled airbnb/lottie samples

## Design Notes

- **Convex geometry** — the dome is composed of three segments per side: a flat top, a cubic shoulder, and a circular wrap arc concentric with the FAB (radius = `fabRadius + fabGap`). The cubic shoulder's end tangent is matched analytically to the wrap arc's traversal direction, so shoulder→wrap is curvature-continuous (no visible joint).
- **Tap recognition** — `_TabBarItem` runs a `TapGesture(count: 1)` combined exclusively with a long-press recognizer. Double-tap is detected via a manual timestamp check (`lastTapTime`) so the single-tap path never waits on a double-tap window — single taps always fire on touch-up without delay. This mirrors UIKit's `touchDown` + `touchDownRepeat` event split.
- **Replay trigger** — every `_TabBarItem` owns a `@State Bool animKey` that toggles on tap (and on becoming selected). Built-in animations key off it via `keyframeAnimator(trigger:)`, and custom builders receive it as `ITabBarAnimationContext.tapTrigger`. Consumers can apply `.id(ctx.tapTrigger)` to force a child view to reset its internal animation state on every tap.
- **Equal-width distribution** — each item carries `.frame(maxWidth: .infinity)`, so the `HStack` always assigns equal slots regardless of intrinsic content width (icon + label vs. a custom Lottie view).

## Out of Scope

- Drag-to-reorder tabs
- Scrollable / overflow tab strip (see `ITabPager` for that pattern)
- macOS / tvOS / watchOS

## License

ITabBar is available under the MIT license. See the [LICENSE](LICENSE) file for details.
