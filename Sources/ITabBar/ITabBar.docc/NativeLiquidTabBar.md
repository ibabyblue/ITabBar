# Native Liquid Tab Bar

Adopt the system-owned iOS 26 tab bar when native Liquid Glass behavior is required.

## Availability

``ILiquidTabBar`` is compiled only for iOS with a Swift 6.2 or newer compiler and is available on iOS 26 or later. Guard its use at your application boundary; the package does not provide an older-system fallback.

## Configure Native Items

```swift
@available(iOS 26.0, *)
struct NativeRoot: View {
    @State private var selection = AppTab.home

    var body: some View {
        ILiquidTabBar(
            tabs: AppTab.allCases,
            selection: $selection,
            configs: [
                .home: .init(icon: "house", selectedIcon: "house.fill", title: "Home"),
                .search: .init(icon: "magnifyingglass", title: "Search"),
                .inbox: .init(icon: "tray", selectedIcon: "tray.fill", title: "Inbox", badge: "3"),
                .profile: .init(icon: "person", selectedIcon: "person.fill", title: "Profile")
            ],
            minimizeBehavior: .onScrollDown
        ) { tab in
            page(for: tab)
        }
    }
}
```

The bridge retains hosting controllers for unchanged tab identities, updates their SwiftUI root views, removes obsolete controllers, and preserves the selected identity through reordering. Missing configurations use a question-mark symbol and empty title.

## Minimize While Scrolling

``ILiquidTabBarMinimizeBehavior`` maps directly to UIKit's iOS 26 minimization policies. The system determines how scrolling content participates; ITabBar does not inspect or modify private UIKit hierarchy.

Programmatic synchronization does not count as a user selection for double-tap recognition. Two user selections of the same native tab within 0.3 seconds invoke `onTabDoubleTap` when installed.
