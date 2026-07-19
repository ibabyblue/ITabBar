# ITabBar Example

This application is the runnable integration reference for ITabBar. It consumes the repository through a local Swift package dependency and keeps Example-only dependencies outside the package products.

## Run

1. Open `ITabBarDemo.xcodeproj` in Xcode.
2. Select the shared `ITabBarDemo` scheme.
3. Run an iOS 17 or newer simulator.

The Native Liquid Glass scene requires the iOS 26 SDK, Swift 6.2, and an iOS 26 runtime.

## Scenarios

| Section | Scenario | Demonstrates |
|---|---|---|
| Essentials | Basic Plain | Default items, selected symbols, a badge, and bound selection |
| Essentials | Tap Interactions | Immediate selection, same-tab double taps, and selected-tab long presses |
| Essentials | Concave + FAB | Center cutout, center action, and live geometry controls |
| Essentials | Convex + FAB | Center dome, center action, and live geometry controls |
| Essentials | Dynamic Tabs | Insertion, removal, reordering, and automatic selection correction |
| Customization | Custom Styling | Colors, fonts, dimensions, material, spacing, and badge styling |
| Customization | Custom Tab Item | A consumer-supplied SwiftUI item hierarchy |
| Customization | Built-in Animations | Bounce, wiggle, pop, and disabled animations |
| Customization | Lottie Animation | One-shot custom playback through `ITabBarTapPlayView` |
| iOS 26 | Native Liquid Glass | Native items, badges, dynamic tabs, double taps, and minimization |

The four bundled Lottie JSON resources use a 100 by 100 canvas and belong only to the Example application. ITabBar itself has no Lottie dependency.

## UI Tests

Run the shared scheme's Test action, or use:

```bash
xcodebuild -quiet test \
  -project Example/ITabBarDemo.xcodeproj \
  -scheme ITabBarDemo \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  CODE_SIGNING_ALLOWED=NO
```

The UI tests exercise the catalog, selection, badges, interaction callbacks, center actions, custom items, animation scenes, dynamic selection correction, and native iOS 26 behavior without downloading remote assets.

## Regenerate the Project

`project.yml` is the source of truth for the Xcode project:

```bash
xcodegen generate --spec Example/project.yml --project Example
```

Commit the regenerated project together with `project.yml` after structural changes.
