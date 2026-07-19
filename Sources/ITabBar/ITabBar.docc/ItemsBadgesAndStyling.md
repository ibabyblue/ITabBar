# Items, Badges, and Styling

Use the default item template for SF Symbols and titles, or supply a complete SwiftUI item hierarchy.

## Configure Default Items

``ITabBarItemConfig`` selects an unselected symbol, optional selected symbol, title, animation, and badge. When `selectedIcon` is `nil`, the unselected symbol is reused. Badge text longer than three characters is truncated to its first three extended grapheme clusters.

``ITabBarStyle`` controls selected and unselected colors and fonts, background fill, height, item spacing, badge appearance, center button appearance, and curve geometry. A non-`nil` `backgroundColor` takes precedence over `backgroundMaterial`.

## Build Custom Items

Use the custom initializer when the entire item hierarchy belongs to the application:

```swift
ITabBar(tabs: tabs, selection: $selection) { tab in
    page(for: tab)
} tabItem: { tab, isSelected in
    HStack(spacing: 6) {
        Image(systemName: tab.icon)
        Text(tab.title)
    }
    .foregroundStyle(isSelected ? .white : .secondary)
    .padding(.horizontal, 12)
    .frame(height: 36)
    .background(isSelected ? Color.indigo : Color.clear, in: Capsule())
}
```

The bar gives every item an equal-width slot. Custom item content should remain compact enough for the number of tabs and supported localizations.
