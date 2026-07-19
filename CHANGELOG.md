# Changelog

All notable changes to ITabBar are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and releases use semantic versioning.

## [0.3.0] - 2026-07-19

### Added

- Complete English DocC comments for declarations in the package and Example app.
- An `ITabBar.docc` catalog covering component selection, setup, shapes, items, styling, interactions, animation playback, native iOS 26 integration, and platform behavior.
- A documented, XcodeGen-managed `Example` application with ten integration scenarios and a shared UI-test scheme.
- Direct README navigation to DocC, Example, and this changelog.

### Changed

- Renamed the runnable integration directory from `demo` to `Example`.
- Updated installation and documentation examples for release 0.3.0.

### Compatibility

- Package API and runtime behavior are unchanged from 0.2.0.
- The package remains dependency-free; Lottie remains scoped to the Example app.

## [0.2.0] - 2026-07-17

### Added

- Native iOS 26 `ILiquidTabBar` integration backed by `UITabBarController`.
- Dynamic native items, badges, minimization behavior, and same-tab double-tap callbacks.
- Expanded integration examples and UI tests.

### Changed

- Selection is revalidated whenever a tab collection changes.
- Standard and native tab behavior now preserve selection by stable tab identity.

## [0.1.1] - 2026-06-14

### Fixed

- Improved package behavior and presentation following the initial release.

## [0.1.0] - 2026-05-18

### Added

- Initial Swift Package Manager release.
- Plain, concave, and convex SwiftUI tab bars.
- Default and custom tab item views, badges, center actions, styles, and item animations.
- Replayable custom active content through `ITabBarTapPlayView`.

[0.3.0]: https://github.com/ibabyblue/ITabBar/releases/tag/0.3.0
[0.2.0]: https://github.com/ibabyblue/ITabBar/releases/tag/0.2.0
[0.1.1]: https://github.com/ibabyblue/ITabBar/releases/tag/0.1.1
[0.1.0]: https://github.com/ibabyblue/ITabBar/releases/tag/0.1.0
