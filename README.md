# ITabBar

A custom tab bar component for iOS 17+. Three shape styles (plain, concave water-drop, convex dome), built-in animations, FAB center button, badge support, and double-tap / long-press callbacks. Pure SwiftUI, zero third-party dependencies.

![iOS 17+](https://img.shields.io/badge/iOS-17%2B-blue)
![Swift 6.0](https://img.shields.io/badge/Swift-6.0%2B-orange)
![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen)
![License](https://img.shields.io/badge/license-MIT-lightgrey)

## Features

- **Three shapes** — plain flat, concave water-drop notch, convex dome with enclosed FAB
- **Built-in animations** — bounce, wiggle, pop, or fully custom per tab item
- **FAB center button** — optional center action button for concave / convex styles
- **Badge support** — numeric or text badge on any tab
- **Gesture callbacks** — double-tap and long-press per tab via `.onTabDoubleTap` / `.onTabLongPress`
- **Flexible tab items** — default icon+label template or fully custom `ViewBuilder`
- **Background modes** — solid color, blur material, iOS 26+ liquid glass

## Requirements

| | Minimum |
|---|---|
| iOS | 17.0 |
| Swift | 6.0 |
| Xcode | 16.0 |

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/ibabyblue/ITabBar", from: "0.0.1")
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
| `.concave` | Top edge dips at center (water-drop notch), FAB floats above |
| `.convex` | Top edge rises at center (dome), FAB enclosed inside dome |

## Custom Style

```swift
var style: ITabBarStyle {
    var s = ITabBarStyle()
    s.selectedColor   = .orange
    s.fabColor        = .orange
    s.height          = 60
    s.fabSize         = 56
    s.curveRadius     = 32
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
ITabBarItemConfig(
    icon: "star",
    selectedIcon: "star.fill",
    title: "Favorites",
    animation: .wiggle   // .bounce | .wiggle | .pop | .none | .custom(...)
)
```

## Edge-Case Behavior

| Scenario | Behavior |
|---|---|
| `tabs` is empty | Renders blank, no crash |
| `selection` not in `tabs` | Corrected to `tabs.first` automatically |
| `onCenterTap` is nil | FAB renders but taps are no-ops |
| badge text > 3 chars | Truncated to 3 characters |
| `useLiquidGlass` on iOS < 26 | Silent fallback to `backgroundMaterial` |

## Demo

Open `demo/ITabBarDemo.xcodeproj`, select a simulator and run. Covers four scenarios:

- **Plain** — flat tab bar, badges, double-tap / long-press callbacks
- **Concave** — water-drop notch, FAB callback
- **Convex** — dome style, FAB enclosed inside
- **Animations** — all built-in animation presets side by side

## License

ITabBar is available under the MIT license. See the [LICENSE](LICENSE) file for details.
