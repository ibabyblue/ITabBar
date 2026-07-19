# Shapes, Center Actions, and Layout

Configure the custom component's contour and center button without changing its selection model.

## Choose a Shape

``ITabBarShape/plain`` draws a straight top edge and does not render the center button. ``ITabBarShape/concave`` creates a circular inward cutout. ``ITabBarShape/convex`` creates a dome that wraps around the floating action button.

```swift
ITabBar(
    tabs: tabs,
    selection: $selection,
    shape: .convex,
    style: style,
    configs: configs,
    onCenterTap: { compose() }
) { tab in
    page(for: tab)
}
```

Curved shapes reserve a center slot in the standard item row. The center action is independent of tab selection. If `onCenterTap` is `nil`, the button remains visible but performs no action.

## Tune Geometry

```swift
var style = ITabBarStyle()
style.height = 60
style.fabSize = 56
style.fabGap = 8
style.curveRadius = 38
style.convexProtrusion = 15
```

All dimensions are points. `fabGap` controls concave clearance and the fixed convex wrap clearance. `convexProtrusion` moves the button above the bar and controls dome height. Keep sizes positive and test compact widths; the package intentionally does not clamp consumer-supplied style values.

The background extends through the bottom safe area while item content remains in the configured top region. On macOS, the bottom inset is normally zero.
