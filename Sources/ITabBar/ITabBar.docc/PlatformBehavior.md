# Platform Behavior

Plan availability and capability differences explicitly.

## iOS 17 through iOS 25

Use ``ITabBar``. SwiftUI renders the background, content, gestures, animations, center button, and safe-area coverage. ``ILiquidTabBar`` is unavailable.

## iOS 26 and Later

Both components are valid when compiled with Swift 6.2 or later. Use ``ITabBar`` for a branded custom surface or ``ILiquidTabBar`` for system Liquid Glass. They intentionally expose different capabilities and do not switch between implementations automatically.

## macOS 14 and Later

The package exposes ``ITabBar`` through SwiftUI. Core Motion and UIKit are not involved. Curved shapes, standard item interactions, and animations remain available, while ``ILiquidTabBar`` is excluded at compile time.

## Concurrency

SwiftUI view rendering and custom builders execute on the main actor where required. ``ITabBarAnimation/custom(_:)`` explicitly requires its builder on the main actor. Keep application state mutations performed by interaction callbacks compatible with the surrounding UI isolation.

## Dependencies

The package target has no external dependencies. The repository Example app uses Lottie 4.6.0 only for the bundled animation scenario; consumers do not receive Lottie transitively.
