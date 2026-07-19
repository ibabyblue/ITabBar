# Standard Tab Bar Quick Start

Create a custom tab container with stable identities, a caller-owned selection, item configurations, and a selected-content builder.

## Define Stable Tabs

```swift
import ITabBar
import SwiftUI

enum AppTab: String, CaseIterable, Hashable {
    case home, search, inbox, profile
}
```

The `Hashable` value is the tab's identity. Keep it stable across insertions and reordering.

## Configure and Present Items

```swift
struct RootView: View {
    @State private var selection: AppTab = .home

    private let items: [AppTab: ITabBarItemConfig] = [
        .home: .init(icon: "house", selectedIcon: "house.fill", title: "Home"),
        .search: .init(icon: "magnifyingglass", title: "Search"),
        .inbox: .init(icon: "tray", selectedIcon: "tray.fill", title: "Inbox", badge: "12"),
        .profile: .init(icon: "person", selectedIcon: "person.fill", title: "Profile")
    ]

    var body: some View {
        ITabBar(
            tabs: AppTab.allCases,
            selection: $selection,
            configs: items
        ) { tab in
            Text(tab.rawValue.capitalized)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
```

The default initializer renders ``ITabBarDefaultItemView`` for each tab. A missing configuration uses a question-mark icon and empty title instead of failing.

## Selection Ownership

The binding is the source of truth. User taps and automatic correction write into it. Programmatic binding changes select the corresponding tab. If `tabs` becomes empty, the component presents no selected page and leaves the binding unchanged.
