# ``ITabBar``

Build custom SwiftUI tab bars or adopt the system-owned iOS 26 Liquid Glass tab bar.

## Overview

ITabBar contains two deliberately separate components:

- ``ITabBar`` renders a SwiftUI-owned tab bar with custom shapes, styles, item views, center actions, gestures, and animations on iOS 17 and macOS 14.
- ``ILiquidTabBar`` bridges to `UITabBarController` on iOS 26 so UIKit owns the native Liquid Glass appearance, transitions, and minimize behavior.

Both components use caller-owned selection bindings and stable `Hashable` tab identities. When a nonempty tab collection no longer contains the selected identity, the component writes the first tab back to the binding. Empty collections remain valid and do not mutate selection.

Start with <doc:ChoosingAComponent>, then follow the guide for the component that matches your product requirements. Run the repository's `Example` application for complete integrations.

## Topics

### Essentials

- <doc:ChoosingAComponent>
- <doc:StandardTabBarQuickStart>
- <doc:PlatformBehavior>

### Custom Tab Bar

- <doc:ShapesFABAndLayout>
- <doc:ItemsBadgesAndStyling>
- <doc:SelectionAndInteractions>
- <doc:AnimationsAndTapPlay>

### Native iOS 26 Tab Bar

- <doc:NativeLiquidTabBar>

### Custom Component API

- ``ITabBar``
- ``ITabBarShape``
- ``ITabBarStyle``
- ``ITabBarItemConfig``
- ``ITabBarDefaultItemView``
- ``ITabBarAnimation``
- ``ITabBarAnimationContext``
- ``ITabBarTapPlayView``

### Native Component API

- ``ILiquidTabBar``
- ``ILiquidTabBarItemConfig``
- ``ILiquidTabBarMinimizeBehavior``
