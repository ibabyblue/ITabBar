# Choosing a Component

Select the ownership model before choosing visual details.

## Use ITabBar for a Custom Surface

Choose ``ITabBar`` when the tab bar must provide any of these capabilities:

- Plain, concave, or convex custom geometry
- A center floating action button
- Consumer-supplied SwiftUI item views
- Custom colors, materials, fonts, dimensions, spacing, badges, or curves
- Built-in or custom item animations
- Selected-tab long-press callbacks
- iOS 17, iOS 18, or macOS 14 deployment

SwiftUI owns the complete surface, interaction recognition, selected content, and bottom safe-area coverage.

## Use ILiquidTabBar for the Native Surface

Choose ``ILiquidTabBar`` when the app runs on iOS 26 and the system Liquid Glass interaction is more important than custom geometry. The component creates real `UITabBarItem` values in a `UITabBarController`; UIKit owns the selection lens, transitions, and minimization.

The native surface supports SF Symbol names, selected symbol names, titles, badges, dynamic tabs, programmatic selection, same-tab double taps, and ``ILiquidTabBarMinimizeBehavior``. It does not expose custom SwiftUI item views, curved backgrounds, center actions, per-item animations, or long-press callbacks.

## Do Not Switch Implicitly

The two components do not form a fallback pair. ``ILiquidTabBar`` has no pre-iOS 26 implementation, and ``ITabBar`` does not imitate the system Liquid Glass hierarchy. Choose explicitly at an availability boundary in your application.
