# ITabBar

ITabBar provides two focused SwiftUI tab containers: a fully customizable tab bar for iOS 17 and macOS 14, and a native iOS 26 tab bar whose Liquid Glass appearance is managed by UIKit.

![iOS 17+](https://img.shields.io/badge/iOS-17%2B-blue)
![macOS 14+](https://img.shields.io/badge/macOS-14%2B-blue)
![Swift 6.0](https://img.shields.io/badge/Swift-6.0%2B-orange)
![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen)
![Version](https://img.shields.io/badge/version-0.3.0-blueviolet)
![License](https://img.shields.io/badge/license-MIT-lightgrey)

## Choose a Component

| Component | Availability | Best for |
|---|---|---|
| `ITabBar` | iOS 17+, macOS 14+ | Custom shapes, center actions, styles, item views, and animations |
| `ILiquidTabBar` | iOS 26+ with Swift 6.2+ | A native `UITabBarController` experience with system Liquid Glass and minimization |

The package has no external dependencies. The Example app depends on Lottie only to demonstrate custom replayable content.

## Features

- Plain, concave, and convex custom tab bar shapes
- Optional center action button for curved shapes
- Default SF Symbol items or a fully custom SwiftUI item builder
- Badges, colors, materials, typography, sizing, spacing, and curve configuration
- Bounce, wiggle, pop, disabled, and custom per-item animations
- Replayable active content through `ITabBarTapPlayView`
- Immediate single selection, same-tab double taps, and selected-tab long presses
- Dynamic tab insertion, removal, reordering, and automatic selection correction
- Native iOS 26 tab items, badges, dynamic tabs, double taps, and minimize behavior

## Requirements

| Component | Platform | Swift | Xcode |
|---|---|---|---|
| `ITabBar` | iOS 17+, macOS 14+ | 6.0+ | 16.0+ |
| `ILiquidTabBar` | iOS 26+ | 6.2+ | 26.0+ |

## Installation

In Xcode, choose **File → Add Package Dependencies** and enter the repository URL.

To add ITabBar in `Package.swift`, declare the package dependency:

```swift
dependencies: [
    .package(url: "https://github.com/ibabyblue/ITabBar.git", from: "0.3.0")
]
```

Then add the product to your target:

```swift
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            .product(name: "ITabBar", package: "ITabBar")
        ]
    )
]
```

## ITabBar Quick Start

```swift
import ITabBar
import SwiftUI

enum AppTab: String, CaseIterable, Hashable {
    case home, explore, messages, profile
}

struct RootView: View {
    @State private var selection: AppTab = .home

    private let items: [AppTab: ITabBarItemConfig] = [
        .home: .init(icon: "house", selectedIcon: "house.fill", title: "Home"),
        .explore: .init(icon: "safari", selectedIcon: "safari.fill", title: "Explore"),
        .messages: .init(icon: "message", selectedIcon: "message.fill", title: "Messages", badge: "3"),
        .profile: .init(icon: "person", selectedIcon: "person.fill", title: "Profile")
    ]

    var body: some View {
        ITabBar(
            tabs: AppTab.allCases,
            selection: $selection,
            shape: .concave,
            configs: items,
            onCenterTap: { print("Create item") }
        ) { tab in
            Text(tab.rawValue.capitalized)
        }
        .onTabDoubleTap { tab in
            print("Scroll \(tab) to top")
        }
        .onTabLongPress { tab in
            print("Show actions for \(tab)")
        }
    }
}
```

`selection` remains caller-owned. When a nonempty `tabs` collection no longer contains the selected identity, ITabBar writes the first tab back to the binding. Empty collections render no selected content and leave the binding unchanged.

## Native Liquid Glass

Use `ILiquidTabBar` only when the app deploys on iOS 26 or later and wants the system-owned tab bar surface:

```swift
@available(iOS 26.0, *)
struct NativeTabs: View {
    @State private var selection: AppTab = .home

    var body: some View {
        ILiquidTabBar(
            tabs: AppTab.allCases,
            selection: $selection,
            configs: [
                .home: .init(icon: "house", selectedIcon: "house.fill", title: "Home"),
                .explore: .init(icon: "safari", selectedIcon: "safari.fill", title: "Explore"),
                .messages: .init(icon: "message", title: "Messages", badge: "3"),
                .profile: .init(icon: "person", title: "Profile")
            ],
            minimizeBehavior: .onScrollDown
        ) { tab in
            Text(tab.rawValue.capitalized)
        }
        .onTabDoubleTap { tab in
            print("Scroll \(tab) to top")
        }
    }
}
```

The native component intentionally does not provide custom item views, custom animations, curved backgrounds, a center button, or long-press callbacks. Those capabilities belong to `ITabBar`.

## Documentation

- [DocC catalog](Sources/ITabBar/ITabBar.docc/ITabBar.md) — component selection, setup, styling, interactions, animations, native integration, and platform behavior
- [Example application](Example/README.md) — ten runnable scenarios and UI-test instructions
- [Changelog](CHANGELOG.md) — release history and migration notes
- Generated symbol documentation is available by building the `ITabBar` DocC catalog in Xcode.

## Example

Open `Example/ITabBarDemo.xcodeproj`, select the shared `ITabBarDemo` scheme, and run an iOS simulator. The catalog includes basic, interaction, shape, dynamic-tab, custom-style, custom-item, built-in-animation, Lottie, and native iOS 26 integrations.

Regenerate the project after changing its structure:

```bash
xcodegen generate --spec Example/project.yml --project Example
```

## License

ITabBar is available under the MIT license. See [LICENSE](LICENSE).
